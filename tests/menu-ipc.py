"""Check native menu transport, construction latency and owner-bound lifetime without UI."""
import json
import os
import statistics
import subprocess
import sys
import time

server_path, client_path = sys.argv[1:3]
owner = subprocess.Popen(["/bin/cat"], stdin=subprocess.PIPE, stdout=subprocess.DEVNULL)
channel = f"pub.anko.sketchybar-menu.test.{os.getpid()}"
server = subprocess.Popen([server_path, "--serve", str(owner.pid), channel], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
try:
    deadline = time.monotonic() + 15
    while time.monotonic() < deadline:
        ping = subprocess.run([client_path, "--ping", channel], capture_output=True, text=True)
        if ping.returncode == 0:
            break
        assert server.poll() is None, server.stderr.read().decode()
        time.sleep(0.05)
    assert ping.returncode == 0, "Native menu host did not become ready"
    pid = int(ping.stdout)
    fixtures = {
        "cpu": ["CPU", "Busy (all CPUs)\t50%", "User / System\t25.0% / 25.0%", "Idle / Nice\t50.0% / 0.0%",
                "Load 1 / 5 / 15m\t1.20 / 2.40 / 3.60", "Physical / Logical\t10 / 10", "Sample age: 1.0 s at open"],
        "memory": ["Memory", "Used (estimate)\t12.00 GiB / 16.00 GiB", "Anon / Wired\t8.00 GiB / 2.00 GiB",
                   "Compressor RAM\t2.00 GiB", "Swap used / total\t3.00 GiB / 4.00 GiB", "Swap in / out\t2.0 / 5.0 pages/s"],
        "network": ["Network", "en7 · SC primary: IPv4", "IPv4: 192.0.2.1", "IPv6: 2001:db8:1234:5678:9abc:def0:1234:5678",
                    "Router (SC): 192.0.2.254", "Global DNS (SC)", "  2001:db8::53", "MTU\t1500", "Rx / Tx\t1.00 MiB/s / 2.00 MiB/s"],
        "volume": ["Sound", "USB Audio", "Nominal rate\t48.0 kHz", "I/O buffer\t128 frames"],
        "battery": ["Battery", "Charge\t75%", "Remaining (OS est.)\t3:00"],
        "calendar": ["Calendar"],
    }
    kind_timings = {}
    for kind in ["cpu", "memory", "volume", "network", "battery", "calendar"]:
        start = time.perf_counter()
        subprocess.run([client_path, "--bench", channel, "0", kind, *fixtures[kind]], check=True)
        kind_timings[kind] = round((time.perf_counter() - start) * 1000, 3)
    timings = []
    for _ in range(20):
        start = time.perf_counter()
        subprocess.run([client_path, "--bench", channel, "0", "cpu", *fixtures["cpu"]], check=True)
        timings.append((time.perf_counter() - start) * 1000)
        current = subprocess.check_output([client_path, "--ping", channel], text=True)
        assert int(current) == pid, "A click must reuse the same AppKit host"
    bad = subprocess.run([client_path, "--bench", channel, "0", "invalid", "test"])
    assert bad.returncode == 75
    def cpu_seconds():
        value = subprocess.check_output(["/bin/ps", "-p", str(pid), "-o", "time="], text=True).strip()
        minutes, seconds = value.split(":")
        return int(minutes) * 60 + float(seconds)

    before = cpu_seconds()
    started = time.monotonic()
    time.sleep(5)
    idle_cpu = (cpu_seconds() - before) / (time.monotonic() - started) * 100
    rss = int(subprocess.check_output(["/bin/ps", "-p", str(pid), "-o", "rss="], text=True))
    assert idle_cpu < 1, "An idle menu host must not poll or busy-wait"
    print(json.dumps({"samples": len(timings), "median_request_ms": round(statistics.median(timings), 3),
                      "max_request_ms": round(max(timings), 3), "idle_cpu_percent": round(idle_cpu, 3), "rss_kib": rss,
                      "first_request_by_kind_ms": kind_timings, "reused_host": True}))
    owner.terminate()
    owner.wait(timeout=3)
    assert server.wait(timeout=3) == 0, "Native menu host must exit with its owning bar"
    gone = subprocess.run([client_path, "--ping", channel])
    assert gone.returncode == 69
    print("Native menu IPC: owner exit, endpoint removal and invalid-request rejection passed")
finally:
    for process in (server, owner):
        if process.poll() is None:
            process.terminate()
            process.wait(timeout=3)
