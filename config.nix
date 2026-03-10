# Fleet configuration: users, hosts, modules, and nix settings
rec {
  users = {
    anko = {
      editor = "nvim";
      git = {
        name = "anko9801";
        email = "37263451+anko9801@users.noreply.github.com";
        sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEpnmapaBsLWiMwmg201YFSh8J776ICJ8GnOEs5YmT/M";
      };
    };
    runner = {
      editor = "vim";
      git = {
        name = "CI";
        email = "ci@localhost";
      };
    };
  };

  # Base modules loaded for standard configurations
  # (coreModules in hosts.nix are always loaded: common.nix, nix.nix, defaults.nix, bash.nix)
  baseModules = [
    # Dev
    ./dev/build-tools.nix
    ./dev/go.nix
    ./dev/mise.nix
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

  # Reusable module sets
  moduleSets = {
    workstation = baseModules ++ [
      ./ai
      ./tools
      ./editor
      ./terminal
    ];
    server = baseModules ++ [
      ./editor/vim.nix
      ./tools/git
      ./tools/cli.nix
      ./tools/bat.nix
      ./terminal/tmux.nix
    ];
  };

  # Default host for each environment (used by switch app)
  defaultHosts = {
    darwin = "mac-arm";
    nixos = "nixos-desktop";
    wsl = "linux-wsl";
    linux = "linux-desktop";
  };

  # Host naming convention:
  #   - Architecture suffix: `-intel` (x64) or `-arm` (aarch64) when both exist
  #   - No suffix when only one architecture exists
  #   - manager: "home-manager" (standalone) | "nixos" | "nix-darwin"
  hosts = {
    # Home Manager only (standalone Linux)
    linux-wsl = {
      system = "x86_64-linux";
      manager = "home-manager";
      modules = moduleSets.workstation ++ [ ./terminal/zellij ];
    };
    linux-desktop = {
      system = "x86_64-linux";
      manager = "home-manager";
      modules = moduleSets.workstation ++ [ ./desktop ];
    };
    linux-server-intel = {
      system = "x86_64-linux";
      manager = "home-manager";
      modules = moduleSets.server;
    };
    linux-server-arm = {
      system = "aarch64-linux";
      manager = "home-manager";
      modules = moduleSets.server;
    };
    # nix-darwin + home-manager
    mac-arm = {
      system = "aarch64-darwin";
      manager = "nix-darwin";
      modules = moduleSets.workstation;
      systemModules = [ ./system/darwin/defaults.nix ];
    };
    mac-intel = {
      system = "x86_64-darwin";
      manager = "nix-darwin";
      modules = moduleSets.workstation;
      systemModules = [ ./system/darwin/defaults.nix ];
    };

    # NixOS + home-manager
    nixos-wsl = {
      system = "x86_64-linux";
      manager = "nixos";
      modules = moduleSets.workstation ++ [ ./terminal/zellij ];
      inputModules = [ "stylix" ];
      systemModules = [ ./system/nixos/wsl.nix ];
    };
    nixos-desktop = {
      system = "x86_64-linux";
      manager = "nixos";
      modules = moduleSets.workstation ++ [ ./desktop ];
      inputModules = [ "stylix" ];
      systemModules = [
        ./system/nixos/desktop.nix
        (import ./desktop/kanata.nix).nixosModule
      ];
    };
    nixos-server-intel = {
      system = "x86_64-linux";
      manager = "nixos";
      modules = moduleSets.server;
      inputModules = [ "comin" ];
      systemModules = [
        ./system/nixos/server.nix
        ./system/nixos/comin.nix
      ];
      deploy.hostname = "nixos-server-intel";
    };
    nixos-server-arm = {
      system = "aarch64-linux";
      manager = "nixos";
      modules = moduleSets.server;
      systemModules = [ ./system/nixos/server.nix ];
    };
    example-vps = {
      system = "x86_64-linux";
      manager = "nixos";
      modules = moduleSets.server;
      inputModules = [
        "disko"
        "comin"
      ];
      systemModules = [
        ./system/nixos/example-vps
        ./system/nixos/server.nix
        ./system/nixos/comin.nix
      ];
      deploy = {
        hostname = "example-vps";
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

  # ═══════════════════════════════════════════════════════════════════════════
  # Nix infrastructure settings (rarely changed)
  # ═══════════════════════════════════════════════════════════════════════════

  versions = {
    home = "24.11";
    nixos = "24.11";
    darwin = 5;
  };

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
}
