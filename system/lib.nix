# System builder utilities
{ inputs, username }:
let
  inherit (inputs)
    nixpkgs
    home-manager
    nix-darwin
    nix-homebrew
    llm-agents
    antfu-skills
    ;

  cfg = import ../config.nix;

  # Home-manager modules from flake inputs
  flakeHomeModules = [
    "nix-index-database"
    "nixvim"
    "stylix"
    "agent-skills"
  ];

  resolveFlakeModule =
    name:
    inputs.${name}.homeModules.${name} or inputs.${name}.homeModules.default
      or inputs.${name}.homeManagerModules.default or (throw "flakeHomeModule '${name}' not found");

  flakeModules = map resolveFlakeModule flakeHomeModules;

  # Core modules required for all configurations (prevents broken environments)
  coreModules = [
    ../system/home-manager.nix
    ../dev/nix.nix
    ../shell/defaults.nix
    ../shell/bash.nix
  ];

  inherit (cfg)
    nixSettings
    versions
    basePackages
    ;

  defaults = cfg.defaultHosts;

  # User-specific configuration (must be defined in config.nix)
  userConfig = cfg.users.${username} or (throw "User '${username}' not defined in config.nix");

  allHosts = cfg.hosts;
  remoteServers = cfg.remoteServers or { };

  # Get host config from config.nix
  getHostConfig = hostName: allHosts.${hostName} or { };

  # OS detection from pkgs
  getOS = { pkgs, ... }: if pkgs.stdenv.isDarwin then "darwin" else "linux";

  # Get host modules from config.nix (already includes baseModules)
  getHostModules = hostName: (getHostConfig hostName).modules or [ ];

  # System module that auto-detects darwin/nixos
  # Unified configuration for all platforms
  nixModule =
    { pkgs, ... }:
    let
      os = getOS { inherit pkgs; };
    in
    {
      # Nix daemon configuration
      nix = {
        inherit (nixSettings) settings;
        optimise.automatic = true;
        gc =
          nixSettings.gc
          // (
            if os == "darwin" then
              { interval = nixSettings.gcSchedule.darwin; }
            else
              { dates = nixSettings.gcSchedule.frequency; }
          );
      };

      # Base packages (git, vim, curl, wget)
      environment.systemPackages = basePackages pkgs;

      # Zsh as default shell environment
      programs.zsh.enable = true;

      # Home Manager backup extension
      home-manager.backupFileExtension = "backup";

      # State version (auto-detect)
      system.stateVersion = if os == "darwin" then versions.darwin else versions.nixos;
    };

  # Unfree package handling with build-time warnings
  setUnfreeWarning =
    maybeAttrs: prefix:
    let
      outputNames = [
        "out"
        "dev"
        "lib"
        "bin"
        "man"
        "doc"
        "info"
      ];
      withoutWarning =
        if builtins.isAttrs maybeAttrs then
          builtins.mapAttrs (
            name: value:
            if builtins.elem name outputNames then value else setUnfreeWarning value "${prefix}.${name}"
          ) maybeAttrs
        else
          maybeAttrs;
    in
    if nixpkgs.lib.isDerivation withoutWarning then
      builtins.warn "Using UNFREE package: ${prefix}" withoutWarning
    else
      withoutWarning;

  mkUnfreePkgs =
    system:
    setUnfreeWarning (import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    }) "unfreePkgs";

  # Special args for home-manager modules
  mkSpecialArgs =
    system: hostName:
    let
      hostConfig = getHostConfig hostName;
      llmAgentsPkgs = if llm-agents != null then llm-agents.packages.${system} or { } else { };
    in
    {
      inherit
        userConfig
        remoteServers
        hostConfig
        versions
        nixSettings
        getOS
        llmAgentsPkgs
        antfu-skills
        ;
      unfreePkgs = mkUnfreePkgs system;
    };

  # Special args for system modules (darwin/nixos)
  mkSystemSpecialArgs =
    { self, inputs }:
    system: hostName: mkSpecialArgs system hostName // { inherit self inputs username; };

  # Factory for creating system builders (darwin/nixos)
  # Reduces duplication between darwin and nixos builders
  mkSystemBuilder =
    {
      systemBuilder, # nix-darwin.lib.darwinSystem or nixpkgs.lib.nixosSystem
      homeManagerModule, # home-manager.darwinModules or home-manager.nixosModules
      homeDir, # "/Users" or "/home"
      mkPlatformModules, # system -> username -> list of platform-specific modules
    }:
    { self, inputs }:
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
      specialArgs = mkSystemSpecialArgs { inherit self inputs; } system hostName;
      modules =
        mkPlatformModules system username
        ++ [
          homeManagerModule.home-manager
          (mkSystemHomeConfig {
            inherit
              system
              hostName
              hostModules
              homeDir
              ;
          })
        ]
        ++ extraModules;
    };

  # Darwin-specific builder
  mkDarwinBuilder = mkSystemBuilder {
    systemBuilder = nix-darwin.lib.darwinSystem;
    homeManagerModule = home-manager.darwinModules;
    homeDir = "/Users";
    mkPlatformModules = system: user: [
      nixModule
      nix-homebrew.darwinModules.nix-homebrew
      {
        nix-homebrew = {
          enable = true;
          enableRosetta = system == "aarch64-darwin";
          inherit user;
          autoMigrate = true;
        };
      }
      { system.primaryUser = user; }
    ];
  };

  # NixOS-specific builder
  mkNixOSBuilder = mkSystemBuilder {
    systemBuilder = nixpkgs.lib.nixosSystem;
    homeManagerModule = home-manager.nixosModules;
    homeDir = "/home";
    mkPlatformModules = _system: user: [
      nixModule
      (
        { lib, ... }:
        {
          time.timeZone = lib.mkDefault "Asia/Tokyo";
          i18n.defaultLocale = lib.mkDefault "ja_JP.UTF-8";
        }
      )
      {
        users.users.${user} = {
          isNormalUser = true;
          extraGroups = [
            "wheel"
            "networkmanager"
          ];
        };
      }
    ];
  };

  # Home Manager config for system integration (darwin/nixos modules)
  mkSystemHomeConfig =
    {
      system,
      hostName,
      homeDir,
      hostModules,
    }:
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = mkSpecialArgs system hostName;
        users.${username} =
          { lib, ... }:
          {
            imports = coreModules ++ flakeModules ++ hostModules;
            home = {
              username = lib.mkForce username;
              homeDirectory = lib.mkForce "${homeDir}/${username}";
            };
          };
      };
    };

  # Standalone home-manager configuration (no system integration)
  mkStandaloneHome =
    {
      system,
      hostName,
    }:
    let
      pkgs = import nixpkgs { inherit system; };
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

  # Generate deploy-rs nodes from hosts with deploy field
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

  # Generate all configurations from hosts in config.nix
  mkAllConfigurations =
    { self }:
    let
      inherit (nixpkgs) lib;

      # Instantiate builders with self/inputs
      mkDarwin = mkDarwinBuilder { inherit self inputs; };
      mkNixOS = mkNixOSBuilder { inherit self inputs; };

      # Filter hosts by builder type (only hosts with a builder field)
      byBuilder = type: lib.filterAttrs (_: h: (h.integration or null) == type) allHosts;

      # Resolve input module references to actual modules (auto-detect from inputs)
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
      ) (byBuilder "standalone");

      darwinConfigurations = lib.mapAttrs (
        name: host:
        mkDarwin {
          inherit (host) system;
          hostName = name;
          extraModules = resolveInputModules host ++ (host.systemModules or [ ]);
        }
      ) (byBuilder "darwin");

      nixosConfigurations = lib.mapAttrs (
        name: host:
        mkNixOS {
          inherit (host) system;
          hostName = name;
          extraModules = resolveInputModules host ++ (host.systemModules or [ ]);
        }
      ) (byBuilder "nixos");
    };
in
{
  inherit
    mkAllConfigurations
    mkDeployNodes
    defaults
    ;
}
