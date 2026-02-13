# NixOS configuration
{
  nixpkgs,
  home-manager,
  homeManager,
  systemLib,
}:
let
  inherit (systemLib) mkSystemBuilder;
  inherit (homeManager) mkSystemHomeConfig;

  mkNixOS = mkSystemBuilder {
    systemBuilder = nixpkgs.lib.nixosSystem;
    homeManagerModule = home-manager.nixosModules;
    homeDir = "/home";
    inherit mkSystemHomeConfig;
    mkPlatformModules = _system: username: [
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
    ];
  };
in
{
  inherit mkNixOS;
}
