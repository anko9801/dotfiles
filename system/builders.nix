# Unified system builders for home-manager, darwin, and nixos
{
  nixpkgs,
  home-manager,
  nix-darwin,
  nix-homebrew,
  nix-index-database,
  nixvim,
  stylix,
  llm-agents ? null,
  agent-skills ? null,
  antfu-skills ? null,
}:
let
  inherit (nixpkgs) lib;

  # === Config ===
  fleetConfig = import ../config.nix;
  username =
    let
      envUser = builtins.getEnv "USER";
    in
    if envUser != "" then envUser else "nixuser";
  userConfig =
    fleetConfig.users.${username} or {
      name = username;
      email = "${username}@localhost";
    };
  allHosts = fleetConfig.hosts;

  # === Versions ===
  versions = {
    home = "24.11";
    nixos = "24.11";
    darwin = 5;
  };

  # === Nix Settings ===
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

  mkNixConfig =
    {
      isDarwin ? false,
    }:
    {
      inherit (nixSettings) settings;
      optimise.automatic = true;
      gc =
        nixSettings.gc
        // (
          if isDarwin then
            {
              interval = {
                Weekday = 0;
                Hour = 3;
                Minute = 0;
              };
            }
          else
            { dates = "weekly"; }
        );
    };

  # === Packages ===
  basePackages =
    pkgs: with pkgs; [
      git
      vim
      curl
      wget
    ];
  desktopFonts =
    pkgs: with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.hack
    ];

  # === Unfree Warning ===
  mkUnfreePkgs =
    system:
    let
      warn =
        maybeAttrs: prefix:
        let
          outputs = [
            "out"
            "dev"
            "lib"
            "bin"
            "man"
            "doc"
            "info"
          ];
          inner =
            if builtins.isAttrs maybeAttrs then
              builtins.mapAttrs (n: v: if builtins.elem n outputs then v else warn v "${prefix}.${n}") maybeAttrs
            else
              maybeAttrs;
        in
        if lib.isDerivation inner then builtins.warn "Using UNFREE package: ${prefix}" inner else inner;
    in
    warn (import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    }) "unfreePkgs";

  # === Special Args ===
  mkSpecialArgs = system: {
    inherit
      userConfig
      allHosts
      versions
      nixSettings
      mkNixConfig
      basePackages
      desktopFonts
      ;
    unfreePkgs = mkUnfreePkgs system;
  };

  # === Modules ===
  commonModules = [
    ./home-manager/core.nix
    ./defaults.nix
    ../dev/build-tools.nix
    ../dev/go.nix
    ../dev/mise.nix
    ../dev/nix.nix
    ../dev/node.nix
    ../dev/python.nix
    ../dev/rust.nix
    ../security/1password.nix
    ../security/gitleaks.nix
    ../security/gpg.nix
    ../security/ssh.nix
    ../shell/aliases.nix
    ../shell/atuin.nix
    ../shell/bash.nix
    ../shell/defaults.nix
    ../shell/eza.nix
    ../shell/fish.nix
    ../shell/fzf.nix
    ../shell/readline.nix
    ../shell/starship.nix
    ../shell/zoxide.nix
    ../shell/zsh
    ../theme/catppuccin-mocha.nix
    ../theme/default.nix
    nix-index-database.homeModules.nix-index
    nixvim.homeModules.nixvim
    stylix.homeModules.stylix
  ]
  ++ lib.optional (agent-skills != null) agent-skills.homeManagerModules.default;

  workstationModules = [
    ../ai
    ../tools
    ../editor
    ../terminal
  ];

  platformModules = {
    wsl = [ ../terminal/zellij ];
    desktop = [ ../desktop ];
    server = [
      ../editor/vim.nix
      ../tools/git
      ../tools/cli.nix
      ../tools/bat.nix
      ../terminal/tmux.nix
    ];
  };

  # === Builders ===
  mkStandaloneHome =
    {
      system,
      workstation ? true,
      homeModules ? [ ],
    }:
    let
      pkgs = import nixpkgs { inherit system; };
      llmAgentsPkgs = if llm-agents != null then llm-agents.packages.${system} or { } else { };
    in
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = mkSpecialArgs system // {
        inherit llmAgentsPkgs antfu-skills;
      };
      modules =
        commonModules
        ++ lib.optionals workstation workstationModules
        ++ homeModules
        ++ [
          {
            home = {
              inherit username;
              homeDirectory = "/home/${username}";
            };
            nix.package = pkgs.nix;
          }
        ];
    };

  mkSystemHomeConfig =
    {
      system,
      homeDir,
      extraImports ? [ ],
    }:
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = mkSpecialArgs system;
        users.${username} =
          { lib, ... }:
          {
            imports = commonModules ++ extraImports;
            home = {
              username = lib.mkForce username;
              homeDirectory = lib.mkForce "${homeDir}/${username}";
            };
          };
      };
    };

  mkDarwin =
    { self, inputs }:
    {
      system,
      extraModules ? [ ],
      homeModules ? [ ],
    }:
    nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = mkSpecialArgs system // {
        inherit self inputs username;
      };
      modules = [
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = system == "aarch64-darwin";
            user = username;
            autoMigrate = true;
          };
        }
        home-manager.darwinModules.home-manager
        (mkSystemHomeConfig {
          inherit system;
          homeDir = "/Users";
          extraImports = homeModules;
        })
        { system.primaryUser = username; }
      ]
      ++ extraModules;
    };

  mkNixOS =
    { self, inputs }:
    {
      system,
      extraModules ? [ ],
      homeModules ? [ ],
    }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = mkSpecialArgs system // {
        inherit self inputs username;
      };
      modules = [
        {
          users.users.${username} = {
            isNormalUser = true;
            extraGroups = [
              "wheel"
              "networkmanager"
            ];
          };
        }
        home-manager.nixosModules.home-manager
        (mkSystemHomeConfig {
          inherit system;
          homeDir = "/home";
          extraImports = homeModules;
        })
      ]
      ++ extraModules;
    };

in
{
  inherit
    mkStandaloneHome
    mkDarwin
    mkNixOS
    platformModules
    username
    ;
}
