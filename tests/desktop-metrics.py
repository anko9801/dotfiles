"""Validate real collector schemas and units without changing system state."""
import ipaddress
import json
import math
import subprocess
import sys
import time

metrics, network, audio = sys.argv[1:4]


def read(path, optional=False):
    result = subprocess.run([path], capture_output=True, text=True, timeout=5)
    if optional and result.returncode:
        return None
    assert result.returncode == 0, (path, result.stderr)
    return json.loads(result.stdout)


sample = read(metrics)
for name in ["user", "system", "nice", "idle", "page_size", "swapin_pages", "swapout_pages",
             "memory_bytes", "total_bytes", "anonymous_bytes", "purgeable_bytes", "wired_bytes", "compressed_bytes", "file_backed_bytes"]:
    assert isinstance(sample[name], int) and sample[name] >= 0, name
assert sample["page_size"] > 0 and sample["total_bytes"] > 0
used = min(max(0, sample["anonymous_bytes"] - sample["purgeable_bytes"])
           + sample["wired_bytes"] + sample["compressed_bytes"], sample["total_bytes"])
assert sample["memory_bytes"] == used
assert abs(sample["memory_percent"] - 100 * used / sample["total_bytes"]) <= 0.051
if sample["load_average"] is not None:
    assert len(sample["load_average"]) == 3
    assert all(math.isfinite(value) and value >= 0 for value in sample["load_average"])
time.sleep(0.05)
assert read(metrics)["monotonic"] > sample["monotonic"]

route = read(network)
assert route["status"] in {"no-route", "interface"}
if route["status"] == "interface":
    assert route["interface"] and route["primary_family"] in {"IPv4", "IPv6"}
    if route["ipv4"]:
        assert ipaddress.ip_address(route["ipv4"]).version == 4
    if route["ipv6"]:
        assert ipaddress.ip_address(route["ipv6"]).version == 6
    assert route["address"] == (route["ipv4"] or route["ipv6"])
    assert route["mtu"] is None or route["mtu"] > 0

output = read(audio, optional=True)
if output:
    assert output["device"] > 0 and output["monotonic"] > 0
    assert output["sample_rate"] is None or output["sample_rate"] > 0
    assert output["buffer_frames"] is None or output["buffer_frames"] > 0
    assert output["writable"] is None or isinstance(output["writable"], bool)
    assert output["name"] is None or isinstance(output["name"], str)
print("Native collectors: VM byte accounting, 64-bit page counters, address families and audio schema passed")
