# NixOS configuration
{
  nixpkgs,
  systemLib,
}:
let
  inherit (systemLib) mkSystemBuilder homeManagerModules nixModule;

  mkNixOS = mkSystemBuilder {
    systemBuilder = nixpkgs.lib.nixosSystem;
    homeManagerModule = homeManagerModules.nixos;
    homeDir = "/home";
    mkPlatformModules = _system: username: [
      # Nix configuration (auto-detects nixos)
      nixModule
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
