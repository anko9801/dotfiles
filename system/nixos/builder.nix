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
      # Nix configuration (shared with darwin)
      nixModule
      # NixOS-specific defaults
      (
        { lib, ... }:
        {
          time.timeZone = lib.mkDefault "Asia/Tokyo";
          i18n.defaultLocale = lib.mkDefault "ja_JP.UTF-8";
        }
      )
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
