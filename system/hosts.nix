# Host configuration generator
# Reads config.nix, resolves modules, and produces all flake outputs
# (homeConfigurations, darwinConfigurations, nixosConfigurations, deployNodes)
{ inputs, username }:
let
  inherit (inputs)
    nixpkgs
    home-manager
    nix-darwin
    nix-homebrew
    ;

  cfg = import ../config.nix;

  # Home-manager modules from flake inputs (loaded for all hosts)
  flakeHomeModules = [
    "nix-index-database"
    "nixvim"
    "stylix"
    "agent-skills"
  ];

  # Darwin-only HM modules
  darwinFlakeHomeModules = [
    "mac-app-util"
  ];

  resolveFlakeModule =
    name:
    inputs.${name}.homeModules.${name} or inputs.${name}.homeModules.default
      or inputs.${name}.homeManagerModules.default or inputs.${name}.hmModules.default
        or (throw "flakeHomeModule '${name}' not found");

  flakeModules = map resolveFlakeModule flakeHomeModules;

  coreModules = [
    ../system/common.nix
    ../dev/nix.nix
    ../shell/defaults.nix
    ../shell/bash.nix
  ];

  inherit (cfg)
    nixSettings
    versions
    ;

  defaults = cfg.defaultHosts;

  userConfig = cfg.users.${username} or (throw "User '${username}' not defined in config.nix");

  allHosts = cfg.hosts;
  remoteServers = cfg.remoteServers or { };

  getHostConfig = hostName: allHosts.${hostName} or { };

  getHostModules = hostName: (getHostConfig hostName).modules or [ ];

  mkUnfreePkgs =
    system:
    import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

  mkSpecialArgs =
    system: hostName:
    let
      hostConfig = getHostConfig hostName;
    in
    {
      inherit
        inputs
        username
        userConfig
        remoteServers
        hostConfig
        versions
        ;
      unfreePkgs = mkUnfreePkgs system;
    };

  # --- Builders ---

  # Nix daemon / system configuration for darwin and nixos
  nixModule =
    { pkgs, ... }:
    let
      inherit (pkgs.stdenv) isDarwin;
    in
    {
      nix =
        if isDarwin then
          { enable = false; }
        else
          {
            inherit (nixSettings) settings;
            extraOptions = "!include /etc/nix/private.conf";
            optimise.automatic = true;
            gc = nixSettings.gc // {
              dates = nixSettings.gcSchedule.frequency;
            };
          };

      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = with pkgs; [
        git
        vim
        curl
        wget
      ];

      programs.zsh.enable = true;
      home-manager.backupFileExtension = "backup";
      system.stateVersion = if isDarwin then versions.darwin else versions.nixos;
    };

  mkSystemHomeConfig =
    {
      system,
      hostName,
      homeDir,
      hostModules,
      extraFlakeModules ? [ ],
    }:
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = mkSpecialArgs system hostName;
        users.${username} =
          { lib, ... }:
          {
            imports = coreModules ++ flakeModules ++ extraFlakeModules ++ hostModules;
            home = {
              username = lib.mkForce username;
              homeDirectory = lib.mkForce "${homeDir}/${username}";
            };
            stylix.overlays.enable = false;
          };
      };
    };

  mkSystemBuilder =
    {
      systemBuilder,
      homeManagerModule,
      homeDir,
      platformModules ? [ ],
      extraFlakeHomeModules ? [ ],
    }:
    { self }:
    {
      system,
      hostName,
      extraModules ? [ ],
    }:
    let
      hostModules = getHostModules hostName;
    in
    systemBuilder {
      inherit system;
      specialArgs = mkSpecialArgs system hostName // {
        inherit self;
      };
      modules = [
        nixModule
      ]
      ++ platformModules
      ++ [
        homeManagerModule.home-manager
        (mkSystemHomeConfig {
          inherit
            system
            hostName
            hostModules
            homeDir
            ;
          extraFlakeModules = map resolveFlakeModule extraFlakeHomeModules;
        })
      ]
      ++ extraModules;
    };

  mkDarwinBuilder = mkSystemBuilder {
    systemBuilder = nix-darwin.lib.darwinSystem;
    homeManagerModule = home-manager.darwinModules;
    homeDir = "/Users";
    extraFlakeHomeModules = darwinFlakeHomeModules;
    platformModules = [
      nix-homebrew.darwinModules.nix-homebrew
      (
        { username, ... }:
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = false;
            user = username;
            autoMigrate = true;
          };
          system.primaryUser = username;
        }
      )
    ];
  };

  mkNixOSBuilder = mkSystemBuilder {
    systemBuilder = nixpkgs.lib.nixosSystem;
    homeManagerModule = home-manager.nixosModules;
    homeDir = "/home";
    platformModules = [
      (
        { lib, username, ... }:
        {
          time.timeZone = lib.mkDefault "Asia/Tokyo";
          i18n.defaultLocale = lib.mkDefault "ja_JP.UTF-8";
          users.users.${username} = {
            isNormalUser = true;
            extraGroups = [
              "wheel"
              "networkmanager"
            ];
          };
          programs.nix-ld.enable = true;
          boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
        }
      )
    ];
  };

  mkStandaloneHome =
    {
      system,
      hostName,
    }:
    let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      hostModules = getHostModules hostName;
    in
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = mkSpecialArgs system hostName;
      modules =
        coreModules
        ++ flakeModules
        ++ hostModules
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

  # --- Output generators ---

  mkDeployNodes =
    { self, deploy-rs }:
    let
      inherit (nixpkgs) lib;
      deployableHosts = lib.filterAttrs (_: h: h.deploy or null != null) allHosts;
    in
    lib.mapAttrs (name: host: {
      hostname = host.deploy.hostname or name;
      profiles.system = {
        user = host.deploy.user or "root";
        path = deploy-rs.lib.${host.system}.activate.nixos self.nixosConfigurations.${name};
      };
    }) deployableHosts;

  mkAllConfigurations =
    { self }:
    let
      inherit (nixpkgs) lib;

      mkDarwin = mkDarwinBuilder { inherit self; };
      mkNixOS = mkNixOSBuilder { inherit self; };

      byManager = type: lib.filterAttrs (_: h: (h.manager or null) == type) allHosts;

      resolveInputModules =
        host:
        map (
          name:
          inputs.${name}.nixosModules.${name} or inputs.${name}.nixosModules.default
            or (throw "inputModule '${name}' not found")
        ) (host.inputModules or [ ]);

    in
    {
      homeConfigurations = lib.mapAttrs (
        name: host:
        mkStandaloneHome {
          inherit (host) system;
          hostName = name;
        }
      ) (byManager "home-manager");

      darwinConfigurations = lib.mapAttrs (
        name: host:
        mkDarwin {
          inherit (host) system;
          hostName = name;
          extraModules = resolveInputModules host ++ (host.systemModules or [ ]);
        }
      ) (byManager "nix-darwin");

      nixosConfigurations = lib.mapAttrs (
        name: host:
        mkNixOS {
          inherit (host) system;
          hostName = name;
          extraModules = resolveInputModules host ++ (host.systemModules or [ ]);
        }
      ) (byManager "nixos");
    };
in
{
  inherit
    mkAllConfigurations
    mkDeployNodes
    defaults
    ;
}
