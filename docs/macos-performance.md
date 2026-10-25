# macOS performance

Use `/usr/bin/python3 scripts/nix-safe.py plan` from the repository root before
building. It previews `darwinConfigurations.mac-arm.system` without activation.
Use `build` instead of `plan` only after reviewing the preview. Both commands
refuse to start under macOS memory pressure, cancel on pressure increases, and
limit Nix to one build with two requested cores. The evaluator is monitored at
0.5-second intervals with a 2 GiB RSS threshold and a wall time limit. These are
best-effort safeguards, not a hard memory limit on daemon-owned builders.

`nix run .#switch` also checks memory pressure inside the switch app, bounds build
parallelism, and resolves nix-darwin from this repository's inputs. The initial
evaluation needed to launch a flake app happens before its shell guard; prefer
the standalone script on a busy Mac. Do not run a full flake check or update all
inputs merely to edit a SketchyBar Lua file.

## Resource configuration

On this Mac, Determinate owns `/etc/nix/nix.conf`; nix-darwin has `nix.enable =
false`. Home Manager's `nix.settings` only configures user clients. Shared
settings in `config.nix` do not automatically configure the macOS daemon.

`system/darwin/nix-limits.sh` preserves existing custom settings and maintains a
marked block in `/etc/nix/nix.custom.conf`: one build, two requested cores, four
substitutions, and one evaluation core. Activation runs the script. To apply
without building, run `sudo /bin/bash system/darwin/nix-limits.sh`; restart
`system/systems.determinate.nix-daemon` only when no Nix builds are active.
The previous custom file is saved as `nix.custom.conf.before-dotfiles-limits`.

Home Manager mirrors build limits and configured binary caches in the user
configuration. It does not install another upstream Nix CLI on macOS; the
installer's `/nix/var/nix/profiles/default/bin/nix` should own the CLI and daemon.

## Measurements on 2026-10-25

The 16 GiB / 10-core Mac had about 12.9 GiB swap in use and 5.3 GiB compressed
memory at the first sample. Memory pressure later reached warning level 2.
The Codex renderer's physical footprint was about 4.9 GiB. Research Python jobs
were active and were deliberately left running. Startup uptime was 125 days;
large swap use alone does not prove that current swap traffic is high.

SketchyBar queried AeroSpace synchronously once per each of 30 workspaces.
Three runs took 1571.4, 1405.9, and 1590.7 ms. A single all-window query took
30.6, 35.0, and 31.8 ms. The replacement uses asynchronous queries, one observer,
and one trailing refresh for overlapping events. After reload, synthetic bar
event-to-highlight latency including CLI polling was 36.0–46.8 ms (median
42.5 ms). This measures the bar; actual keyboard-to-window motion latency was
not measured. No actual windows or workspaces were moved for this test.

The installed bootstrap also paired Lua 5.4 with a SbarLua module installed under
`lib/lua/5.5`. Matching Lua 5.5 and the module's versioned path fixed module
loading before the bar was reloaded.

SkyComputerUseService consumed roughly one CPU core; its sample repeatedly
entered Core Foundation run-loop handling on a window-bounds observer thread.
After the user authorized a restart, the new process sampled at 0% CPU. This
establishes the immediate reduction, not a permanent fix inside the application.
Steam's main application and heavy helper processes exited after the authorized
normal quit attempt; a 0%-CPU ipcserver remained at the final check.

The effective Nix settings initially allowed 10 builds, each requesting all 10
cores. This permits severe oversubscription when builders respect the core
setting. It does not establish that 100 compiler processes caused a historical
crash. A guarded dry-run was cancelled when memory pressure rose; no full build
or configuration activation was performed for validation.

Daemon limits were subsequently written to the custom configuration, the idle
Determinate daemon was restarted, and the effective values were verified as
`max-jobs=1`, `cores=2`, `max-substitution-jobs=4`, `eval-cores=1`. AC low-power
mode was disabled; battery low-power mode remains enabled. Existing binary
caches declared in the repository were applied to the user configuration.

