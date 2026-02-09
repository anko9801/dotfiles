# NixOS configuration
{
  nixpkgs,
  home-manager,
  homeManager,
  shared,
}:
let
  inherit (shared) username mkSystemSpecialArgs;
  inherit (homeManager) mkSystemHomeConfig;

  mkNixOS =
    { self, inputs }:
    {
      system,
      extraModules ? [ ],
      homeModules ? [ ],
    }:
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
          extraImports = homeModules;
        })
      ]
      ++ extraModules;
    };
in
{
  inherit mkNixOS;
}
