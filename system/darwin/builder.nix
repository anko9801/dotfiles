# nix-darwin configuration (for macOS)
{
  nix-darwin,
  nix-homebrew,
  home-manager,
  homeManager,
  systemLib,
}:
let
  inherit (systemLib)
    username
    allHosts
    mkSystemSpecialArgs
    ;
  inherit (homeManager) mkSystemHomeConfig;

  # Get host modules from config.nix (already includes baseModules)
  getHostModules = hostName: (allHosts.${hostName} or { }).modules or [ ];

  mkDarwin =
    { self, inputs }:
    {
      system,
      hostName,
      extraModules ? [ ],
      homeModules ? [ ],
    }:
    let
      hostModules = getHostModules hostName ++ homeModules;
    in
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
        (mkSystemHomeConfig {
          inherit system hostModules;
          homeDir = "/Users";
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
