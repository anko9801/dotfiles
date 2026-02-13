# Standalone Home Manager configuration (for Linux/WSL)
{
  nixpkgs,
  home-manager,
  nix-index-database,
  nixvim,
  stylix,
  systemLib,
  llm-agents ? null,
  agent-skills ? null,
  antfu-skills ? null,
}:
let
  inherit (systemLib)
    username
    allHosts
    mkSpecialArgs
    ;

  # Get host modules from config.nix
  getHostModules = hostName: (allHosts.${hostName} or { }).modules or [ ];

  # Common modules from config.nix + external flake modules
  commonModules =
    systemLib.commonModules
    ++ [
      nix-index-database.homeModules.nix-index
      nixvim.homeModules.nixvim
      stylix.homeModules.stylix
    ]
    ++ (if agent-skills != null then [ agent-skills.homeManagerModules.default ] else [ ]);

  # Home Manager config for system integration (darwin/nixos modules)
  # Used when home-manager is embedded in nix-darwin or NixOS
  mkSystemHomeConfig =
    {
      system,
      homeDir,
      extraImports ? [ ],
    }:
    let
      llmAgentsPkgs = if llm-agents != null then llm-agents.packages.${system} or { } else { };
    in
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = mkSpecialArgs system // {
          inherit llmAgentsPkgs antfu-skills;
        };
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

  # Standalone home-manager configuration (no system integration)
  # Used for pure home-manager setups (WSL, non-NixOS Linux)
  mkStandaloneHome =
    {
      system,
      hostName,
      homeModules ? [ ],
    }:
    let
      pkgs = import nixpkgs { inherit system; };
      # AI tools from llm-agents flake
      llmAgentsPkgs = if llm-agents != null then llm-agents.packages.${system} or { } else { };
      # Host-specific modules from config.nix
      hostModules = getHostModules hostName;
    in
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = mkSpecialArgs system // {
        inherit llmAgentsPkgs antfu-skills;
      };
      modules =
        commonModules
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
    commonModules
    mkSystemHomeConfig
    mkStandaloneHome
    ;
}
