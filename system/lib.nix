# System builder utilities
{
  nixpkgs,
  username,
  home-manager,
  homeModules ? { },
  llm-agents ? null,
  antfu-skills ? null,
}:
let
  cfg = import ../config.nix;

  inherit (cfg)
    nixSettings
    versions
    basePackages
    desktopFonts
    defaults
    ;

  # User-specific configuration (must be defined in config.nix)
  userConfig = cfg.users.${username} or (throw "User '${username}' not defined in config.nix");

  allHosts = cfg.hosts;
  remoteServers = cfg.remoteServers or { };

  # Get host config from config.nix
  getHostConfig = hostName: allHosts.${hostName} or { };

  # Single source of truth for OS detection
  getOS =
    {
      pkgs,
      hostConfig ? { },
    }:
    if pkgs.stdenv.isDarwin then
      "darwin"
    else if hostConfig.isWindows or false then
      "windows"
    else
      "linux";

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
    in
    {
      inherit
        userConfig
        remoteServers
        hostConfig
        versions
        nixSettings
        desktopFonts
        getOS
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
      homeModules ? [ ],
    }:
    let
      hostModules = getHostModules hostName ++ homeModules;
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

  # Home Manager modules for system integration
  homeManagerModules = {
    darwin = home-manager.darwinModules;
    nixos = home-manager.nixosModules;
  };

  # External flake modules (passed from flake.nix)
  flakeModules = builtins.attrValues homeModules;

  # Home Manager config for system integration (darwin/nixos modules)
  mkSystemHomeConfig =
    {
      system,
      hostName,
      homeDir,
      hostModules,
    }:
    let
      llmAgentsPkgs = if llm-agents != null then llm-agents.packages.${system} or { } else { };
    in
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = mkSpecialArgs system hostName // {
          inherit llmAgentsPkgs antfu-skills;
        };
        users.${username} =
          { lib, ... }:
          {
            imports = flakeModules ++ hostModules;
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
      homeModules ? [ ],
    }:
    let
      pkgs = import nixpkgs { inherit system; };
      llmAgentsPkgs = if llm-agents != null then llm-agents.packages.${system} or { } else { };
      hostModules = getHostModules hostName;
    in
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = mkSpecialArgs system hostName // {
        inherit llmAgentsPkgs antfu-skills;
      };
      modules =
        flakeModules
        ++ hostModules
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
    {
      mkDarwin,
      mkNixOS,
      inputModules ? { },
    }:
    let
      inherit (nixpkgs) lib;

      # Filter hosts by builder type (only hosts with a builder field)
      byBuilder = type: lib.filterAttrs (_: h: (h.integration or null) == type) allHosts;

      # Resolve input module references to actual modules
      resolveInputModules = host: map (name: inputModules.${name}) (host.inputModules or [ ]);

      # Flag-based homeModules (extensible for future flags)
      flagModules = {
        wslUser = {
          programs.wsl.windowsUser = username;
        };
      };

      # Resolve flags to homeModules (only flags with corresponding modules)
      mkFlagModules =
        host:
        let
          flags = host.flags or [ ];
          knownFlags = builtins.filter (f: flagModules ? ${f}) flags;
        in
        map (flag: flagModules.${flag}) knownFlags;
    in
    {
      homeConfigurations = lib.mapAttrs (
        name: host:
        mkStandaloneHome {
          inherit (host) system;
          hostName = name;
          homeModules = mkFlagModules host;
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
          homeModules = mkFlagModules host;
        }
      ) (byBuilder "nixos");
    };
in
{
  # Used by flake.nix
  inherit
    mkStandaloneHome
    mkAllConfigurations
    mkDeployNodes
    defaults
    ;

  # Used by darwin/builder.nix and nixos/builder.nix
  inherit mkSystemBuilder homeManagerModules nixModule;
}
