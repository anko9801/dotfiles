# Kanata - Cross-platform key remapper
# https://github.com/jtroo/kanata
#
# Single file managing all platforms:
#   - Home-manager: deploys config to ~/.config/kanata/
#   - NixOS: services.kanata
#   - Darwin: launchd.daemons
#   - Windows: manual install, config deployed by HM
#
# Usage:
#   Home-manager: imports = [ ./tools/kanata.nix ];
#   NixOS system: imports = [ (import ./tools/kanata.nix).nixosModule ];
#   Darwin system: imports = [ (import ./tools/kanata.nix).darwinModule ];
let
  # defcfg is separate because NixOS services.kanata generates its own
  defcfgBlock = ''
    (defcfg
      process-unmapped-keys yes
    )
  '';

  # Core config without defcfg (for NixOS which generates its own)
  coreConfig = ''
    ;; Kanata configuration
    ;; Key remappings for Japanese input and Vim-friendly editing
    ;;
    ;; Prefix layers (目的語):
    ;;   ctrl+q = Pane operations
    ;;   ctrl+t = Tab operations (handled by apps)
    ;;   ctrl+g = Shell operations (handled by apps)
    ;;   Space  = Vim leader (handled by vim)
    ;;
    ;; Verbs:
    ;;   h/j/k/l     = focus left/down/up/right
    ;;   H/J/K/L     = resize left/down/up/right
    ;;   |/-         = split vertical/horizontal
    ;;   x           = close
    ;;   z           = zoom/toggle
    ;;   n           = new

    (defsrc
      caps lmet rmet
      q h j k l
      min eql
      x z n
    )

    (defvar
      tap-timeout 200
      hold-timeout 200
    )

    (defalias
      ;; CapsLock: tap=Escape, hold=Ctrl (Vim-friendly)
      cap (tap-hold $tap-timeout $hold-timeout esc lctl)
      ;; Left Meta: tap=英数 (Eisuu/lang2), hold=Meta
      lm  (tap-hold $tap-timeout $hold-timeout lang2 lmet)
      ;; Right Meta: tap=かな (Kana/lang1), hold=Meta
      rm  (tap-hold $tap-timeout $hold-timeout lang1 rmet)

      ;; ctrl+q: activate pane layer for next key
      pane (tap-hold $tap-timeout $hold-timeout q (layer-while-held pane))
    )

    (deflayer default
      @cap @lm @rm
      @pane h j k l
      min eql
      x z n
    )

    ;; Pane operations layer (activated by ctrl+q)
    ;; Maps vim-style keys to Windows Terminal standard keybindings
    (deflayer pane
      _    _   _
      _
      ;; Focus: h/j/k/l → alt+arrow
      A-left A-down A-up A-right
      ;; Split: -/= → alt+shift+minus/plus
      A-S-min A-S-eql
      ;; Close/Zoom/New
      C-S-w A-S-z A-S-n
    )
  '';

  # Full config with defcfg (for Darwin, Windows, standalone)
  kanataConfig = defcfgBlock + coreConfig;
in
{
  # Home-manager module (default export)
  __functor = _: _args: {
    xdg.configFile."kanata/kanata.kbd".text = kanataConfig;
  };

  # NixOS system module
  nixosModule =
    {
      lib,
      config,
      ...
    }:
    let
      isDesktop = !(config.wsl.enable or false);
    in
    {
      config = lib.mkIf isDesktop {
        services.kanata = {
          enable = true;
          keyboards.default = {
            devices = [ ];
            extraDefCfg = "process-unmapped-keys yes";
            config = coreConfig;
          };
        };
      };
    };

  # Darwin system module
  darwinModule =
    { username, ... }:
    {
      launchd.daemons.kanata = {
        serviceConfig = {
          Label = "com.kanata.daemon";
          ProgramArguments = [
            "/opt/homebrew/bin/kanata"
            "-c"
            "/Users/${username}/.config/kanata/kanata.kbd"
          ];
          RunAtLoad = true;
          KeepAlive = true;
          StandardOutPath = "/tmp/kanata.out.log";
          StandardErrorPath = "/tmp/kanata.err.log";
        };
      };
    };

  # Raw config (for custom usage)
  inherit kanataConfig;
}