The user reported some improvement but continued lag. Under increasing research
load, AeroSpace read-command medians rose to about 81–131 ms, and load average
later exceeded 30. A four-transition comparison gave median command completion
times of 292 ms with borders and 173 ms without them, but an alternating HiDPI
comparison was inconsistent. No reliable drawing-speed conclusion follows from
these noisy samples. HiDPI off reduced the borders process footprint from about
298 MiB to 136 MiB; its original setting was retained because a speed benefit
was not established. All test workspace switches were restored afterward.

A later process-footprint sum reported roughly 10 GiB across Codex-related
processes, 2.9 GiB across Python processes, and 757 MiB across 80 node_repl
processes. These sums include shared memory and compressed footprint and are
not unique resident RAM. The user chose to retain research calculation speed;
neither calculations nor their scheduling priority were changed. Remaining
system-wide lag is unresolved under this concurrent workload.

## Operating policy

Keep Nix for reproducible project environments, shared CLI configuration, and
Linux/NixOS hosts. Keep macOS GUI applications and window-manager binaries in
Homebrew, as this repository already does. Nix remains useful; broad dependency
updates and source builds on a memory-constrained interactive Mac are the
expensive part of this setup. If guarded evaluation remains costly after memory
pressure is resolved, simplify global modules before replacing the whole tool.

Avoid restarting the desktop, killing WindowServer, or closing research jobs
without coordinating with their owners. Reopening a bloated renderer or logging
out can reclaim memory, but should wait until active work is safe to interrupt.

## Shell and tool audit

A follow-up audit covered mise, Zsh/Fish, Starship, Git, language configuration,
Homebrew activation, AI/editor packages, and user LaunchAgents. The installed
mise was 2026.4.20. No runtime versions were upgraded or removed for this audit.
The `node`, Python, and other installed runtime selections were retained.

Changes applied to the current user's files, with backups under
`/private/tmp/mac-shell-performance-20261025-154710`:

- Fish uses Home Manager's mise activation once; the duplicate manual activation
  was removed. uv completions are loaded when completion is first requested.
- Zsh records its last successful completion security audit separately from the
  completion dump. The old September dump caused a full check on every startup
  because checking unchanged completions did not refresh its modification time.
  Cached startup now skips the audit for 24 hours; missing dumps and expired
  audit stamps trigger a full check.
- Candidate previews for Nix/build/install/cloud tools show candidate names.
  Merely selecting a completion no longer runs Nix evaluation, remote package
  searches, `make -n`, Kubernetes requests, or Terraform provider processes.
  File, Git, local package metadata, and script previews remain available.
- On macOS, mise implicit installation is disabled. Use explicit `mise install`
  or `mise use` when adding a runtime. mise task concurrency remains four.
- New Zsh/Fish sessions use two Julia precompile tasks instead of 28. This
  changes package precompilation, not `JULIA_NUM_THREADS` or active calculations.
- `plugupdate` checks macOS memory pressure before updating Nix inputs and again
  before mise upgrades. mise upgrades use two install jobs. The dotfiles path
  comes from the Nix host's configured checkout, and the incorrect Lazy.nvim
  updater was removed: this configuration uses Nixvim and lz-n.

Homebrew `onActivation.autoUpdate` and `upgrade` are now false in the source.
This change takes effect on the next configuration activation; no full Nix
activation was attempted just to install it. Existing explicitly staged
Homebrew application additions were preserved.

Measured from the repository root, with auto-installation and network access
disabled for mise in both runs:

| Command | Before median (3 runs) | After median (5 runs) |
| --- | ---: | ---: |
| `zsh -lic ':'` | 202.2 ms | 172.4 ms |
| Zsh plus deferred tool initialization | 412.9 ms | 307.7 ms |
| `fish -ic exit` | 556.0 ms | 316.8 ms |

These command-launch measurements are not direct terminal-display latency and
were taken while research calculations continued. Starship alone measured
roughly 60–75 ms; its configuration was retained. Node's 4096 MiB heap setting
is a per-process ceiling, not a preallocated memory reservation, so it was not
treated as an explanation for the system's aggregate memory use.

The audit found no additional high-CPU mise/Ollama/window-manager process at
the sampled idle instant. A Linux-builder LaunchAgent definition exists but
was not loaded in the user domain; the system still has a Linux-builder entry
in `/etc/nix/machines`. Root SSH configuration and actual remote-builder
availability were not verified, so the builder configuration was retained.

