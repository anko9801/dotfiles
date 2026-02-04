# Kanata - Cross-platform key remapper for NixOS
# https://github.com/jtroo/kanata
# Uses NixOS built-in services.kanata module
# Note: Does NOT work on WSL (no access to input devices)
{
  lib,
  config,
  ...
}:

let
  # Only enable on NixOS desktop (not WSL)
  isDesktop = !(config.wsl.enable or false);
in
{
  config = lib.mkIf isDesktop {
    services.kanata = {
      enable = true;
      keyboards.default = {
        # Empty list = auto-detect all keyboards
        devices = [ ];
        config = ''
          ;; Kanata configuration
          ;; Key remappings for Japanese input and Vim-friendly editing

          (defcfg
            process-unmapped-keys yes
          )

          (defsrc
            caps lmet rmet
          )

          (defalias
            ;; CapsLock: tap=Escape, hold=Ctrl (Vim-friendly)
            cap (tap-hold 200 200 esc lctl)
            ;; Left Meta: tap=英数 (Eisuu/lang2), hold=Meta
            lm  (tap-hold 200 200 lang2 lmet)
            ;; Right Meta: tap=かな (Kana/lang1), hold=Meta
            rm  (tap-hold 200 200 lang1 rmet)
          )

          (deflayer default
            @cap @lm @rm
          )
        '';
      };
    };
  };
}
