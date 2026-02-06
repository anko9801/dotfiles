# Common system packages shared across platforms
# Used by NixOS and nix-darwin configs
pkgs: {
  # Core packages for all systems
  base = with pkgs; [
    git
    vim
    curl
  ];

  # Additional packages for NixOS (not needed on darwin)
  nixos = with pkgs; [
    wget
  ];

  # Server-specific packages
  server = with pkgs; [
    htop
  ];

  # Desktop-specific packages (GUI apps)
  desktop = with pkgs; [
    firefox
    nautilus
    pavucontrol
    networkmanagerapplet
    polkit_gnome
    gnome-keyring
    libsecret
  ];
}
