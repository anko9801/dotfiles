# NixOS configuration
{
  nixpkgs,
  home-manager,
  home,
  common,
}:
let
  inherit (common) username mkSystemSpecialArgs;
  inherit (home) mkHomeManagerConfig;

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
        (mkHomeManagerConfig {
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
