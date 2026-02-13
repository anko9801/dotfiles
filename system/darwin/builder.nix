# nix-darwin configuration (for macOS)
{
  nix-darwin,
  nix-homebrew,
  home-manager,
  systemLib,
}:
let
  inherit (systemLib) mkSystemBuilder;

  mkDarwin = mkSystemBuilder {
    systemBuilder = nix-darwin.lib.darwinSystem;
    homeManagerModule = home-manager.darwinModules;
    homeDir = "/Users";
    mkPlatformModules = system: username: [
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
