# nix-darwin configuration (for macOS)
{
  nix-darwin,
  nix-homebrew,
  home-manager,
  homeManager,
  shared,
}:
let
  inherit (shared) username mkSystemSpecialArgs;
  inherit (homeManager) mkHomeManagerConfig;

  mkDarwin =
    { self, inputs }:
    {
      system,
      extraModules ? [ ],
      homeModules ? [ ],
    }:
    nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = mkSystemSpecialArgs { inherit self inputs; } system;
      modules = [
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

        # Home Manager as nix-darwin module
        home-manager.darwinModules.home-manager
        (mkHomeManagerConfig {
          inherit system;
          homeDir = "/Users";
          extraImports = homeModules;
        })

        # Override system.primaryUser for the specific user
        {
          system.primaryUser = username;
        }
      ]
      ++ extraModules;
    };
in
{
  inherit mkDarwin;
}
