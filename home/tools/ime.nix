# Japanese Input Method (SKK)
# - Linux: fcitx5-skk
# - macOS: AquaSKK (installed via Homebrew)
# - WSL: Uses Windows IME (no config needed)
{
  pkgs,
  lib,
  config,
  ...
}:

let
  isLinuxDesktop = pkgs.stdenv.isLinux && !(config.targets.genericLinux.enable or false);
in
{
  # Linux desktop only (not WSL)
  config = lib.mkIf isLinuxDesktop {
    i18n.inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-skk
        fcitx5-gtk
      ];
    };

    # SKK dictionaries
    home.packages = with pkgs; [
      skktools
      skkDictionaries.l # Large dictionary
      skkDictionaries.jinmei # Personal names
      skkDictionaries.geo # Geographic names
      skkDictionaries.emoji
    ];

    # fcitx5 config
    xdg.configFile."fcitx5/profile".text = ''
      [Groups/0]
      Name=Default
      Default Layout=us
      DefaultIM=skk

      [Groups/0/Items/0]
      Name=keyboard-us
      Layout=

      [Groups/0/Items/1]
      Name=skk
      Layout=

      [GroupOrder]
      0=Default
    '';

    # SKK config with AZIK
    xdg.configFile."fcitx5/conf/skk.conf".text = ''
      # Use AZIK input style for efficient Japanese typing
      InputStyle=AZIK
      # Punctuation style
      PunctuationStyle=JA
      # Show annotation
      ShowAnnotation=True
    '';
  };
}

# Note: For macOS (AquaSKK) and Windows (CorvusSKK), enable AZIK in their respective settings:
# - AquaSKK: Preferences > Input > AZIK
# - CorvusSKK: Settings > Romaji Table > AZIK
