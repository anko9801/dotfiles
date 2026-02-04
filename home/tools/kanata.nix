# Kanata - Cross-platform key remapper
# https://github.com/jtroo/kanata
# Shared configuration for Linux (NixOS) and macOS (nix-darwin)
# Note: Does NOT work on WSL (no access to input devices)
{ ... }:

{
  # Generate Kanata config file at ~/.config/kanata/kanata.kbd
  xdg.configFile."kanata/kanata.kbd".text = ''
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
}
