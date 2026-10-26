# SketchyBar stability and visible layout

<!-- cspell:ignore sbar -->

Implemented after the [research proposal](sketchybar-improvement-proposal.md).
The native client remains pinned to the existing SbarLua revision; a reviewed
local patch changes its lifecycle and IPC behavior without importing a fork.

## Native client

- Send and reply waits are bounded to one second per attempt. The existing
  reconnect path can make a second attempt after send failure. Reply timeouts do
  not resend an already delivered command, preserving toggle semantics. This bounds a stalled endpoint; it
  is not a claim that all desktop actions complete within that time.
- Empty transactions and property-less updates are skipped. Nested transactions
  keep their depth, including across synchronous queries.
- Completed timer and execution callbacks release one-shot registry references;
  subscription references remain live. Callback errors are removed from the stack.
- Invalid query JSON returns nil. Execution workers reset their inherited child
  signal disposition, use a ten-second alarm, and preserve signaled exit status.
  Callback messages are explicitly terminated.

The module links the already-built Lua 5.5 runtime instead of rebuilding its
vendored interpreter for each patch. The patch is shared by the renderer and AeroSpace's direct notifier. The notifier,
workspace ordering guard and cached membership remain in place. The redundant
startup CLI update is removed because the native event loop initializes updates.

Native checks exercise nested/empty transactions, callback release, persistent
subscriptions, error-stack recovery, malformed query data and a saturated private
Mach queue. An isolated timer test changes from 201 retained function references
after 200 completed timers to zero. It does not contact the running bar and does
not establish a measured live latency improvement.

## Probe recovery

Requests carry an identity. A sixteen-second completion deadline covers the
native worker's ten-second launch budget plus the wrapped command's four-second
timeout and one-second termination grace. Missing completion releases the request
state and schedules bounded exponential retry. Retired callbacks/retries cannot
replace a newer request or clear an authoritative workspace event.

Routine operation still coalesces requests and keeps a single active request.
As before, freshness timers depend on the Lua event loop being alive; no external
watchdog or automatic application restart is introduced. A stalled native launch
or OS scheduling delay can still affect elapsed times.

## Layout and interactions

The user rejected hiding application locations and graphs. The final layout keeps
all occupied workspaces' application icons and CPU/memory graphs continuously
visible. The selected workspace gains a border/background; existing workspace
bindings and application grouping remain unchanged. Network throughput also stays
on the main bar.

SketchyBar's custom popup windows are replaced by native AppKit menus. CPU, memory,
network and battery clicks show the bar's latest validated details below the bar.
Volume includes a standard slider when CoreAudio exposes a writable volume
property. It verifies the default device before a user-initiated write. The date
opens a native month calendar. The operating system supplies menu appearance,
keyboard navigation and dismissal; no theme-colored popup window is drawn.

The menu host initializes with the bar and reuses AppKit rather than launching a
new application on each click. A small Core Foundation client sends bounded local
requests to a channel unique to the bar process and its birth time. Only missing
endpoints are retried; ambiguous timeouts never duplicate a menu. The host watches
the owning bar process and exits when it does, including across bar reloads.

The accessory has no Dock icon or independent work window and does not poll while
idle. Its temporary invisible status anchor is removed on close. Informational
rows use standard text labels with the primary system color, avoiding disabled
action tint and secondary gray for the actual values. Activity Monitor and
settings remain explicit secondary actions. Media keeps its direct play/pause
action. Unreadable volume remains unknown rather than being labeled as external.

`bash scripts/check-native-menu.sh` checks the actual AppKit label colors,
same-process request reuse, invalid requests, idle CPU and owner-bound teardown
without showing menus. Its timing is transport plus native menu construction,
not physical click-to-screen latency. The host retains the latest handler-to-
`menuWillOpen` timing in memory, readable with `menu-client --metrics <channel>`.
The menu path performs no diagnostic disk writes. Compositor and display delay
are outside that measurement.

## Diagnostic snapshots

