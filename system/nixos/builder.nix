# NixOS configuration
{
  nixpkgs,
  home-manager,
  systemLib,
}:
let
  inherit (systemLib) mkSystemBuilder;

  mkNixOS = mkSystemBuilder {
    systemBuilder = nixpkgs.lib.nixosSystem;
    homeManagerModule = home-manager.nixosModules;
    homeDir = "/home";
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
