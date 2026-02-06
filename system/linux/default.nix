# Standalone Home Manager configuration (for Linux/WSL)
{
  nixpkgs,
  home-manager,
  nix-index-database,
  nixvim,
  stylix,
  common,
}:
let
  inherit (common) username mkSpecialArgs;

  # Common modules for home-manager (also used by darwin/nixos)
  commonModules = [
    # Core
    ../../home/core.nix
    # Dev
    ../../home/dev/build-tools.nix
    ../../home/dev/go.nix
    ../../home/dev/mise.nix
    ../../home/dev/nix.nix
    ../../home/dev/node.nix
    ../../home/dev/python.nix
    ../../home/dev/rust.nix
    # Security
    ../../home/security/1password.nix
    ../../home/security/gitleaks.nix
    ../../home/security/gpg.nix
    ../../home/security/ssh.nix
    # Shell
    ../../home/shell/defaults.nix
    ../../home/shell/aliases.nix
    ../../home/shell/atuin.nix
    ../../home/shell/bash.nix
    ../../home/shell/eza.nix
    ../../home/shell/fish.nix
    ../../home/shell/fzf.nix
    ../../home/shell/readline.nix
    ../../home/shell/starship.nix
    ../../home/shell/zoxide.nix
    ../../home/shell/zsh
    # Theme
    ../../theme/catppuccin-mocha.nix
    ../../theme/default.nix
    # External
    nix-index-database.homeModules.nix-index
    nixvim.homeModules.nixvim
    stylix.homeModules.stylix
  ];

  # Configuration for system modules (darwin/nixos)
  mkHomeManagerConfig =
    {
      system,
      homeDir,
      extraImports ? [ ],
    }:
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = mkSpecialArgs system;
        users.${username} =
          { lib, ... }:
          {
            imports = commonModules ++ extraImports;
            home = {
              username = lib.mkForce username;
              homeDirectory = lib.mkForce "${homeDir}/${username}";
            };
          };
      };
    };

  # Standalone home-manager configuration
  mkHome =
    {
      system,
      extraModules ? [ ],
    }:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = mkSpecialArgs system;
      modules =
        commonModules
        ++ extraModules
        ++ [
          {
            home = {
              inherit username;
              homeDirectory = "/home/${username}";
            };
            nix.package = pkgs.nix;
          }
        ];
    };
in
{
  inherit
    commonModules
    mkHomeManagerConfig
    mkHome
    ;
}
