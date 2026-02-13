# Fleet configuration: users, hosts, modules, and nix settings
rec {
  # Nix daemon settings (shared across darwin/nixos)
  nixSettings = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://devenv.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
      accept-flake-config = true;
      keep-derivations = true;
      keep-outputs = true;
      max-jobs = "auto";
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
    gcSchedule = {
      darwin = {
        Weekday = 0;
        Hour = 3;
        Minute = 0;
      };
      frequency = "weekly";
    };
  };

  # Centralized version management
  versions = {
    home = "24.11";
    nixos = "24.11";
    darwin = 5;
  };

  # Common system packages
  basePackages =
    pkgs: with pkgs; [
      git
      vim
      curl
      wget
    ];

  # Common fonts for desktop environments
  desktopFonts =
    pkgs: with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.hack
    ];

  # Base modules loaded for all configurations
  baseModules = [
    ./system/home-manager/core.nix
    # Dev
    ./dev/build-tools.nix
    ./dev/go.nix
    ./dev/mise.nix
    ./dev/nix.nix
    ./dev/node.nix
    ./dev/python.nix
    ./dev/rust.nix
    # Security
    ./security/1password.nix
    ./security/gitleaks.nix
    ./security/gpg.nix
    ./security/ssh.nix
    # Shell
    ./shell/aliases.nix
    ./shell/atuin.nix
    ./shell/bash.nix
    ./shell/defaults.nix
    ./shell/eza.nix
    ./shell/fish.nix
    ./shell/fzf.nix
    ./shell/readline.nix
    ./shell/starship.nix
    ./shell/zoxide.nix
    ./shell/zsh
    # Theme
    ./theme/catppuccin-mocha.nix
    ./theme/default.nix
  ];

  users = {
    anko = {
      editor = "nvim";
      theme = "catppuccin";
      git = {
        name = "anko9801";
        email = "37263451+anko9801@users.noreply.github.com";
        sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEpnmapaBsLWiMwmg201YFSh8J776ICJ8GnOEs5YmT/M";
      };
    };
    # GitHub Actions runner user
    runner = {
      editor = "vim";
      git = {
        name = "CI";
        email = "ci@localhost";
      };
    };
  };

  hosts = {
    # Workstations
    wsl = {
      platform = "wsl";
      type = "workstation";
      modules = baseModules ++ [
        ./ai
        ./tools
        ./editor
        ./terminal
        ./terminal/zellij
      ];
    };
    desktop = {
      platform = "linux";
      type = "workstation";
      modules = baseModules ++ [
        ./ai
        ./tools
        ./editor
        ./terminal
        ./desktop
      ];
    };
    windows = {
      platform = "windows";
      type = "workstation";
      modules = baseModules;
    };
    server = {
      platform = "linux";
      type = "server";
      modules = baseModules ++ [
        ./editor/vim.nix
        ./tools/git
        ./tools/cli.nix
        ./tools/bat.nix
        ./terminal/tmux.nix
      ];
    };
    mac = {
      platform = "darwin";
      type = "workstation";
      modules = baseModules ++ [
        ./ai
        ./tools
        ./editor
        ./terminal
      ];
    };

    # Servers (users = SSH access)
    pikachu = {
      platform = "nixos";
      type = "server";
      hostname = "140.238.55.181";
      sshUser = "ubuntu";
      users = [ "anko" ];
    };
    metamon = {
      platform = "nixos";
      type = "server";
      hostname = "150.230.108.22";
      sshUser = "ubuntu";
      users = [ "anko" ];
    };
    bracky = {
      platform = "nixos";
      type = "server";
      hostname = "168.138.210.152";
      sshUser = "ubuntu";
      users = [ "anko" ];
    };
    pochama = {
      platform = "nixos";
      type = "server";
      hostname = "193.123.167.108";
      sshUser = "ubuntu";
      users = [ "anko" ];
    };
  };
}
