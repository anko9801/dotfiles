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
    kind_timings = {}
    for kind in ["cpu", "memory", "volume", "network", "battery", "calendar"]:
        start = time.perf_counter()
        subprocess.run([client_path, "--bench", channel, "0", kind, "test"], check=True)
        kind_timings[kind] = round((time.perf_counter() - start) * 1000, 3)
    timings = []
    for _ in range(20):
        start = time.perf_counter()
        subprocess.run([client_path, "--bench", channel, "0", "cpu", "CPU", "使用率 25%"], check=True)
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
