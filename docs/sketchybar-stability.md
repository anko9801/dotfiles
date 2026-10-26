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

The menu helper launches only on click and exits after dismissal. Its application
is an accessory, with no Dock icon or independent work window. A per-user lock
prevents simultaneous helpers. A temporary invisible status anchor is removed on
close. Activity Monitor and settings are optional explicit detail actions, rather
than the primary click behavior. Media keeps its direct play/pause action.
Unreadable volume remains unknown rather than being labeled as an external device.


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
