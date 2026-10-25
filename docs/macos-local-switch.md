# Local macOS builds and activation

Use the system Nix executable and build before activation. The CI configuration
was verified separately; the real interactive profile also needs its GUI files
and local activation permissions checked.

```sh
python3 scripts/nix-safe.py plan --timeout 240
python3 scripts/nix-safe.py build --out-link /tmp/dotfiles-system
```

The default guard requires normal memory pressure. If warning-level pressure is
acceptable for the current task, opt in explicitly:

```sh
python3 scripts/nix-safe.py build --allow-warning --gc-heap-mib 2048 \
  --timeout 1800 --out-link /tmp/dotfiles-system
```

Warning mode uses one build job and one requested core. It still stops on
critical or unreadable pressure, evaluator RSS above 2 GiB, or the time limit.
The GC heap cap controls the collector heap, not all process memory or
daemon-owned builders. The 1 GiB warning-mode default was insufficient for this
interactive profile; an explicit 2 GiB cap succeeded. Smaller heaps are not
necessarily faster: they can cause repeated garbage collection and allocation
failure. Version inspection is bounded to thirty seconds and fails closed.

Before activation, record `/run/current-system` and the system profile, preserve
manual configuration files, and inspect the exact generated `activate` script.
Use the already built system instead of evaluating the entire configuration as
root again. Activation requires administrator authentication.

```sh
system_config="$(readlink -f /tmp/dotfiles-system)"
sudo /nix/var/nix/profiles/default/bin/nix-env \
  -p /nix/var/nix/profiles/system --set "$system_config"
sudo "$system_config/sw/bin/darwin-rebuild" activate
```

For a preflight using `checkActivation=1`, invoke the generated script through
its Bash interpreter explicitly. Its `env -i` shebang otherwise removes the
flag. A preflight is not an activation or a success check for protected
preferences and package-manager operations.

## Compatibility and ownership

- Homebrew 5.0.12 could not parse current cask metadata. Only `nix-homebrew` and
  its nested `brew-src` input were updated, pinning Homebrew 7.0.4. Application
  upgrades remain disabled.
- Homebrew activation uses cleanup `none`; the generated command has
  `--no-upgrade` and no `--cleanup` or `--zap`. Unlisted packages stay installed.
- Homebrew 7 requires explicit trust for non-official formula definitions.
  Inspect the actual official repository and approve individual formula names;
  do not disable trust checks or trust entire taps merely to finish activation.
- Trust-file location depends on `XDG_CONFIG_HOME`. Activation uses a clean
  environment, so its Homebrew configuration location can differ from an
  interactive shell. Verify the context where `brew bundle` actually runs.
- `com.apple.universalaccess` is protected on this Mac. Direct `reduceMotion`
  writes were removed from Nix activation; the setting remains managed through
  macOS rather than requiring broader application permissions.
- A previously manual `/etc/kanata/start` must be compared with its backup and
  moved aside before nix-darwin can take ownership. The script now comes from
  an explicit Nix derivation so it is retained by the system closure.

## Measurements on 2026-10-25

With active research workloads and AC power, the successful plan took 30.48 s.
It reported 48 small derivations and 10.3 MiB to download. The first successful
local build took 134.27 s, including evaluation, downloads and generation.
Corrective incremental builds took 85.38 s and 59.59 s. These are measurements of
these revisions and cache state, not guaranteed durations for future builds.
Authentication waiting and earlier failed investigations are separate.

Build logs, timings, prior generations and desktop-file backups are under
`/private/tmp/mac-local-switch-20261025` on this machine.