Numeric readouts use two columns with monospaced, left-aligned values and an
eight-point column gap. Names, status, address/DNS lists and explanatory text are
plain lines. Width follows content rather than a fixed wide panel (normally
200–480 points, with intrinsic minimums for sliders and the calendar). The bar's
graphs and application layout stay unchanged. No collection or network probe
runs on click. `Sample age: ... at open` is the monotonic
age of the cached reading when the menu opens; menu values are snapshots, while
the bar graphs continue updating. Missing reads clear the old values.

- CPU: busy, user/system, idle/nice, raw 1/5/15-minute load averages, physical and
  logical CPU counts, and the actual sampling interval. Busy is normalized so
  100% means all logical CPUs; load averages are counts, not percentages.
- Memory: used/total GiB, anonymous and wired bytes, purgeable pages within the
  anonymous count, physical compressor RAM, file-backed pages, swap used/total,
  swap-in/out pages per second and page size. Estimated used memory is
  `max(anonymous - purgeable, 0) + wired + compressor`, capped at physical RAM.
  File-backed pages are not an unconditional free-memory estimate. Swap page
  rates describe logical pages processed, not physical disk-byte throughput.
- Network: the SystemConfiguration primary interface/family/router, IPv4 and
  non-link-local IPv6, MTU, per-interface receive/transmit rates and cumulative
  bytes, and the global DNS addresses. Global DNS does not enumerate all scoped
  or split-DNS resolvers, and primary-interface counters are not machine-wide
  traffic totals. The main bar keeps decimal kB/s; detailed rates use KiB/MiB.
- Audio: sampled output name/ID, mute/volume state, nominal sample rate, I/O buffer
  frames, buffer duration and whether volume is writable. Buffer duration is
  `frames / sample rate`, not end-to-end audio latency. The live slider identifies
  its current output separately and rejects writes if that device changes.
- Battery: the existing state and percentage plus the OS time estimate when
  available. An unavailable estimate is not replaced with a guessed duration.

Collectors use Mach, sysctl, SystemConfiguration and CoreAudio locally. Polling
cadences are unchanged; no process-list scan, Internet reachability check or new
privacy permission is introduced.


Calendar events, remote research integration and new permissions are outside this
change. Research calculations, their priorities, Dock preferences and AeroSpace's
zero top gap are preserved.

## Build and reversible local application

Build only the bar when editing its Lua or native helpers:

```sh
python3 scripts/nix-safe.py build .#sketchybar-config --allow-warning \
  --gc-heap-mib 512 --out-link /tmp/sketchybar-config
python3 scripts/apply-sketchybar.py --dry-run /tmp/sketchybar-config
python3 scripts/apply-sketchybar.py /tmp/sketchybar-config
```

The bundle uses the same file renderer and notifier as Home Manager. Local
application creates registered Nix roots for each generation, saves a rollback
manifest, preserves the existing AeroSpace configuration except for its notifier,
and atomically replaces individual links before reloading the two configurations.
The bundle runs Lua regression fixtures during its build. Deployment waits for a
generation-specific health marker after all items initialize, rolling back if it
does not appear.
It does not activate the OS configuration or restart the Dock. Restore using the
printed manifest path:

```sh
python3 scripts/apply-sketchybar.py --restore /path/to/rollback.json
```

The standalone bundle uses the repository's default theme palette; full Home
Manager activation also honors host theme overrides. Keep old generations until
the replacement has passed real desktop checks.

## Verification scope

Run `bash scripts/check-desktop.sh`, build `.#sketchybar-config`, and run
`lua tests/sbarlua-lifetime.lua <directory-containing-sketchybar.so>` on macOS.
The normal full flake and Darwin configuration checks remain required for delivery.
Real sleep, lock/unlock and physical monitor reconnection require separate live
checks; simulated wake events do not establish those cases. A long soak is needed
to assess worker memory growth and rare failures.

The SketchyBar daemon was separately updated from 2.23.0 to the official 2.24.1,
retaining the previous binary for rollback. Native-client fixes are a separate
change from that daemon update.
