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
      "nikitabobko/tap" # For AeroSpace
    ];

    # CLI tools (most are in Home Manager, these are Homebrew-only)
    brews = [
      "charmbracelet/tap/crush" # AI coding agent (avoids Nix Go build)
      "kanata" # Cross-platform key remapper
      "FelixKratz/formulae/sketchybar" # Custom macOS menu bar
      "FelixKratz/formulae/borders" # JankyBorders - window borders
      "nowplaying-cli" # Media info for SketchyBar
      "switchaudio-osx" # Audio device switching for SketchyBar
    ];

    # GUI Applications (casks)
    casks = [
      # Window management
      "aerospace"

      # Development
      "figma"
      "visual-studio-code"
      "zed"
      "cmux"
      "ghostty"
      "orbstack" # Docker replacement (2sec startup, 60% faster, 180mW)

      # AI/LLM (Metal acceleration)
      "claude"
      "ollama-app" # renamed from ollama

      # Productivity
      "notion"
      "raycast"
      "rectangle"
      "obsidian"

      # Communication
      "discord"
      "slack"
      "zoom"

      # Media
      "spotify"

      # Gaming
      "steam"

      # Japanese Input
      "aquaskk"
      "azookey" # Neural kana-kanji converter (Zenzai)

      # Karabiner-DriverKit (required for Kanata virtual keyboard)
      "karabiner-elements"

      # Utilities
      "1password"
      "appcleaner"
      "jordanbaird-ice" # Menu bar management
      "shottr" # Screenshot tool

      # Browser
      "arc"
    ];

  };
}