Verification used real Zsh completion initialization with an expired dump and
audit stamp, completion-preview assertions, Fish uv completion and runtime
selection checks, targeted Nix expression evaluation, Statix/deadnix, formatting,
and shell syntax checks. No research processes or priorities were changed.

## Desktop follow-up on 2026-10-25

CPU and memory widgets share a five-second asynchronous sample from
`desktop/sketchybar/helpers/metrics.c`. The helper reads Mach counters directly;
it does not enumerate processes or launch monitoring tools. CPU percentage is
the busy tick delta divided by the total tick delta, with 32-bit wrap handling.
Memory percentage approximates physical use from non-purgeable internal, wired,
and compressed pages. Warning colors use the OS memory-pressure level, rather
than treating high usage as pressure. Hovering over memory shows pressure and
swap. Failed samples preserve the previous display; unavailable values are
reported as unknown.

Eight launches per command, measured with Python's monotonic timer while the
desktop was active, gave these medians:

| Retrieval | Median |
| --- | ---: |
| Previous process-list CPU query | 38.57 ms |
| Previous memory-pressure query | 11.08 ms |
| New combined native sample | 4.07 ms |

The native sample ranged from 3.24 to 200.17 ms, so scheduling outliers remain.
The independent CPU/memory query cadence falls from 32 to 12 launches per minute.
These measurements do not establish keyboard or window-drawing latency.

Workspace order now lives in `desktop/workspaces.json` and generates both the
AeroSpace bindings and SketchyBar order. Focus changes update the old and new
items; unchanged window lists produce no redundant item updates. Moving a window
with a configured workspace binding triggers an immediate bar refresh. Wake and
reload queries cannot overwrite a newer workspace event. The top gap remains
zero: reserving 36 pixels for the bar created unwanted space above windows and
was reverted after user feedback.

Additional bindings: `alt-tab` returns to the previous workspace; `alt-/` cycles
tile orientation; `alt-,` cycles accordion orientation. In service mode
(`alt-shift-;`), `c` reloads AeroSpace and SketchyBar.

Network speed uses the macOS primary network interface, with IPv6 primary
information as a fallback, instead of assuming `en0`. Interface or counter
changes reset the speed baseline.
The popup identifies the interface; it does not claim to display a Wi-Fi SSID.
Volume initializes after reload and discards stale device-popup responses.
Shell quoting preserves literal network and audio-device names. Repeated media
events no longer queue duplicate animations, and old track timers cannot collapse
a newer track or a hovered item.

Dock reveal duration is 0.15 seconds and Mission Control duration is 0.1 seconds.
Native edge/Option tiling, Stage Manager, wallpaper-click desktop reveal, and
automatic window animations are disabled in the managed configuration. These
preferences were written and the Dock was restarted. The managed
`universalaccess.reduceMotion` preference was refused by macOS; it was not
successfully applied or verified through the UI.

The desktop files were applied separately from a full Nix activation. Their
backup, including original symlink targets and changed preference values, is in
`/private/tmp/dotfiles-desktop-backup-20261025`. The helper was compiled with the
installed Clang; its Nix derivation and the complete system were not built.
Targeted module rendering, Lua syntax and asynchronous regression tests,
Statix/deadnix, shell checks, and AeroSpace's live configuration dry-run passed.
Live CPU, memory, pressure/swap, volume, and network labels updated after reload.
At that check memory pressure was still warning level 2 with about 11.3 GiB swap;
system-wide responsiveness under that load remains unqualified.

## Background services and battery follow-up

Kanata's system LaunchDaemon was failing approximately every ten seconds. A
12-second observation recorded another launch; its cumulative count was about
267,000 and its two logs occupied about 160 MiB. Configuration validation passed.
The actual error was an unavailable Karabiner virtual HID driver, and
`systemextensionsctl list` reported that extension as activated but waiting for
user approval. The full driver was not enabled to resolve this startup issue.

