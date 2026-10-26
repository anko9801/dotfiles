"""Forward AeroSpace's ordered socket events without spawning on its UI thread."""

import json
import os
import pwd
import select
import socket
import stat
import struct
import subprocess
import sys


def read_exact(connection, count):
    result = bytearray()
    while len(result) < count:
        part = connection.recv(count - len(result))
        if not part:
            raise EOFError("AeroSpace disconnected")
        result.extend(part)
    return bytes(result)


def read_frame(connection):
    size = struct.unpack("=I", read_exact(connection, 4))[0]
    if not 0 < size <= 65536:
        raise ValueError("Invalid AeroSpace frame size")
    event = json.loads(read_exact(connection, size))
    if not isinstance(event, dict):
        raise ValueError("Invalid AeroSpace event")
    return event


def watch(connection, publish):
    connection.sendall(struct.pack("=I", 1))
    if struct.unpack("=I", read_exact(connection, 4))[0] != 1:
        raise ValueError("Unsupported AeroSpace protocol")
    request = json.dumps({
        "args": ["subscribe", "focused-workspace-changed", "window-detected"],
        "stdin": "", "windowId": None, "workspace": None,
    }).encode()
    connection.sendall(struct.pack("=I", len(request)) + request)
    while True:
        select.select([connection], [], [])
        workspace, changed = None, False
        while True:
            event = read_frame(connection)
            if event.get("_event") == "focused-workspace-changed":
                value = event.get("workspace")
                if not isinstance(value, str) or not value or "\0" in value:
                    raise ValueError("Invalid workspace event")
                workspace = value
            elif event.get("_event") == "window-detected":
                changed = True
            if not select.select([connection], [], [], 0)[0]:
                break
            # Publish buffered state before EOF; the next iteration reports loss.
            if not connection.recv(1, socket.MSG_PEEK):
                break
        if workspace is not None:
            publish("aerospace_workspace_change", "FOCUSED_WORKSPACE=" + workspace)
        if changed:
            publish("aerospace_windows_change")


def publish(executable, event, *environment):
    subprocess.run(
        [executable, "--trigger", event, *environment], check=True, timeout=2,
        stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )


def main():
    executable = sys.argv[1] if len(sys.argv) > 1 else "/opt/homebrew/bin/sketchybar"
    username = pwd.getpwuid(os.getuid()).pw_name
    path = "/tmp/bobko.aerospace-" + username + ".sock"
    try:
        info = os.stat(path)
        if not stat.S_ISSOCK(info.st_mode) or info.st_uid != os.getuid():
            raise ValueError("Unexpected AeroSpace socket owner or type")
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as connection:
            connection.settimeout(2)
            connection.connect(path)
            watch(connection, lambda *args: publish(executable, *args))
    except (OSError, EOFError, ValueError, subprocess.SubprocessError):
        return 1
    finally:
        try:
            publish(executable, "aerospace_connection_change", "CONNECTED=0")
        except (OSError, subprocess.SubprocessError):
            pass
    return 0


if __name__ == "__main__":
    sys.exit(main())
