# NixOS configuration
{
  nixpkgs,
  home-manager,
  homeManager,
  shared,
}:
let
  inherit (shared)
    username
    userConfig
    allHosts
    mkSystemSpecialArgs
    ;
  inherit (homeManager) mkSystemHomeConfig;

  # User-defined modules from config.nix
  userModules = userConfig.modules or [ ];

  # Get host modules from config.nix
  getHostModules = hostName: (allHosts.${hostName} or { }).modules or [ ];

  mkNixOS =
    { self, inputs }:
    {
      system,
      hostName,
      extraModules ? [ ],
      homeModules ? [ ],
    }:
    let
      hostModules = getHostModules hostName;
    in
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = mkSystemSpecialArgs { inherit self inputs; } system;
      modules = [
        # User configuration
        {
          users.users.${username} = {
            isNormalUser = true;
            extraGroups = [
              "wheel"
              "networkmanager"
            ];
          };
        }

        # Home Manager as NixOS module
        home-manager.nixosModules.home-manager
        (mkSystemHomeConfig {
          inherit system;
          homeDir = "/home";
          extraImports = userModules ++ hostModules ++ homeModules;
        })
      ]
      ++ extraModules;
    };
in
{
  inherit mkNixOS;
}