`desktop/kanata-start.sh` now checks that the driver is both enabled and active
before invoking Kanata. Missing prerequisites or invalid configuration exit
successfully so launchd does not treat them as crashes. A five-minute interval
rechecks prerequisites, and unexpected runtime failures have a 60-second restart
throttle. Existing key mappings and native Caps Lock remapping were retained.
These settings were installed through macOS administrator authentication; the
previous daemon plist is in
`/private/tmp/kanata-desktop-fix-20261025/backup`. After application, another
12-second observation found the launch count and log sizes unchanged. This
verifies that the previous fast loop stopped, not that the keyboard driver works.
At that point, Kanata still awaited driver approval before it could remap keys.

`desktop-network` reads primary interface information through SystemConfiguration
and 64-bit interface counters through sysctl. The shell snapshot remains as a
fallback when the helper is absent. Ten launches of each implementation gave
median retrieval times of 20.73 ms for the shell implementation and 7.84 ms for
the native helper; ranges were 19.80–22.48 and 7.55–29.56 ms respectively. On the
current connection, interface, address, and router matched the shell snapshot.
Other physical network configurations were not switched for this check.

Battery state now initializes on reload. On battery, CPU/memory sampling changes
from five to fifteen seconds, network sampling from ten to thirty seconds, and
the workspace fallback poll from thirty to sixty seconds. Workspace and network
events still trigger updates. Returning to AC restores the original cadence.
Battery transition behavior was verified with event fixtures; a physical
disconnect/reconnect test was not performed. The live battery cadence of 15/30/60 seconds
and battery/network labels were verified after reload. User-file backups are in
`/private/tmp/dotfiles-desktop-power-backup-20261025`.

Verification covered startup fixtures for missing/unapproved drivers, failed
extension checks, invalid configuration, and unexpected runtime exits; actual
Kanata configuration validation; Lua widget regressions; C compilation with
warnings as errors; shell checks; and targeted Nix rendering/linting. A complete
Nix system build remains unverified while memory pressure is elevated.

## Kanata activation and keyboard verification

The user subsequently authorized driver activation, Input Monitoring, and
Accessibility access. The Karabiner extension was enabled through System
Settings, and the installed Kanata executable was added to both privacy lists.
Both switches were observed on. The installed Kanata 1.11.0 client and
VirtualHIDDevice 6.8.0 package both use client protocol 5; no package upgrade or
downgrade was needed for this activation.

The vendor's virtual HID output daemon was also required. It is now registered
as `org.pqrs.service.daemon.Karabiner-VirtualHIDDevice-Daemon`, with its startup
configuration declared in `desktop/kanata.nix`. The Kanata startup guard checks
that this service is running before starting input capture. After restarting
Kanata with the granted permissions, the log reported a connected driver and
matching version. The two earlier keyboard-open permission errors did not
increase during the final check. Both services remained running.

The macOS mapping is now in `desktop/kanata-macos.kbd`: Caps Lock is Escape on
tap and Control on hold; left/right Command tap selects Eisu/Kana, while a chord
activates Command immediately. Ordinary letters and application prefixes pass
through unchanged. The previous macOS mapping intercepted plain Q with a
tap/hold pane layer despite describing it as a Ctrl-Q shortcut. Linux and
Windows retain their previous mappings.

The user confirmed normal operation after checking physical Caps Lock, left/right
Command taps, and Command-Tab. Generated configurations parse for
all three platforms, and the startup regression tests and targeted Nix/shell
checks passed. Startup after a complete macOS reboot was not tested.

The previous keyboard file and activation artifacts are in
`/private/tmp/kanata-enabled-backup-20261025`. The user completed authentication
through macOS; no authentication secret was collected or stored in this repo.

## Event batching and clock follow-up

Related workspace, application-focus, and window-list events now share a
100-millisecond refresh window. Focus highlighting remains immediate, while
application icons may follow up to about 100 milliseconds later plus query time.
The existing one-query-at-a-time and trailing-query behavior is retained, and
wake/reload invalidates an older scheduled refresh. A fixture delivering 60
related events required two AeroSpace queries before this change and one after
it; this is a query-count check, not a keyboard-latency measurement.

The calendar uses one timer scheduled near the next minute boundary instead of
polling every 30 seconds. It skips unchanged text and replaces its timer chain
after wake or a forced update. The system clock API used here has whole-second
precision; scheduling delays can still postpone a displayed update. The live
bar advanced from 18:03 to 18:04 and matched the OS clock at the subsequent check.
Tests cover minute alignment, midnight, duplicate timers, wake, and unchanged
text, together with the workspace and other widget regressions.

