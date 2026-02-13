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

  # Get host modules from config.nix (already includes baseModules)
  getHostModules = hostName: (allHosts.${hostName} or { }).modules or [ ];

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
        extraSpecialArgs = mkSpecialArgs system // {
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
      extraSpecialArgs = mkSpecialArgs system // {
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
    flakeModules
    mkSystemHomeConfig
    mkStandaloneHome
    ;
}
