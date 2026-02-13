# Fleet configuration: users, hosts, modules, and nix settings
rec {
  # Default hosts for each environment (used by switch app)
  defaults = {
    darwin = "mac";
    nixos = "nixos-desktop";
    wsl = "wsl";
    linux = "desktop";
  };

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
        "https://numtide.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
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
    ./system/home-manager.nix
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

  # Reusable module sets to reduce duplication
  moduleSets = {
    # Full workstation: AI, tools, editor, terminal
    workstation = baseModules ++ [
      ./ai
      ./tools
      ./editor
      ./terminal
    ];
    # Server: minimal tools
    server = baseModules ++ [
      ./editor/vim.nix
      ./tools/git
      ./tools/cli.nix
      ./tools/bat.nix
      ./terminal/tmux.nix
    ];
  };

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
    # Standalone home-manager configurations
    wsl = {
      role = "workstation";
      system = "x86_64-linux";
      integration = "standalone";
      flags = [ "wslUser" ];
      modules = moduleSets.workstation ++ [ ./terminal/zellij ];
    };
    desktop = {
      role = "workstation";
      system = "x86_64-linux";
      integration = "standalone";
      modules = moduleSets.workstation ++ [ ./desktop ];
    };
    windows = {
      role = "workstation";
      system = "x86_64-linux";
      integration = "standalone";
      isWindows = true;
      modules = baseModules;
    };
    server = {
      role = "server";
      system = "x86_64-linux";
      integration = "standalone";
      modules = moduleSets.server;
    };
    server-arm = {
      role = "server";
      system = "aarch64-linux";
      integration = "standalone";
      modules = moduleSets.server;
    };

    # Darwin configurations
    mac = {
      role = "workstation";
      system = "aarch64-darwin";
      integration = "darwin";
      systemModules = [ ./system/darwin/desktop.nix ];
      modules = moduleSets.workstation;
    };
    mac-intel = {
      role = "workstation";
      system = "x86_64-darwin";
      integration = "darwin";
      systemModules = [ ./system/darwin/desktop.nix ];
      modules = moduleSets.workstation;
    };

    # NixOS configurations
    nixos-wsl = {
      role = "workstation";
      system = "x86_64-linux";
      integration = "nixos";
      flags = [ "wslUser" ];
      systemModules = [ ./system/nixos/wsl.nix ];
      modules = moduleSets.workstation ++ [ ./terminal/zellij ];
    };
    nixos-desktop = {
      role = "workstation";
      system = "x86_64-linux";
      integration = "nixos";
      systemModules = [
        ./system/nixos/desktop.nix
        ./system/nixos/kanata.nix
      ];
      modules = moduleSets.workstation ++ [ ./desktop ];
    };
    nixos-server = {
      role = "server";
      system = "x86_64-linux";
      integration = "nixos";
      systemModules = [ ./system/nixos/server.nix ];
      modules = moduleSets.server;
      deploy = {
        hostname = "nixos-server"; # Replace with actual hostname/IP
      };
    };
    nixos-server-arm = {
      role = "server";
      system = "aarch64-linux";
      integration = "nixos";
      systemModules = [ ./system/nixos/server.nix ];
      modules = moduleSets.server;
    };
    example-vps = {
      role = "server";
      system = "x86_64-linux";
      integration = "nixos";
      inputModules = [ "disko" ];
      systemModules = [
        ./system/nixos/example-vps
        ./system/nixos/server.nix
      ];
      modules = moduleSets.server;
      deploy = {
        hostname = "example-vps"; # Replace with actual hostname/IP
        user = "root";
      };
    };
  };

  # Remote servers (SSH config generation only, not managed by Nix)
  remoteServers = {
    pikachu = {
      hostname = "140.238.55.181";
      sshUser = "ubuntu";
      users = [ "anko" ];
    };
    metamon = {
      hostname = "150.230.108.22";
      sshUser = "ubuntu";
      users = [ "anko" ];
    };
    bracky = {
      hostname = "168.138.210.152";
      sshUser = "ubuntu";
      users = [ "anko" ];
    };
    pochama = {
      hostname = "193.123.167.108";
      sshUser = "ubuntu";
      users = [ "anko" ];
    };
  };
}
