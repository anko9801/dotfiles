# SketchyBar improvement proposal

<!-- cspell:ignore nowplaying -->

Research date: 2026-10-26 JST. Scope: recommendations and isolated diagnostics;
no running configuration, service, Dock preference or research job was changed.
See [upstream evidence](sketchybar-upstream-research.md) for pinned source analysis.

Implementation follow-up: the user rejected hiding workspace application locations
and graphs or using custom popups. Those display proposals are superseded by
[the implemented stability and visible-layout policy](sketchybar-stability.md).

## Recommendation

Keep SketchyBar, AeroSpace, Lua and the existing Catppuccin Mocha theme. Work in
three stages: make the native client and probes recover reliably, simplify the
information hierarchy, then add calendar or research integrations selectively.
The recent direct workspace notification should remain the baseline.

Do not promise a universal latency improvement from a release update, fewer
widgets, or this research. Measure each change separately against the current
working setup. The user has already confirmed improved normal workspace tracking.

## Verified local baseline

Read-only checks on this Mac established:

- macOS 26.5.1, SketchyBar 2.23.0, AeroSpace client/server 0.21.3-Beta.
- One display, logical frame 1512 x 982 at the sampled instant.
- The running spaces, media, volume, network, calendar and metrics Lua sources
  match the repository. There are 59 registered items including hidden observers,
  popup entries and graphs; this is not 59 simultaneously visible widgets.
- Bar height is 32, background transparent, blur and shadow disabled, topmost off,
  fullscreen display off. The Homebrew LaunchAgent already uses Interactive mode.
- Workspace focus uses a direct native notification, callback creation timestamps,
  ordering checks and asynchronous reconciliation. Application membership is cached.
- Native metrics/network/audio readers, request coalescing, expiry, unknown values,
  battery-dependent polling and regression fixtures already exist.

Source: `desktop/aerospace.nix`, `desktop/sketchybar/`, live version/property queries.
The theme comes from `theme/catppuccin-mocha.nix`. Earlier performance notes are
historical; [accuracy policy](status-bar-accuracy.md) and the current source take
precedence over superseded polling descriptions.

## Ranked work

Effort is an engineering estimate including focused checks, not a completion-time
promise. Waiting for permissions, external hardware, or a long soak is additional.

| Priority | Change | Expected value | Effort / uncertainty |
| --- | --- | --- | --- |
| A1 | Harden the pinned SbarLua client | Bound IPC waits, release one-shot callbacks, skip empty transactions | Several hours; native changes need isolated and long-run tests |
| A2 | Add probe deadlines independent of callback delivery | Recover when an execution callback never arrives | 1-3 hours; request identities must reject late callbacks |
| A3 | Compare SketchyBar 2.24.1 with rollback | Evaluate rendering, window-stack and menu-height fixes | 1-2 hours plus wake/display checks; speedup unmeasured |
| B1 | Make display semantics precise | Avoid unsupported/read-error/external-device confusion | 1-2 hours; hardware coverage matters |
| B2 | Compact layout and stronger workspace selection | Stable click targets, clearer current workspace, less crowding | 2-4 hours; visual preference and width checks |
| B3 | Improve audio/media interactions | Finer volume control, stable media area, explicit command outcomes | Several hours; macOS media metadata remains a dependency |
| B4 | Add a health view and lighter preview/apply path | Explain failures and shorten safe iteration | Several hours; preserve Nix reproducibility and garbage-collection roots |
| C1 | Calendar popup and optional next appointment | Make the bar useful for time management | Several hours plus calendar authorization/sync verification |
| C2 | Research/build status from explicit receipts | Surface completion or required attention | Half a day or more; producer integration must exist first |
| C3 | External-display and presentation layouts | Preserve clarity when screen geometry/context changes | Several hours plus actual hardware checks |

### A1. Harden SbarLua separately from the daemon

