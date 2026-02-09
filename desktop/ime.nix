# Japanese Input Method (SKK) for Linux Desktop
# - fcitx5-skk with AZIK input style
{ pkgs, lib, ... }:

let
  isCI = builtins.getEnv "CI" != "";
in
{
  # Skip IME setup in CI (no display server)
  config = lib.mkIf (!isCI) {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
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
