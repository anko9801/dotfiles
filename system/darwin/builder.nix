# nix-darwin configuration (for macOS)
{
  nix-darwin,
  nix-homebrew,
  home-manager,
  homeManager,
  systemLib,
}:
let
  inherit (systemLib) mkSystemBuilder;
  inherit (homeManager) mkSystemHomeConfig;

  mkDarwin = mkSystemBuilder {
    systemBuilder = nix-darwin.lib.darwinSystem;
    homeManagerModule = home-manager.darwinModules;
    homeDir = "/Users";
    inherit mkSystemHomeConfig;
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
