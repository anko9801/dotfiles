# SketchyBar upstream research

<!-- cspell:ignore sbar appkit nsscreen -->

Research date: 2026-10-26 JST. Scope: proposals and evidence; no production
configuration, service, Dock, or research-process settings were changed.

Implementation follow-up: the user rejected hiding workspace application locations
and graphs or using custom popups. Those display proposals are superseded by
[the implemented stability and visible-layout policy](sketchybar-stability.md).

## Recommendation

Keep SketchyBar, SbarLua, and the working direct AeroSpace notification path.
The most valuable next work is native-client reliability, controlled version
maintenance, and a bounded layout. Additional widgets should follow these fixes.
There is no evidence that changing languages or installing a large theme will
solve the remaining latency.

The official optimization guidance favors batched changes, event-driven updates,
and compiled Mach helpers for sensitive paths. Much of that architecture is
already present here. [SketchyBar performance guidance](https://felixkratz.github.io/SketchyBar/config/tricks)

## Evidence categories

- **Verified locally:** files and installed package metadata inspected in this
  checkout; the isolated callback-retention experiment below.
- **Verified upstream source:** behavior visible in a specific source revision.
- **Upstream report:** a user's issue or proposed patch; useful evidence, not a
  reproduction on this Mac.
- **Proposal/inference:** a design choice or likely consequence that still needs
  acceptance tests. No speed percentage is established by this research.

## Versions and update scope

The local baseline reported by the main investigation is SketchyBar 2.23.0,
AeroSpace 0.21.3-Beta, macOS 26.5.1, Lua 5.5.0, and the Nix package
`lua5.5-sbarLua-0-unstable-2026-03-06`.

The installed SbarLua derivation points to the exact source revision
`dba9cc421b868c918d5c23c408544a28aadf2f2f`. This was read from its source
derivation, not inferred solely from the date in its package name.
[Exact SbarLua source](https://github.com/FelixKratz/SbarLua/tree/dba9cc421b868c918d5c23c408544a28aadf2f2f)

The official release page and formula currently offer 2.24.1. The formula uses
a tagged source archive with a checksum and an interactive launchd service.
An extra priority tweak is therefore not a substitute for fixing client-side
work or defects. [Release](https://github.com/FelixKratz/SketchyBar/releases/tag/v2.24.1),
[official formula](https://github.com/FelixKratz/homebrew-formulae/blob/master/sketchybar.rb)

Version 2.24.0 changed the rendering system. Version 2.24.1 includes menu-bar
height, window stacking, notch handling, and Mach send-timeout fixes. These are
reasons to evaluate an update, not proof that all updates are faster or safer.
[2.24.0 changes](https://github.com/FelixKratz/SketchyBar/releases/tag/v2.24.0),
[2.24.1 changes](https://github.com/FelixKratz/SketchyBar/releases/tag/v2.24.1)

## Priority 1: bound native IPC and avoid empty work

### The daemon upgrade does not update SbarLua's client implementation

SketchyBar PR 838 adds a five-second send timeout when a Mach port queue cannot
be drained. Its motivating report describes hung clients accumulating after a
wedged daemon. The patch merged on 2026-10-09 and is in 2.24.1.
[Upstream fix and reproduction](https://github.com/FelixKratz/SketchyBar/pull/838)

SbarLua separately embeds a Mach implementation. At the installed revision its
send uses `MACH_SEND_MSG` with `MACH_MSG_TIMEOUT_NONE`; its response receive has
a one-second timeout. Therefore a new SketchyBar executable alone does not add
a send deadline to the Lua plugin. This is a verified source-level failure mode,
not evidence that the current live bar has a full Mach queue.
[Pinned native client](https://github.com/FelixKratz/SbarLua/blob/dba9cc421b868c918d5c23c408544a28aadf2f2f/src/mach.h)

The current workspace notifier uses this native trigger without an outer
process timeout. The four-second `desktop-probe` timeout protects sampled
commands, not every native `sbar.set`, `query`, or `trigger` operation.
Local files: `desktop/aerospace.nix`, `desktop/aerospace-notify.lua`,
`desktop/sketchybar/default.nix`.

**Proposal:** review a small Nix-pinned SbarLua patch for bounded send and receive,
resource cleanup, and reconnect behavior. A bounded notifier wrapper is a
simpler fallback, but adds a supervising process and does not protect the
long-lived renderer's native calls. Keep the healthy path fast and test the
failed-daemon path in a separate bar instance.

### Empty callbacks still send a synchronous transaction

The pinned implementation automatically opens and commits a transaction for
callbacks, even when the callback queued no commands. Thus skipping unchanged
clock text avoids property changes, but does not eliminate every IPC round trip.
The same applies to invalidated expiry timers that return without changes.
[Pinned transaction implementation](https://github.com/FelixKratz/SbarLua/blob/dba9cc421b868c918d5c23c408544a28aadf2f2f/src/sketchybar.c)

SbarLua PR 62 proposes nested-transaction correctness, skipping empty sends, and
avoiding property-less `set` commands. It remained open when checked; it is not
an already released fix. Its interaction with `animate` and `query` needs tests.
[PR 62](https://github.com/FelixKratz/SbarLua/pull/62)

**Proposal:** validate this change in the same native-client reliability work.
Do not add nested `begin_config` blocks to every callback as a generic batching
optimization: callbacks are already batched, and the old nesting behavior is one
of the problems the PR addresses.

Remove the explicit startup update: SbarLua's event-loop entry already sends
`--update`, so the current initialization duplicates it.
[Pinned event-loop entry](https://github.com/FelixKratz/SbarLua/blob/dba9cc421b868c918d5c23c408544a28aadf2f2f/src/sketchybar.c)

## Priority 1: fix callback lifetime and missing completion recovery

### Callback retention was reproduced with the installed binary

At the pinned source, `exec` and `delay` store Lua registry references, and their
completion handlers do not release them. Upstream issue 66 and PR 67 discuss
callback, error-stack, and query-buffer lifetime. PR 67 remained open when
checked. [Issue 66](https://github.com/FelixKratz/SbarLua/issues/66),
[proposed fix](https://github.com/FelixKratz/SbarLua/pull/67)

A standalone process loaded the exact installed `sketchybar.so`, selected an
isolated bar name with no daemon, ran 100 timers, and performed two full Lua
collections. It reported:

```text
completed_timers=100 retained_function_delta=101
```

The delta includes the final measurement callback itself. It demonstrates
retention after the 100 ordinary callbacks completed. It does not measure the
live worker's RSS slope or prove that this retention caused the user's lag.
The small experiment never addressed the production bar.
Reproduction: `/private/tmp/sketchybar-upstream-research-20261026/native-reference-check.lua`.

This matters here because `helpers/probe.lua` creates an expiry timer after each
accepted sample or focus event; workspace activity and polling both contribute
callbacks. Merely forcing Lua garbage collection cannot free registry-rooted
closures.

**Proposal:** review the upstream lifetime fix, including shared subscription
references and error handling. Replace per-success expiry timers with a small
shared expiry scheduler where practical, using monotonic freshness deadlines.
Keep the existing clear-on-failure behavior. Do not adopt periodic restarts as
the permanent substitute for a lifetime fix.

### A helper may fail without invoking its callback

The native `exec` path can fail without delivering completion. The current probe
then leaves `running=true`, so later refreshes only mark `pending`. This is a
source-based recovery gap, not a live reproduced failure.
[Pinned execution path](https://github.com/FelixKratz/SbarLua/blob/dba9cc421b868c918d5c23c408544a28aadf2f2f/src/sketchybar.c),
[upstream failure-path discussion](https://github.com/FelixKratz/SbarLua/pull/67)

**Proposal:** attach an independent request generation and deadline to each
probe. Recover its state after a missing completion, reject late callbacks, and
retain a bound on subprocess overlap. Test the missing-callback case explicitly.
The external command's timeout alone does not prove that Lua receives completion.

Upstream issue 68 also reports signal termination being reported as exit code
zero because `WEXITSTATUS` is used without checking normal exit. Treat the
payload schema as part of success, which the current probes largely already do.
This research did not successfully reproduce the signal-status case locally.
[Issue 68](https://github.com/FelixKratz/SbarLua/issues/68)

### Freshness deadlines have a liveness condition

Expiry and rendering share one Lua run loop. A blocked or dead worker cannot
enforce nominal TTLs. Freshness limits are conditional on worker liveness;
worker-failure tests must observe this from outside that loop.
[Pinned run loop and callback paths](https://github.com/FelixKratz/SbarLua/blob/dba9cc421b868c918d5c23c408544a28aadf2f2f/src/sketchybar.c)

**Proposal:** prioritize bounded IPC and visible error reporting. Consider an
external health check only if a worker-death/freeze test shows recovery is still
needed. If introduced, validate sustained worker failure and restart only the
bar, with backoff and a restart cap. Never restart AeroSpace, WindowServer, or
research work as a generic recovery action.

## Priority 2: upgrade with a concrete regression matrix

The rendering overhaul has open upstream reports for wake/unlock stale item
windows on macOS 26.5.1 and an external-display click-blocking region in a
2.24.0 configuration. Their existence does not establish the behavior on this
Mac or whether every symptom persists in 2.24.1.
[Wake report](https://github.com/FelixKratz/SketchyBar/issues/866),
[external-display report](https://github.com/FelixKratz/SketchyBar/issues/845)

Test 2.24.1 with the existing minimal visual settings first. Retain the 2.23.0
binary, Lua plugin revision, and configuration generation for rollback. Keep
binary upgrades and visual redesign in separate changes so a failure is
attributable. Retest external screens at nonzero vertical offsets if used.

Required acceptance cases:

- Workspace switching by key, mouse, and application activation; rapid reversals.
- Bar reload, lock/unlock, sleep/wake, and external display disconnection/reconnection.
- Popups, clicking empty bar regions, and window focus preservation.
- Native fullscreen and presentation behavior; no new top gap or click barrier.
- Failure/recovery of helpers and of the Lua worker; no accumulation of clients.
- A long-running soak with native registry count, RSS, callback age, and log size.

## Priority 2: layout must stay inside a measured width budget

SketchyBar exposes fixed widths, character truncation, display associations,
positions next to the notch, and item geometry queries. It does not provide a
complete responsive information-priority policy for this configuration.
[Item properties](https://felixkratz.github.io/SketchyBar/config/items),
[display and geometry queries](https://felixkratz.github.io/SketchyBar/config/querying)

Use a narrow-screen profile: workspace/current status first, clock/power/audio
next, CPU and memory details in a compact popup, with capped media text. Keep
labels that are unknown explicitly unknown. The existing deduplicated app icons
and unchanged-render suppression should remain.

An upstream issue reports right-side overflow arithmetic; the 2.24.1 source
still contains unsigned cursors and the relevant subtraction. Avoid overflowing
rather than depending on clipping to handle arbitrary widget growth.
[Overflow report](https://github.com/FelixKratz/SketchyBar/issues/872),
[2.24.1 layout source](https://github.com/FelixKratz/SketchyBar/blob/v2.24.1/src/bar.c)

For multiple monitors, distinguish globally focused workspace from the workspace
visible on each monitor. AeroSpace 0.21.3's documentation supports visibility and
`monitor-appkit-nsscreen-screens-id`, specifically for tools such as SketchyBar.
Map these identifiers deliberately; do not equate unrelated monitor numbering.
[Versioned workspace documentation](https://github.com/nikitabobko/AeroSpace/blob/v0.21.3-Beta/docs/aerospace-list-workspaces.adoc)

The current single global highlight is a design choice, not necessarily a bug.
Per-display visible-state markers are useful only if multiple screens are part
of the actual workflow. `display_change` can trigger reconciliation; cached
AeroSpace state should still update without blocking normal focus notifications.
[SketchyBar events](https://felixkratz.github.io/SketchyBar/config/events)

## Priority 2: robust interactions and source semantics

The current popups often close on `mouse.exited.global`. An upstream report
reproduces missed global exit events through item/bracket windows on 2.24.0 and
macOS 27.0.1. That OS differs from this Mac. Give popups an explicit close/toggle
path and test item-to-popup pointer movement before relying on this report.
[Issue 864](https://github.com/FelixKratz/SketchyBar/issues/864),
[popup properties](https://felixkratz.github.io/SketchyBar/config/popups)

A separate report shows quoted text making native query responses invalid JSON.
Current code such as `volume:query().popup.drawing` assumes a table response.
Use cached interaction state, guarded reads, and a deliberate recovery path;
external strings must not turn a click into a Lua exception.
[Query serialization report](https://github.com/FelixKratz/SketchyBar/issues/869)

Official docs mark `media_change` deprecated on macOS 26 and `wifi_change` broken
since Sonoma. The repo already uses SystemConfiguration for network changes,
which should remain. Media correctness should be assessed against its current
provider; adding faster periodic polls cannot make stale OS metadata truthful.
[Event limitations](https://felixkratz.github.io/SketchyBar/config/events)

Animations use a step count equivalent to frames at 60 Hz. The current media
animation value 12 means roughly 0.2 seconds, not 12 seconds; one autogenerated
Context7 SbarLua reference mislabeled this unit. Preserve immediate workspace
selection and use short optional transitions only for secondary details.
[Authoritative animation units](https://felixkratz.github.io/SketchyBar/config/animations)

## What to retain and what to defer

Retain direct workspace notifications, process-start ordering, cached membership,
validated native metrics, unknown-state rendering, battery-aware polling, and
existing tests. SbarLua callbacks already batch property writes. Native `query`
is synchronous and can flush transactions; unnecessary queries should not be
introduced into hover or high-frequency focus paths.
[SbarLua README](https://github.com/FelixKratz/SbarLua),
[pinned query implementation](https://github.com/FelixKratz/SbarLua/blob/dba9cc421b868c918d5c23c408544a28aadf2f2f/src/sketchybar.c)

Defer GitHub/Slack/Discord unread counts, remote research-job polling, weather,
and rich album art until each has an authoritative source, failure policy,
privacy treatment, and a useful action. Such additions increase dependencies and
may display misleading or private information. This is a recommendation based
on the user's accuracy and responsiveness priorities, not an upstream mandate.

Do not lower research-process priority, change Dock timing, or restart unrelated
applications to improve benchmark numbers. Do not replace the working direct
callback with a subscriber merely to remove one fork: earlier repo measurements
and user feedback do not justify that regression risk.
