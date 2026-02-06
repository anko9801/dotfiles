{
  pkgs,
  ...
}:

let
  nixSettings = import ../nix-settings.nix;
in
{
  imports = [
    ./homebrew.nix
    ./aerospace.nix
    ./kanata.nix
    ./system.nix
  ];

  nix = {
    inherit (nixSettings) settings;
    optimise.automatic = true;
    gc = nixSettings.gc // {
      interval = {
        Weekday = 0;
        Hour = 3;
        Minute = 0;
      };
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

  # Home Manager
  home-manager.backupFileExtension = "backup";
  home-manager.sharedModules = [
    ../../home/tools
    ../../home/editor
    (
      { pkgs, ... }:
      {
        home = {
          sessionPath = [
            "/opt/homebrew/bin"
            "/opt/homebrew/sbin"
          ];
          packages = with pkgs; [
            coreutils
            findutils
            gnugrep
            gnutar
            darwin.trash
            terminal-notifier
          ];
        };
      }
    )
  ];

  # Used for backwards compatibility
  system.stateVersion = 5;

  # The platform is set by flake.nix based on the system parameter
}
