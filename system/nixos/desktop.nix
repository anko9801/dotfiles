{ pkgs, ... }:

let
  nixSettings = import ../nix-settings.nix;
in
{
  # NOTE: Replace with hardware-configuration.nix after installing NixOS
  # imports = [ ./hardware-configuration.nix ];
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "nixos-desktop";
    networkmanager.enable = true;
  };

  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "ja_JP.UTF-8";

  nix = {
    settings = nixSettings;
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Niri compositor
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  # Display manager (greetd + tuigreet)
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
        user = "greeter";
      };
    };
  };

  # XWayland
  programs.xwayland.enable = true;

  # Audio (PipeWire)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # Polkit (for GUI auth)
  security.polkit.enable = true;
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # Fonts
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
    ];
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif CJK JP" ];
        sansSerif = [ "Noto Sans CJK JP" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
      };
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    firefox
    nautilus
    pavucontrol
    networkmanagerapplet
    polkit_gnome
    gnome-keyring
    libsecret
  ];

  # GNOME Keyring
  services.gnome.gnome-keyring.enable = true;

  # Dconf (for GTK apps)
  programs.dconf.enable = true;

  # This value determines the NixOS release
  system.stateVersion = "24.11";
}
