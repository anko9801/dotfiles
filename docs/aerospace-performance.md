# AeroSpace performance

Keep workspace navigation inside AeroSpace. SketchyBar receives workspace-change
events immediately, without synchronously enumerating windows on its event thread.
AeroSpace's workspace callback starts a one-shot Lua notifier directly. SbarLua's
public `trigger` API sends the committed workspace through native Mach IPC; no
shell or SketchyBar CLI is started. The callback does not wait for child exit.

Callbacks include their kernel process-creation timestamp. The bar discards
notifications older than its own process, a newer accepted callback, or the
latest reconciliation request. This prevents a callback delayed by scheduling
from restoring old focus, including across reloads. Polling remains the fallback
when a notification is lost. The process timestamp and reconciliation cutoff both use the kernel
absolute-time clock.

Focus changes do not change workspace membership. A known application in the
focused workspace therefore does not need another all-window query. The check is
delayed briefly so an application notification arriving before its workspace
notification can use the final workspace.

Unknown applications, explicit window-move events, wake/reload, failed samples,
and periodic reconciliation still query AeroSpace. A routine or invalidation
cannot be suppressed by a coalesced known-application event. Failed queries clear
cached membership and display unknown state. Polling remains five seconds on AC
and ten seconds on battery; freshness expiry remains unchanged. A failed reconciliation clears focus and membership; periodic queries remain as a fallback.

The configuration uses `config-version = 2` and explicitly preserves the workspace
list in `desktop/workspaces.json`. Borders uses non-Retina drawing and native
focus detection (`hidpi=off`, `ax_focus=off`). Dock timings are unchanged.

## Measurements on 2026-10-26

The official Homebrew cask was updated from AeroSpace 0.20.3 to 0.21.3. The app and
CLI versions match. The old app, CLI, window assignments and local measurements
are retained under `/private/tmp/desktop-speed-20261026` on this Mac.

An initial comparison using the same target windows gave these command-response
medians, including CLI startup:

| Operation | 0.20.3 | 0.21.3 |
| --- | ---: | ---: |
| Workspace switch | 111.67 ms | 63.23 ms |
| Focus across workspaces | 168.05 ms | 128.54 ms |

This is a before/after observation, not a controlled version-only result. The
application was restarted, window classification changed, and concurrent load
varied. Recognized windows were restored to their recorded workspaces and
layouts. Steam helper windows and a native-fullscreen Zoom window initially
remained outside AeroSpace's managed list; their OS window IDs still existed.

Removing both borders and bar callbacks in an on/off/off/on comparison did not
eliminate stalls. Median focus-command times ranged from about 155 to 392 ms;
one command took 1.86 seconds. Because load and target applications varied, this
does not isolate a border-only cost.

The bar query optimization was checked with eight real Arc workspace switches
per condition and an instrumented query counter. Commands used AeroSpace's
[documented socket protocol](https://nikitabobko.github.io/AeroSpace/guide#socket-protocol),
excluding CLI process startup. Reversing the condition order gave:

| Order | Queries before / after | Median response before / after |
| --- | ---: | ---: |
| Before, after | 8 / 0 | 37.23 / 13.44 ms |
| After, before | 8 / 0 | 34.47 / 64.72 ms |

The query reduction reproduced; the latency improvement did not. Do not present
the first comparison as a reliable speedup or as key-to-visible-frame latency.
Long stalls under concurrent application load remain unresolved. Memory pressure
was at warning level during part of the investigation. No research jobs or
their priorities were changed.

One physical Alt+S observation gave 53.60 ms between the binding notification
and the focus-change notification. The key-down timestamp was not recorded;
this cannot establish input-to-handler latency or explain the user's remaining
delay before switching begins.

A subsequent 90-second observation received 24 shortcut/focus notification
pairs, including gaps of 716.31 and 675.84 ms. These are arrival intervals at the
observer, not server execution times: notification delivery and batching also
contribute. A separate sampling run showed waits in macOS accessibility and
application activation calls. It does not isolate the cause of each long gap.
Concurrent research compilations and simulations were active; load average
later approached 40 on the ten-core Mac.

The local configuration build and activation succeeded. Desktop regression
tests, Statix, deadnix, formatting and the live AeroSpace config check passed.
A full `nix flake check --impure` attempt was cancelled by the resource guard
when macOS memory pressure became critical. That attempt is not a pass. Complete
the required check on the CI review branch before advancing `master`.

The persistent subscriber was subsequently built and activated on this Mac.
An eight-switch before/after observation gave response medians of 203.42 and
102.09 ms, but maxima of 757.17 and 1499.48 ms. The experiment does not establish
a reliable reduction in long stalls. It removes process launching from the
workspace callback without changing research processes or their priorities.

The [upstream release notes](https://github.com/nikitabobko/AeroSpace/releases/tag/v0.21.3-Beta)
and [workspace callback implementation](https://github.com/nikitabobko/AeroSpace/blob/v0.21.3-Beta/Sources/AppBundle/focus.swift)
were inspected. `exec-on-workspace-change` does not wait for the launched process
to exit; replacing its shell alone would not remove an application-response wait.

## SketchyBar reflection follow-up

The persistent subscription was replaced after visible bar delays remained.
Upstream `broadcastEvent` schedules subscriber delivery as a main-actor task;
the workspace callback is launched directly at the committed model change. This
makes the callback the earlier available notification path during a busy refresh.
The native notifier also removes the subscriber's per-event SketchyBar process.

Concurrent native queries of `space.<id>` reproduced variable reflection times
with the direct callback: 59.70, 264.95, 340.85 and 451.30 ms in one four-target
run. These are request-to-observed-item-state times, including AeroSpace command
processing and query scheduling, not physical key-to-visible-frame latency. The
prototype also had a missed observation in an earlier run. Do not claim that
all desktop latency is eliminated or infer a controlled speedup from these runs.

Regression coverage includes reversed and duplicate callback delivery,
pre-reload callbacks, malformed timestamps, reconciliation ordering, and late
query responses. Research processes and Dock settings remain unchanged.