The installed SbarLua is built from revision
`dba9cc421b868c918d5c23c408544a28aadf2f2f`. Its native send path has no send timeout;
its one-shot execution/timer callbacks retain Lua registry references; even
unchanged timer callbacks commit empty transactions. These mechanisms are verified
in the pinned source. An isolated test using the installed module completed 100
timers and retained 101 additional function references after two collections
(the extra function is the measurement callback). This proves retention in that
test, not that live-worker memory growth caused the user's lag.

Implement narrowly reviewed, pinned patches for bounded IPC, one-shot callback
cleanup, error-stack cleanup and empty transaction handling. Persistent event
subscriptions must keep their references. Treat open upstream patches as review
material, not as merged releases. Do not import a fork wholesale.
Sources: [pinned client](https://github.com/FelixKratz/SbarLua/blob/dba9cc421b868c918d5c23c408544a28aadf2f2f/src/sketchybar.c),
[pinned transport](https://github.com/FelixKratz/SbarLua/blob/dba9cc421b868c918d5c23c408544a28aadf2f2f/src/mach.h),
[transaction proposal](https://github.com/FelixKratz/SbarLua/pull/62),
[callback proposal](https://github.com/FelixKratz/SbarLua/pull/67).

A small configuration cleanup belongs in this stage too: `init.lua` explicitly
launches `sketchybar --update`, while the pinned native `event_loop` already sends
that command itself. Remove the redundant launch after checking startup/wake
initialization. Consolidating expiry scheduling can also reduce one-shot timer
creation without slowing correct update events. Neither change has a measured
live latency benefit yet.

### A2. Make probe recovery independent of a successful callback

`helpers/probe.lua` sets `running=true` until the execution callback runs. Expiry
clears a value, but does not clear that request state. If the callback never
arrives, subsequent refreshes only set `pending=true`. The shell timeout bounds a
normally launched command; it does not cover every failure in the native launcher.
This is a source-level failure mode, not an observed permanent stall of this bar.

Give requests identities and a deadline beyond the command's timeout/grace period.
On loss, mark data unknown and recover with bounded retry/backoff. Ignore callbacks
from retired requests. Prevent both a late callback clearing a newer request and
unbounded replacement children. Add a health entry for the last successful sample,
current request age and reason for unknown state.

Lua expiry timers also share the event loop with native IPC. They cannot execute
while that loop is blocked or after the worker dies. Bound IPC first; evaluate an
external health check only if a remaining failure requires it. Avoid adding an
extra permanent high-frequency polling service by default.

### A3. Evaluate the newer daemon with explicit rollback

The official latest release checked is 2.24.1; 2.24.0 changed the rendering system.
2.24.1 includes fixes for menu-height calculation, notch-only spacing, window stack
preservation on clicks and client send timeout. The installed daemon is 2.23.0.
These are reasons for a controlled comparison, not measured speed evidence.
The separate SbarLua transport is not fixed merely by upgrading the daemon.
Sources: [2.24.0](https://github.com/FelixKratz/SketchyBar/releases/tag/v2.24.0),
[2.24.1](https://github.com/FelixKratz/SketchyBar/releases/tag/v2.24.1).

Save the old binary and bar configuration, update only SketchyBar, and compare
workspace tracking, click focus, reload, sleep/wake, fullscreen and display changes.
Keep AeroSpace's top gap at zero. A rendering overhaul deserves an acceptance
check before it becomes the default; open issue reports are risk indicators,
not proof of a failure on this Mac.

### B1. State only what the data establishes

Keep existing unknown-state handling. Tighten these distinctions:

| Current source behavior | Proposed behavior |
| --- | --- |
| Missing audio volume becomes "external" and "cannot read/adjust" | Separate unsupported property, read error, and confirmed non-settable output |
| Audio helper reads values but does not query whether they are writable | Query capability before offering a slider; verify the result of writes |
| Memory main label is an estimated percentage | Prefer memory pressure for attention; keep estimate and swap in details |
| Network icon reflects interface/address information | Preserve the distinction between route/address availability and Internet reachability |
| Details timestamp is formatted when a result is applied | Include sampling scope and age; do not imply continuous or instantaneous measurements |

The read-only audio helper cannot establish write capability. Apple provides a
separate [property-settable query](https://developer.apple.com/documentation/coreaudio/audioobjectispropertysettable(_:_:_:)).
Do not add repeated Internet probes merely to display a stronger connectivity icon.

### B2. Use a compact, stable information hierarchy

Proposed normal layout (conceptual, not a screenshot):

```text
[occupied workspaces; selected emphasized] [current app]    [media] [volume] [NET] [power] [date/time]
```

- Keep occupied workspaces and the selected empty workspace. Give selection a
  clear shape/border in addition to color. Current icon/highlight colors are equal;
  selection depends mainly on the background color.
- Bound application labels/icons per workspace and expose the complete list on
  deliberate interaction. Unknown application names currently have no explicit
  length bound in the workspace renderer. Preserve the full keyboard mapping.
- Keep the selected workspace's applications prominent; make other workspaces
  compact when necessary. Do not show all 30 configured keys as empty placeholders.
- Move network throughput and CPU/memory graphs into an on-demand detail view.
  The configured network label alone is 145 points; each graph is 42 points before
  surrounding padding. This is a layout budget, not an observed latency saving.
- Show a clear pressure warning when needed; high CPU from intentional scientific
  work should not automatically be presented as a system fault.
- Use stable widths for frequently clicked controls. Stop automatic song-change
  expansion by default; show title/artist on hover or click. Disable marquee text
  on the main bar while allowing full text in details.
- Keep the current palette. Use opaque/local chip backgrounds where needed for
  predictable legibility; wallpaper contrast has not been visually assessed.

Fixed widths, text truncation, notch-side placement, display association and
[on-demand popups](https://felixkratz.github.io/SketchyBar/config/popups) are native
features; an additional UI framework is unnecessary.
[Item properties](https://felixkratz.github.io/SketchyBar/config/items).

### B3. Make audio and media controls predictable

Volume scroll currently multiplies ordinary deltas by ten and launches AppleScript
for each event. Propose smaller increments, bounded/coalesced rapid input, explicit
mute control and consistent verification after changing output devices. Preserve
unknown state when the OS cannot verify a value. A native CoreAudio setter is an
option if it materially reduces launches; it must use the same device/capability
model as the reader.

Media currently depends on `nowplaying-cli` plus `media_change`, a 60-second
fallback and 125-second expiry. Official event documentation deprecates
`media_change` on macOS 26.0; `nowplaying-cli` itself warns that its private
frameworks can break across OS updates. This does not establish that either is
broken on this Mac. Test Spotify/other player changes and wake behavior before
choosing a source-specific event or adaptive fallback. Never treat valid JSON as
proof that the OS selected the intended player.
Sources: [events](https://felixkratz.github.io/SketchyBar/config/events),
[nowplaying-cli](https://github.com/kirtan-shah/nowplaying-cli).

Command failures should be visible in the detail view and followed by verified
state retrieval; current media controls discard stderr. Default to a stable compact media
button, with bounded title text in its popup. Avoid a playback progress timer until
accurate elapsed-time metadata and the user's need justify the extra activity.

### B4. Improve diagnosis and configuration iteration

Expose a deliberately opened health view with source versions, last update age,
probe failures and a bar-only reload action. Aggregate repeated errors instead of
spamming logs. A successful process exit alone is insufficient if data validation
fails. Do not kill WindowServer, AeroSpace, or scientific processes for recovery.

Consider extracting a small `sketchybar-config` Nix output containing the rendered
Lua/bootstrap/helpers and consuming it from Home Manager. It should build without
forcing unrelated editor/system configuration, validate before replacing files,
retain a rollback generation and register store roots. No implementation exists
for this proposed output yet. Keep compiled helpers/versioned Lua reproducible;
do not use untracked live files as the permanent deployment mechanism.

### C1-C3. Add useful context after the foundation is stable

**Calendar:** a month popup is a low-permission addition. A next-appointment field
could show start time/countdown; expose titles only on demand or outside a manually
selected presentation layout. Confirm Google Calendar is synchronized into the
chosen source. EventKit requires full calendar access even for read-only behavior;
it does not offer a read-only permission. Permission refusal must leave the date
and clock functional. [Apple EventKit access](https://developer.apple.com/documentation/eventkit/accessing-the-event-store).

**Research/build status:** read an explicit local receipt written atomically by
an opted-in workflow. Require producer identity, task identifier, state, timestamp
and expiry. Display running, completed and awaiting review, failed, or unknown. Never
infer numerical progress, completion or a scientific result from process count,
CPU load, or the existence of a checkpoint. Avoid frequent SSH/API polling from the
bar. Existing workflow integration would need to be designed and verified first.

**Displays/presentation:** only one display was connected during this audit. For
future multiple-display use, distinguish globally keyboard-focused workspace from
each monitor's visible workspace. A compact overflow layout should drop low-priority
fields before workspace selection or clock. Make a presentation layout explicit
and manual until a dependable context signal is available. Keep native macOS
privacy indicators; do not recreate security state from guesses.

## Concrete implementation boundaries

| Concern | Main implementation locations |
| --- | --- |
| Shared native client fixes | A small shared SbarLua derivation and reviewed patches under `desktop/sketchybar/`; consume the same build from `desktop/aerospace.nix` and `desktop/sketchybar/default.nix` |
| Request recovery and freshness | `desktop/sketchybar/helpers/probe.lua`, `tests/sketchybar-probe.lua` |
| Startup duplicate update | `desktop/sketchybar/init.lua`; verify the native library still initializes observers |
| Bounded workspace layout | `desktop/sketchybar/items/spaces.lua`, `settings.lua`, and layout fixtures; retain `desktop/workspaces.json` as the shared order |
| Compact diagnostics/media | `items/cpu.lua`, `memory.lua`, `metrics.lua`, `wifi.lua`, `media.lua` |
| Truthful audio controls | `helpers/audio.c`, `items/volume.lua`, and hardware-independent fixtures |
| Lighter build/preview | `desktop/sketchybar/default.nix` and a small flake package output, keeping Home Manager as the owner of persistent configuration |

Do not combine daemon upgrade, native-client patches, layout redesign and new
integrations into a single unmeasurable rollout. Implement and validate one
boundary at a time. No change to Dock timing or AeroSpace gap reservation is part
of this plan.

## Acceptance plan for implementation

1. Native isolated tests: bounded sends/receives, daemon absent/full queue, one-shot
   reference release, no-op transaction count, callback errors and nested calls.
   Persistent subscriptions must continue working.
2. Probe fixtures: missing callback, late callback after retirement, repeated faults,
   recovery, invalid data, stale query results and bounded retry/child count.
3. Bar checks: real workspace tracking, selected-empty workspace, long/unknown app
   names, narrow-width overflow, volume/mute/device changes, player transitions,
   popup dismissal, permission denial, reload and sleep/wake.
4. Measure separately: event-to-observed-item state and physical key-to-visible
   changes. Warm the observer and initial bar state; do not include observer launch
   in the first sample. Compare both condition orders, retain outliers and report
   percentiles. Keep research jobs and priorities unchanged; record load as context.
5. Run a long soak after targeted checks. Compare retained callbacks and worker
   memory over time; do not call an improvement proven from one idle CPU snapshot.

No additional widget, automatic restart, permission request or software update was
performed as part of this proposal. Next implementation should start with A1/A2
and a rollback-capable A3 comparison, followed by B1/B2.
