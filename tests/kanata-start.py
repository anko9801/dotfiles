#!/usr/bin/env python3
"""Check startup behavior without grabbing a keyboard or loading a driver."""
import json
import os
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix="kanata-start-test-") as directory:
    base = Path(directory)
    calls = base / "calls.jsonl"
    status = base / "extensions"
    extensions = base / "systemextensionsctl"
    extensions.write_text("#!/bin/sh\ncat \"$KANATA_TEST_STATUS\"\nexit \"${KANATA_TEST_STATUS_EXIT:-0}\"\n")
    extensions.chmod(0o755)
    launchctl = base / "launchctl"
    launchctl.write_text("#!/bin/sh\nprintf 'state = %s\\n' \"${KANATA_TEST_SERVICE_STATE:-running}\"\nexit \"${KANATA_TEST_SERVICE_EXIT:-0}\"\n")
    launchctl.chmod(0o755)
    binary = base / "kanata with spaces"
    binary.write_text("""#!/usr/bin/env python3
import json, os, sys
with open(os.environ['KANATA_TEST_CALLS'], 'a') as f:
    f.write(json.dumps(sys.argv[1:]) + '\\n')
sys.exit(int(os.environ.get('KANATA_TEST_CHECK_EXIT' if '--check' in sys.argv else 'KANATA_TEST_RUN_EXIT', '0')))
""")
    binary.chmod(0o755)
    config = base / "keyboard config.kbd"
    config.write_text("test fixture")
    env = dict(os.environ, KANATA_SYSTEMEXTENSIONSCTL=str(extensions), KANATA_LAUNCHCTL=str(launchctl),
               KANATA_TEST_STATUS=str(status), KANATA_TEST_CALLS=str(calls))

    def run(state, **overrides):
        status.write_text(state)
        calls.write_text("")
        result = subprocess.run(
            ["/bin/sh", str(root / "desktop/kanata-start.sh"), str(binary), str(config)],
            env=dict(env, **overrides), capture_output=True, text=True, timeout=5,
        )
        return result, [json.loads(line) for line in calls.read_text().splitlines()]

    driver = "org.pqrs.Karabiner-DriverKit-VirtualHIDDevice"
    waiting = f"\t*\tTEAM\t{driver} (1.8.0)\tDriver\t[activated waiting for user]\n"
    active = f"*\t*\tTEAM\t{driver} (1.8.0)\tDriver\t[activated enabled]\n"
    for state in ("", waiting, "* * TEAM other.driver (1) [activated enabled]\n"):
        result, log = run(state)
        assert result.returncode == 0 and not log, "Unavailable driver must not start a failing remapper"
    result, log = run(active, KANATA_TEST_STATUS_EXIT="1")
    assert result.returncode == 0 and not log
    result, log = run(active, KANATA_TEST_SERVICE_EXIT="1")
    assert result.returncode == 0 and not log
    result, log = run(active, KANATA_TEST_SERVICE_STATE="waiting")
    assert result.returncode == 0 and not log, "Do not grab input while the output service is unavailable"
    result, log = run(active, KANATA_TEST_CHECK_EXIT="1")
    assert result.returncode == 0 and len(log) == 1 and "--check" in log[0]
    result, log = run(active)
    assert result.returncode == 0 and len(log) == 2
    assert log[1] == ["--quiet", "--no-wait", "-c", str(config)]
    result, log = run(active, KANATA_TEST_RUN_EXIT="3")
    assert result.returncode == 3, "Unexpected runtime failure must remain observable to launchd"
print("Kanata startup: unapproved/missing driver, failed checks, quoting, and runtime errors passed")
