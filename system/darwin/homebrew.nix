_:

{
  # Homebrew configuration (managed by nix-darwin)
  homebrew = {
    enable = true;

    # Automatically remove unlisted packages
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
      upgrade = true;
    };

    # Taps
    taps = [
      "charmbracelet/tap" # For crush
      "FelixKratz/formulae" # For SketchyBar, JankyBorders
    ];

    # CLI tools (most are in Home Manager, these are Homebrew-only)
    brews = [
      # keep-sorted start
      "FelixKratz/formulae/borders"
      "FelixKratz/formulae/sketchybar"
      "charmbracelet/tap/crush"
      "kanata"
      "nowplaying-cli"
      "switchaudio-osx"
      # keep-sorted end
    ];

    # GUI Applications (casks)
    casks = [
      # keep-sorted start
      "1password"
      "appcleaner"
      "aquaskk"
      "arc"
      "azookey"
      "claude"
      "cmux"
      "discord"
      "figma"
      "ghostty"
      "jordanbaird-ice"
      "karabiner-elements"
      "nikitabobko/tap/aerospace"
      "notion"
      "obsidian"
      "ollama-app"
      "orbstack"
      "raycast"
      "rectangle"
      "shottr"
      "slack"
      "spotify"
      "steam"
      "visual-studio-code"
      "zed"
      "zoom"
      # keep-sorted end
    ];

  };
}
