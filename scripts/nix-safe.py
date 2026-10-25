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
    args = parser.parse_args()
    if sys.platform != "darwin":
        parser.error("This guard currently supports macOS only")
    try:
        level = pressure()
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print(f"Cannot verify memory pressure; refusing to start: {error}", file=sys.stderr)
        return 75
    if level != 1:
        print(f"Memory pressure level {level} (1 = normal): refusing Nix evaluation/build.", file=sys.stderr)
        return 75

    nix = Path("/nix/var/nix/profiles/default/bin/nix")
    if not nix.exists():
        parser.error("The system Nix installation was not found")
    env = os.environ.copy()
    env["NIX_CONFIG"] = env.get("NIX_CONFIG", "") + "\nmax-jobs = 1\ncores = 2\nmax-substitution-jobs = 4\n"
    version = subprocess.check_output([str(nix), "--version"], text=True, timeout=5)
    if "Determinate" in version:
        env["NIX_CONFIG"] += "eval-cores = 1\n"
    env.setdefault("GC_INITIAL_HEAP_SIZE", str(64 * 1024 * 1024))
    if args.action == "check":
        command = [str(nix), "flake", "check", args.target or ".", "--impure", "--no-update-lock-file"]
    else:
        command = [str(nix), "build", args.target or ".#darwinConfigurations.mac-arm.system",
                   "--impure", "--no-link", "--no-update-lock-file"]
    if args.action == "plan":
        command.append("--dry-run")
    limit = args.timeout or (90 if args.action == "plan" else 1200)
    rss_limit_kib = 2 * 1024 * 1024
    print(f"{args.action}: 1 build job, 2 cores/job; evaluator limit 2 GiB, timeout {limit}s", flush=True)
    process = subprocess.Popen(command, env=env, start_new_session=True, preexec_fn=lambda: os.nice(10))
    start = time.monotonic()
    reason = None
    try:
        while process.poll() is None:
            time.sleep(0.5)
            if process.poll() is not None:
                break
            if pressure() != 1:
                reason = "macOS memory pressure rose above normal"
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
