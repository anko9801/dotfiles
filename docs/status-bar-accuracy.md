# Status bar accuracy

The current policy supersedes the earlier polling and clock descriptions in
[macOS performance](macos-performance.md). A failed or expired reading clears the
value instead of retaining a previously successful sample. Unknown values use
`—`; playback is hidden when the OS cannot provide a validated current track.
This bounds stale display, but does not guarantee that OS metadata is correct.

| Information | Primary update | Fallback / expiry |
| --- | --- | --- |
| Workspace focus | AeroSpace workspace event | 5 s AC / 10 s battery; 25 s expiry |
| Workspace applications | Focus, app and window events, batched for 100 ms | 5 / 10 s; 25 s expiry |
| Audio volume and mute | Native volume event; reread CoreAudio | 30 s; 65 s expiry |
| Battery and charging | Power-source change; reread `pmset` | 30 s; 65 s expiry |
| Interface, address and route | SystemConfiguration notifications trigger `network_change` | 10 / 30 s; 65 s expiry |
| Traffic rate | Two native interface-counter samples | 10 / 30 s, initial second sample after 1 s |
| CPU and memory | Native Mach counters | 5 / 15 s; 45 s expiry |
| Playback | Native media event; reread decoded OS JSON | 60 s; 125 s expiry |
| Clock | In-process local time snapshot | 1 s; unchanged text skips redraw |

All probes run asynchronously, with one request in flight and at most one
trailing request. A four-second timeout kills stalled process groups, with a
one-second termination grace period. Wake and relevant change events invalidate
older responses. Expiry also clears values if update events stop arriving.

The network watcher is a per-user LaunchAgent, declared alongside the helpers in
`desktop/sketchybar/default.nix`. It subscribes to global IPv4/IPv6 state and
interface IPv4/IPv6/link changes. It requires no location permission or root
service and coalesces related notifications for 100 ms. Periodic reconciliation
remains necessary for missed events, helper failures and continuous counters.

Traffic uses monotonic elapsed time and explicit decimal B/s, kB/s and MB/s.
A route change or counter reset starts a new measurement interval. The generic
network icon does not imply Wi-Fi or working Internet access. A missing default
route is labeled separately from an unreadable snapshot. Unsupported counters
remain unknown while verified interface details stay available.

Volume distinguishes mute, zero, and outputs whose volume the OS cannot read.
AC power does not imply active charging. Memory percentage is explicitly marked
as an estimate; pressure and swap are reported separately. CPU is normalized to
100% across all processors and describes the last sampled interval. Hover
popups show collection time and sampling scope. Playback strings use decoded
JSON, and generic music artwork avoids displaying a previous track's cover.

## Verification

Run from the repository root with Lua 5.4 or later:

```sh
lua tests/sketchybar-probe.lua
lua tests/sketchybar-widgets.lua
lua tests/sketchybar-spaces.lua
lua tests/sketchybar-refresh.lua
lua tests/sketchybar-calendar.lua
```

Fixtures cover stale responses, expiry, timeouts, malformed data, counter resets
and wrapping, workspace races, mute, unsupported audio, AC without charging,
escaped track names, clock adjustment and unchanged rendering. Native helpers
compile with `-Wall -Wextra -Werror`.

On 2026-10-25, the live bar was tested with a temporary failing probe, restored
in a `finally` block: numeric widgets cleared, workspace state became unknown,
and all recovered after restoration. A custom network trigger refreshed real
OS values. The timeout returned 124 after approximately four seconds. Audio,
battery, clock and workspace were checked against current OS readings. The
watcher was running with one launch. Physical disconnect/reconnect and cross-application
media transitions were not tested. A full Nix system build remains unverified
under elevated memory pressure; targeted module rendering and Nix lint passed.

Live-file backups are in `/private/tmp/bar-accuracy-live-backup-20261025`.
