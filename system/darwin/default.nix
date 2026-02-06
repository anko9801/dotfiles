{
  pkgs,
  ...
}:

let
  nixSettings = import ../nix-settings.nix;
  basePkgs = import ../base-packages.nix pkgs;
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
  environment.systemPackages = basePkgs.base;

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
    ./home.nix
  ];

  # Used for backwards compatibility
  system.stateVersion = 5;

  # The platform is set by flake.nix based on the system parameter
}
