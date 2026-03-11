#!/usr/bin/env python3
"""Wrap nix build to capture traces and convert to Chrome trace format.

Usage:
  # Record a build (wraps nix build, adds timestamps)
  python3 nix-build-trace.py record -- nix build .#target --impure
  # -> writes /tmp/build.jsonl

  # Convert to Chrome trace
  python3 nix-build-trace.py convert /tmp/build.jsonl -o trace.json
  # -> open trace.json in https://ui.perfetto.dev/
"""

import json
import subprocess
import sys
import time
from pathlib import Path


def cmd_record(args: list[str]) -> int:
    """Run a nix build command, capture timestamped internal-json logs."""
    # Insert --log-format internal-json if not present
    if "--log-format" not in args:
        # Find 'nix' command position and insert after 'build'
        nix_args = args[:]
        for i, a in enumerate(nix_args):
            if a in ("build", "eval", "develop", "shell"):
                nix_args.insert(i + 1, "--log-format")
                nix_args.insert(i + 2, "internal-json")
                break
        else:
            nix_args.extend(["--log-format", "internal-json"])
        args = nix_args

    proc = subprocess.Popen(args, stderr=subprocess.PIPE, text=True)
    output_path = Path("/tmp/build.jsonl")

    with output_path.open("w") as f:
        for line in proc.stderr:
            ts = time.time()
            f.write(f"{ts}\t{line}")

            # Show derivation build starts on stderr for CI visibility
            if line.startswith("@nix "):
                try:
                    data = json.loads(line.strip()[5:])
                    if data.get("action") == "start" and data.get("type") == 105:
                        print(data.get("text", ""), file=sys.stderr)
                    elif data.get("action") == "msg":
                        msg = data.get("msg", "")
                        if msg:
                            print(msg, file=sys.stderr)
                except (json.JSONDecodeError, KeyError):
                    pass

    rc = proc.wait()
    count = sum(1 for l in output_path.read_text().splitlines() if "@nix" in l)
    print(f"Captured {count} nix events to {output_path}", file=sys.stderr)
    return rc


def cmd_convert(log_path: str, out_path: str = "trace.json") -> None:
    """Convert timestamped nix internal-json log to Chrome trace format."""
    events = []
    active: dict[int, tuple[str, float]] = {}  # id -> (name, start_us)
    tid_map: dict[int, int] = {}  # nix_id -> thread_id (for parallel builds)
    next_tid = 0

    for line in Path(log_path).read_text().splitlines():
        if "\t" not in line:
            continue
        ts_str, rest = line.split("\t", 1)
        rest = rest.strip()
        if not rest.startswith("@nix "):
            continue

        try:
            ts_us = float(ts_str) * 1_000_000
            data = json.loads(rest[5:])
        except (ValueError, json.JSONDecodeError):
            continue

        action = data.get("action")
        nix_id = data.get("id")
        if nix_id is None:
            continue

        event_type = data.get("type")
        # type 105 = derivation build, type 100 = substitution (cache fetch)
        if action == "start" and event_type in (105, 100):
            text = data.get("text", "")
            name = text
            if "/nix/store/" in text:
                drv = text.split("/nix/store/")[-1].rstrip(".'\"…")
                parts = drv.split("-", 1)
                name = parts[1] if len(parts) > 1 else drv
                name = name.removesuffix(".drv")

            category = "build" if event_type == 105 else "substitute"
            active[nix_id] = (name, ts_us, category)
            tid_map[nix_id] = next_tid
            next_tid += 1

        elif action == "stop" and nix_id in active:
            name, start_us, category = active.pop(nix_id)
            tid = tid_map.pop(nix_id, 0)
            dur = ts_us - start_us
            events.append({
                "name": name,
                "cat": category,
                "ph": "X",  # Complete event
                "ts": start_us,
                "dur": dur,
                "pid": 0,
                "tid": tid,
            })

    # Sort by start time
    events.sort(key=lambda e: e["ts"])

    # Normalize timestamps (start from 0)
    if events:
        base = events[0]["ts"]
        for e in events:
            e["ts"] -= base

    trace = {"traceEvents": events, "displayTimeUnit": "ms"}
    Path(out_path).write_text(json.dumps(trace, indent=2))
    print(f"Wrote {len(events)} build spans to {out_path}")
    print(f"Open in https://ui.perfetto.dev/")


def main():
    if len(sys.argv) < 2:
        print("Usage:", file=sys.stderr)
        print(f"  {sys.argv[0]} record -- nix build .#target", file=sys.stderr)
        print(f"  {sys.argv[0]} convert build.jsonl [-o trace.json]", file=sys.stderr)
        sys.exit(1)

    cmd = sys.argv[1]

    if cmd == "record":
        if "--" in sys.argv:
            idx = sys.argv.index("--")
            nix_args = sys.argv[idx + 1:]
        else:
            nix_args = sys.argv[2:]
        rc = cmd_record(nix_args)
        sys.exit(rc)

    elif cmd == "convert":
        log_path = sys.argv[2]
        out_path = "trace.json"
        if "-o" in sys.argv:
            idx = sys.argv.index("-o")
            out_path = sys.argv[idx + 1]
        cmd_convert(log_path, out_path)

    else:
        print(f"Unknown command: {cmd}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
