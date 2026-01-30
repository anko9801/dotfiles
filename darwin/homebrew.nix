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
    taps = [ ];

    # CLI tools (most are in Home Manager, these are Homebrew-only)
    brews = [ ];

    # GUI Applications (casks)
    casks = [
      # Window management
      "nikitabobko/tap/aerospace"

      # Development
      "visual-studio-code"
      "ghostty"
      "docker"

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
    ];

    # Mac App Store apps (requires mas CLI)
    masApps = {
      # "App Name" = App ID;
      # Example: "Xcode" = 497799835;
    };
  };
}
