#!/usr/bin/env python3
"""Preview or build this Mac's configuration with conservative resource limits."""
import argparse
import os
from pathlib import Path
import signal
import subprocess
import sys
import time


def pressure():
    result = subprocess.run(
        ["/usr/sbin/sysctl", "-n", "kern.memorystatus_vm_pressure_level"],
        capture_output=True, text=True, check=True, timeout=5,
    )
    return int(result.stdout.strip())


def stop(process):
    if process.poll() is not None:
        return
    try:
        os.killpg(process.pid, signal.SIGTERM)
    except ProcessLookupError:
        return
    try:
        process.wait(timeout=5)
    except subprocess.TimeoutExpired:
        os.killpg(process.pid, signal.SIGKILL)
        process.wait()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["plan", "build", "check"])
    parser.add_argument("target", nargs="?", default=None)
    parser.add_argument("--timeout", type=int, help="Wall time limit in seconds")
    parser.add_argument("--allow-warning", action="store_true",
                        help="Allow warning-level pressure with one core and a 1 GiB GC heap cap")
    parser.add_argument("--gc-heap-mib", type=int, help="GC heap cap in MiB (128 to 2048)")
    parser.add_argument("--out-link", help="Keep the build result at this path")
    args = parser.parse_args()
    if args.gc_heap_mib is not None and not 128 <= args.gc_heap_mib <= 2048:
        parser.error("--gc-heap-mib must be between 128 and 2048")
    if sys.platform != "darwin":
        parser.error("This guard currently supports macOS only")
    try:
        level = pressure()
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print(f"Cannot verify memory pressure; refusing to start: {error}", file=sys.stderr)
        return 75
    allowed_levels = (1, 2) if args.allow_warning else (1,)
    if level not in allowed_levels:
        print(f"Memory pressure level {level} (1 = normal): refusing Nix evaluation/build.", file=sys.stderr)
        return 75

    nix = Path("/nix/var/nix/profiles/default/bin/nix")
    if not nix.exists():
        parser.error("The system Nix installation was not found")
    env = os.environ.copy()
    cores = 1 if args.allow_warning else 2
    env["NIX_CONFIG"] = env.get("NIX_CONFIG", "") + f"\nmax-jobs = 1\ncores = {cores}\nmax-substitution-jobs = 4\n"
    env.setdefault("GC_INITIAL_HEAP_SIZE", str(64 * 1024 * 1024))
    try:
        version = subprocess.check_output([str(nix), "--version"], env=env, text=True, timeout=30)
    except (OSError, subprocess.SubprocessError) as error:
        print(f"Cannot inspect Nix version; refusing to start: {error}", file=sys.stderr)
        return 75
    if "Determinate" in version:
        env["NIX_CONFIG"] += "eval-cores = 1\n"
    heap_mib = args.gc_heap_mib or (1024 if args.allow_warning else None)
    if heap_mib:
        env["GC_MAXIMUM_HEAP_SIZE"] = str(heap_mib * 1024 * 1024)
    if args.action == "check":
        command = [str(nix), "flake", "check", args.target or ".", "--impure", "--no-update-lock-file"]
    else:
        command = [str(nix), "build", args.target or ".#darwinConfigurations.mac-arm.system",
                   "--impure", "--no-update-lock-file"]
        command += ["--out-link", str(Path(args.out_link).resolve())] if args.out_link else ["--no-link"]
    if args.action == "plan":
        command.append("--dry-run")
    limit = args.timeout or (90 if args.action == "plan" else 1200)
    rss_limit_kib = 2 * 1024 * 1024
    print(f"{args.action}: 1 build job, {cores} core(s)/job; evaluator limit 2 GiB, timeout {limit}s", flush=True)
    process = subprocess.Popen(command, env=env, start_new_session=True, preexec_fn=lambda: os.nice(10))
    start = time.monotonic()
    reason = None
    try:
        while process.poll() is None:
            time.sleep(0.5)
            if process.poll() is not None:
                break
            if pressure() not in allowed_levels:
                reason = "macOS memory pressure exceeded the permitted level"
            elif time.monotonic() - start > limit:
                reason = "wall time limit exceeded"
            else:
                result = subprocess.run(
                    ["/bin/ps", "-p", str(process.pid), "-o", "rss="],
                    capture_output=True, text=True, check=False, timeout=5,
                )
                if result.stdout.strip() and int(result.stdout) > rss_limit_kib:
                    reason = "Nix evaluator exceeded 2 GiB resident memory"
            if reason:
                break
    except KeyboardInterrupt:
        reason = "interrupted"
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        reason = f"resource monitor failed: {error}"
    finally:
        if reason:
            stop(process)
    if reason:
        print(f"Stopped: {reason}. No configuration was activated.", file=sys.stderr)
        return 75
    return process.wait()


if __name__ == "__main__":
    sys.exit(main())
