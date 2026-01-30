_:

{
  # Homebrew configuration (managed by nix-darwin)
  homebrew = {
    enable = true;

    # Automatically remove unlisted packages
    onActivation = {
      autoUpdate = true;
      cleanup = "zap"; # Remove all unlisted packages
      upgrade = true;
    };

    # Taps
    taps = [
      "charmbracelet/tap" # For crush
    ];

    # CLI tools (most are in Home Manager, these are Homebrew-only)
    brews = [
      "charmbracelet/tap/crush" # AI coding agent (avoids Nix Go build)
    ];

    # GUI Applications (casks)
    casks = [
      # Window management
      "nikitabobko/tap/aerospace"

      # Development
      "visual-studio-code"
      "ghostty"
      "orbstack" # Docker replacement (2sec startup, 60% faster, 180mW)

      # AI/LLM (Metal acceleration)
      "ollama"

      # Productivity
      "raycast"
      "rectangle"
      "obsidian"

      # Communication
      "discord"
      "slack"
      "zoom"

      # Media
      "spotify"

      # Utilities
      "1password"
      "appcleaner"
      "jordanbaird-ice" # Menu bar management
      "maccy" # Clipboard manager
      "shottr" # Screenshot tool

      # Browser
      "arc"
    ];

    # Mac App Store apps (requires mas CLI)
    masApps = {
      # "App Name" = App ID;
      # Example: "Xcode" = 497799835;
    };
  };
}
