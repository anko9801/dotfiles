# nix-darwin configuration (for macOS)
{
  nix-darwin,
  nix-homebrew,
  systemLib,
}:
let
  inherit (systemLib) mkSystemBuilder homeManagerModules nixModule;

  mkDarwin = mkSystemBuilder {
    systemBuilder = nix-darwin.lib.darwinSystem;
    homeManagerModule = homeManagerModules.darwin;
    homeDir = "/Users";
    mkPlatformModules = system: username: [
      # Nix configuration (auto-detects darwin)
      nixModule
      # Homebrew management
      nix-homebrew.darwinModules.nix-homebrew
      {
        nix-homebrew = {
          enable = true;
          enableRosetta = system == "aarch64-darwin";
          user = username;
          autoMigrate = true;
        };
      }
      # Override system.primaryUser for the specific user
      { system.primaryUser = username; }
    ];
  };
in
{
  inherit mkDarwin;
}
