{
  pkgs,
  ...
}:

{
  imports = [
    ./homebrew.nix
    ./aerospace.nix
    ./system.nix
  ];

  # Nix configuration
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    optimise.automatic = true;
    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 3;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };
  };

  # System packages (available to all users)
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
  ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.hack
  ];

  # Enable Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # Create /etc/zshrc that loads nix-darwin environment
  programs.zsh.enable = true;

  # Primary user is set in flake.nix based on the user parameter

  # Home Manager backup for existing files
  home-manager.backupFileExtension = "backup";

  # Used for backwards compatibility
  system.stateVersion = 5;

  # The platform is set by flake.nix based on the system parameter
}
