#!/usr/bin/env python3
"""Exercise the public socket protocol without a running window manager."""

import importlib.util
import json
from pathlib import Path
import socket
import struct
import threading
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("bridge", Path("desktop/aerospace-events.py"))
bridge = importlib.util.module_from_spec(spec)
spec.loader.exec_module(bridge)


def frame(value):
    data = json.dumps(value).encode()
    return struct.pack("=I", len(data)) + data


class EventsTest(unittest.TestCase):
    def test_fragmented_frame_and_disconnect(self):
        reader, writer = socket.socketpair()
        reader.settimeout(1)
        data = frame({"_event": "focused-workspace-changed", "workspace": "研究"})
        def send():
            with writer:
                for part in (data[:1], data[1:3], data[3:8], data[8:]):
                    writer.sendall(part)
        worker = threading.Thread(target=send)
        worker.start()
        with reader:
            self.assertEqual(bridge.read_frame(reader)["workspace"], "研究")
            with self.assertRaises(EOFError):
                bridge.read_frame(reader)
        worker.join(2)

    def test_invalid_frames(self):
        for data in (struct.pack("=I", 65537), frame([]), struct.pack("=I", 0), b"\x01\x00"):
            reader, writer = socket.socketpair()
            with reader, writer:
                writer.sendall(data)
                writer.shutdown(socket.SHUT_WR)
                with self.assertRaises((ValueError, EOFError)):
                    bridge.read_frame(reader)

    def test_subscription_burst_and_eof(self):
        reader, writer = socket.socketpair()
        reader.settimeout(1)
        writer.settimeout(1)
        errors = []
        def serve():
            try:
                with writer:
                    self.assertEqual(bridge.read_exact(writer, 4), struct.pack("=I", 1))
                    writer.sendall(struct.pack("=I", 1))
                    request = bridge.read_frame(writer)
                    self.assertEqual(request["args"], ["subscribe", "focused-workspace-changed", "window-detected"])
                    self.assertIsNone(request["windowId"])
                    self.assertIsNone(request["workspace"])
                    writer.sendall(b"".join([
                        frame({"_event": "focused-workspace-changed", "workspace": "1"}),
                        frame({"_event": "window-detected"}),
                        frame({"_event": "focused-workspace-changed", "workspace": "研究"}),
                    ]))
            except Exception as error:
                errors.append(error)
        worker = threading.Thread(target=serve)
        worker.start()
        events = []
        with reader, self.assertRaises(EOFError):
            bridge.watch(reader, lambda *args: events.append(args))
        worker.join(2)
        self.assertFalse(errors)
        self.assertEqual(events, [("aerospace_workspace_change", "FOCUSED_WORKSPACE=研究"), ("aerospace_windows_change",)])

    def test_publish_passes_literal_arguments_and_bounds_child(self):
        value = "FOCUSED_WORKSPACE=$(touch /tmp/unwanted)"
        with patch.object(bridge.subprocess, "run") as run:
            bridge.publish("/opt/homebrew/bin/sketchybar", "event", value)
        self.assertEqual(run.call_args.args[0], ["/opt/homebrew/bin/sketchybar", "--trigger", "event", value])
        self.assertEqual(run.call_args.kwargs["timeout"], 2)
        self.assertNotIn("shell", run.call_args.kwargs)

    def test_protocol_and_workspace_validation(self):
        for data in (
            struct.pack("=I", 2),
            struct.pack("=I", 1) + frame({"_event": "focused-workspace-changed", "workspace": 2}),
            struct.pack("=I", 1) + frame({"_event": "focused-workspace-changed", "workspace": "x\0y"}),
        ):
            reader, writer = socket.socketpair()
            reader.settimeout(1)
            with reader, writer:
                writer.sendall(data)
                with self.assertRaises(ValueError):
                    bridge.watch(reader, lambda *args: self.fail("Unverified event was published"))


if __name__ == "__main__":
    unittest.main()
