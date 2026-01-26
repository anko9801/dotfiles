{ config, pkgs, lib, ... }:

{
  # Homebrew configuration (managed by nix-darwin)
  homebrew = {
    enable = true;

    # Automatically remove unlisted packages
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";  # Remove all unlisted packages
      upgrade = true;
    };

    # Taps
    taps = [
      "koekeishiya/formulae"
    ];

    # CLI tools (most are in Home Manager, these are Homebrew-only)
    brews = [
      # Window management (needs Homebrew for macOS integration)
      "koekeishiya/formulae/yabai"
      "koekeishiya/formulae/skhd"
    ];

    # GUI Applications (casks)
    casks = [
      # Development
      "visual-studio-code"
      "iterm2"
      "docker"

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