Only the two Lua files were applied, with backups under
`/private/tmp/desktop-refresh-before-20261025/runtime`. Kanata and the AeroSpace
top gap were retained. Exactly one persistent SketchyBar Lua worker was found;
a briefly observed second process had already exited on recheck.

A guarded Nix build-plan attempt began at normal memory pressure but cancelled
when pressure rose above normal. It did not activate the system configuration;
full-system build validation remains incomplete.

References: [Nix jobs and cores](https://nix.dev/manual/nix/2.34/advanced-topics/cores-vs-jobs.html),
[Determinate configuration](https://docs.determinate.systems/determinate-nix/),
[SbarLua asynchronous execution](https://github.com/FelixKratz/SbarLua#important-remarks).
See also [mise activation and shims](https://mise.jdx.dev/dev-tools/shims.html),
[mise settings](https://mise.jdx.dev/configuration/settings.html), and
[Julia environment variables](https://docs.julialang.org/en/v1/manual/environment-variables/#JULIA_NUM_PRECOMPILE_TASKS).
Driver requirements: [Kanata macOS setup](https://github.com/jtroo/kanata/blob/main/docs/setup-macos.md).

## Accuracy follow-up

The [status bar accuracy policy](status-bar-accuracy.md) supersedes earlier
clock cadence, stale-value retention and workspace fallback descriptions above.
It records event triggers, bounded unknown states and live failure/recovery
verification. The AeroSpace top gap remains zero and Kanata was not changed.

## Desktop startup and screenshot follow-up

A follow-up audit found one user LaunchAgent pointing to a nonexistent app:
`com.lwouis.alt-tab-macos` referenced the removed `/Applications/AltTab.app`.
It was loaded with exit status 78 and `spawn scheduled`, but only one launch was
reported; repeated crashes or a measurable CPU cost were not established. The
service was unloaded and its plist archived rather than deleted. The unrelated,
unloaded Linux-builder registration was retained.

The screenshot preference pointed to `~/Pictures/Screenshots`, but that directory
did not exist. It was created, checked for write access, and the preference now
uses its absolute path. The configured Home Manager home directory supplies the
same path for both the system preference and a dry-run-aware activation step,
so future activations create the directory before use. No existing desktop files
were moved. A screenshot keyboard shortcut was not exercised.

Backups of the screenshot preferences and the AltTab plist are in
`/private/tmp/desktop-qol-20261025`. Restore the latter to
`~/Library/LaunchAgents` only after reinstalling AltTab, then bootstrap it with
`launchctl` if wanted. Restore screenshot preferences with `defaults import
com.apple.screencapture /private/tmp/desktop-qol-20261025/screencapture.plist`.

At the sampled instant, the network watcher, AeroSpace, borders and Raycast
reported 0% CPU, while the memory-pressure level was normal. These point samples
are not before/after performance benchmarks. Research calculations remained
running and their priorities were not changed. Discord helper processes showed
CPU activity; its settings review stopped at an approval boundary before any
Discord preferences were changed. No desktop, Dock or research process was
restarted for this follow-up.

## Build and push validation

Run `bash scripts/check-desktop.sh` for the isolated desktop/shell regression
suite. The macOS build workflow runs it through the CI development shell before
building the system. It exercises the resource guard, keyboard startup, shell
completion and bar update contracts without grabbing keyboard input.

Use `python3 scripts/nix-safe.py check` for `nix flake check --impure` with the
same pressure, RSS and time safeguards as a build. No checks are disabled. The
Nix process defaults to a 64 MiB initial garbage-collector heap instead of the
upstream 384 MiB default; garbage collection can take longer. This is an initial
heap size, not a hard allocation cap. Existing explicit environment overrides
are preserved. Warning-level system pressure still prevents the command from
starting. CI is the full-system validation path while this Mac is busy.

The [local build and activation follow-up](macos-local-switch.md) records the
measured native build times, explicit warning-pressure mode, Homebrew API
compatibility and protected-preference handling. It supersedes the earlier
statement that no local system build had been completed.
