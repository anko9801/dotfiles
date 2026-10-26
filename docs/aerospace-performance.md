# AeroSpace performance

Keep workspace navigation inside AeroSpace. SketchyBar receives workspace-change
events immediately, without synchronously enumerating windows on its event thread.
The `org.dotfiles.aerospace-events` user agent maintains a protocol-version-1
subscription to AeroSpace 0.21 or later. The workspace callback is empty, so
AeroSpace does not launch a shell during workspace transitions. The subscriber
coalesces buffered events and runs SketchyBar notifications in its own process.
It reconnects through launchd after connection loss; the initial event restores
the current workspace. Frame sizes, socket ownership, protocol and workspace
values are checked. Notification subprocesses have a two-second timeout.

Focus changes do not change workspace membership. A known application in the
focused workspace therefore does not need another all-window query. The check is
delayed briefly so an application notification arriving before its workspace
notification can use the final workspace.

Unknown applications, explicit window-move events, wake/reload, failed samples,
and periodic reconciliation still query AeroSpace. A routine or invalidation
cannot be suppressed by a coalesced known-application event. Failed queries clear
cached membership and display unknown state. Polling remains five seconds on AC
and ten seconds on battery; freshness expiry remains unchanged. A reported lost
event connection clears focus and membership; periodic queries remain as a fallback.

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
