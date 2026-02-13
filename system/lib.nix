# System builder utilities
{
  nixpkgs,
  username,
  home-manager,
  nix-index-database,
  nixvim,
  stylix,
  llm-agents ? null,
  agent-skills ? null,
  antfu-skills ? null,
}:
let
  cfg = import ../config.nix;

  inherit (cfg)
    nixSettings
    versions
    basePackages
    desktopFonts
    ;

  # User-specific configuration (must be defined in config.nix)
  userConfig = cfg.users.${username} or (throw "User '${username}' not defined in config.nix");

  allHosts = cfg.hosts;

  # Get host config from config.nix
  getHostConfig = hostName: allHosts.${hostName} or { };

  # Get host modules from config.nix (already includes baseModules)
  getHostModules = hostName: (getHostConfig hostName).modules or [ ];

  # Creates unified nix configuration for darwin/nixos (legacy function)
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
            { interval = nixSettings.gcSchedule.darwin; }
          else
            { dates = nixSettings.gcSchedule.frequency; }
        );
    };

  # System module that auto-detects darwin/nixos
  # Unified configuration for all platforms
  nixModule =
    { pkgs, lib, ... }:
    let
      inherit (pkgs.stdenv) isDarwin;
    in
    {
      # Nix daemon configuration
      nix = {
        inherit (nixSettings) settings;
        optimise.automatic = true;
        gc =
          nixSettings.gc
          // (
            if isDarwin then
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
      system.stateVersion = if isDarwin then versions.darwin else versions.nixos;

      # NixOS-only defaults
      time.timeZone = lib.mkIf (!isDarwin) (lib.mkDefault "Asia/Tokyo");
      i18n.defaultLocale = lib.mkIf (!isDarwin) (lib.mkDefault "ja_JP.UTF-8");
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
        allHosts
        hostConfig
        versions
        nixSettings
        mkNixConfig
        basePackages
        desktopFonts
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

  # External flake modules (not in config.nix)
  flakeModules = [
    nix-index-database.homeModules.nix-index
    nixvim.homeModules.nixvim
    stylix.homeModules.stylix
  ]
  ++ (if agent-skills != null then [ agent-skills.homeManagerModules.default ] else [ ]);

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
in
{
  inherit
    username
    userConfig
    allHosts
    versions
    nixSettings
    mkNixConfig
    nixModule
    basePackages
    desktopFonts
    getHostModules
    mkSpecialArgs
    mkSystemSpecialArgs
    mkSystemBuilder
    homeManagerModules
    flakeModules
    mkSystemHomeConfig
    mkStandaloneHome
    ;
}
