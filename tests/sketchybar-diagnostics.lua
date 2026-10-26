local H = dofile("tests/sketchybar-harness.lua")
dofile("desktop/sketchybar/items/metrics.lua")
local function sample(time, user, system, idle, incoming, outgoing)
  H.time = time
  H.complete("desktop-metrics", { user = user, system = system, nice = 0, idle = idle,
    monotonic = time, memory_percent = 37.5, pressure = 2, swap_gib = 1, swap_total_gib = 2,
    memory_bytes = 1.5 * 2^30, total_bytes = 4 * 2^30, anonymous_bytes = 1.125 * 2^30, purgeable_bytes = 2^27,
    wired_bytes = 2^28, compressed_bytes = 2^28, file_backed_bytes = 2^29,
    page_size = 16384, swapin_pages = incoming, swapout_pages = outgoing,
    logical_cpus = 8, physical_cpus = 8, load_average = { 1, 2, 3 } })
end
local function click(name)
  H.emit(name, "mouse.clicked")
  return H.complete("menu-client", "")
end
H.emit("metrics.observer", "forced")
sample(100, 100, 200, 700, 100, 200)
H.run_timer(1)
sample(102, 150, 250, 800, 104, 210)
H.time = 104
local cpu = click("widgets.cpu.graph")
assert(cpu:find("User / System\t25.0% / 25.0%", 1, true))
assert(cpu:find("Load 1 / 5 / 15m\t1.00 / 2.00 / 3.00", 1, true))
assert(cpu:find("Sample age: 2.0 s at open", 1, true))
local memory = click("widgets.memory.graph")
assert(memory:find("Used (estimate)\t1.50 GiB / 4.00 GiB", 1, true))
assert(memory:find("Swap in / out\t2.0 / 5.0 pages/s", 1, true))
assert(memory:find("Page size\t16 KiB", 1, true))
H.emit("metrics.observer", "routine")
sample(104, 200, 300, 900, 1, 2)
assert(click("widgets.memory.graph"):find("Swap in / out\t—", 1, true), "Reset counters cannot create false I/O")
H.emit("metrics.observer", "routine")
H.complete("desktop-metrics", {}, 1)
assert(not click("widgets.memory.graph"):find("1.50 GiB", 1, true), "Read failure clears diagnostic values")

dofile("desktop/sketchybar/items/wifi.lua")
local function network(time, rx, tx)
  H.time = time
  H.complete("desktop-network", { status = "interface", interface = "en7", monotonic = time,
    address = "2001:db8::1", ipv6 = "2001:db8::1", gateway = "2001:db8::2", primary_family = "IPv6",
    mtu = 1500, dns = "2001:db8::53,192.0.2.53", rx_bytes = rx, tx_bytes = tx })
end
H.emit("widgets.wifi", "forced")
network(104, 1000, 2000)
H.emit("widgets.wifi", "routine")
network(106, 3048, 6096)
local net = click("widgets.wifi")
assert(net:find("Rx / Tx\t1.0 KiB/s / 2.0 KiB/s", 1, true))
assert(net:find("IPv4: —", 1, true) and net:find("IPv6: 2001:db8::1", 1, true))
assert(net:find("Global DNS (SC)", 1, true) and net:find("192.0.2.53", 1, true) and net:find("MTU\t1500", 1, true))

dofile("desktop/sketchybar/items/volume.lua")
H.emit("widgets.volume", "forced")
H.complete("desktop-audio", { device = 1, volume = 25, muted = false, name = "USB Audio", writable = true,
  sample_rate = 48000, buffer_frames = 128, monotonic = 106 })
local audio = click("widgets.volume")
assert(audio:find("USB Audio", 1, true) and not audio:find("Sampled output\t", 1, true))
assert(audio:find("Nominal rate\t48.0 kHz", 1, true))
assert(audio:find("Buffer duration\t2.67 ms", 1, true) and audio:find("Buffer duration ≠ end-to-end latency", 1, true))
print("SketchyBar diagnostics: CPU shares, byte units, page rates, resets, IPv6, DNS, audio and monotonic age passed")
