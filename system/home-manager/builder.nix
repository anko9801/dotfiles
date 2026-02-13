# Standalone Home Manager configuration (for Linux/WSL)
{
  nixpkgs,
  home-manager,
  nix-index-database,
  nixvim,
  stylix,
  shared,
  llm-agents ? null,
  agent-skills ? null,
  antfu-skills ? null,
}:
let
  inherit (shared) username userConfig mkSpecialArgs;

  # User-defined modules from config.nix
  userModules = userConfig.modules or [ ];

  # Platform-specific modules
  platformModules = {
    wsl = [ ../../terminal/zellij ];
    desktop = [ ../../desktop ];
    server = [
      ../../editor/vim.nix
      ../../tools/git
      ../../tools/cli.nix
      ../../tools/bat.nix
      ../../terminal/tmux.nix
    ];
  };

  # Common modules for home-manager (also used by darwin/nixos)
  commonModules = [
    # Core
    ./core.nix
    # Unified defaults (includes capabilities)
    ../defaults.nix
    # Dev
    ../../dev/build-tools.nix
    ../../dev/go.nix
    ../../dev/mise.nix
    ../../dev/nix.nix
    ../../dev/node.nix
    ../../dev/python.nix
    ../../dev/rust.nix
    # Security
    ../../security/1password.nix
    ../../security/gitleaks.nix
    ../../security/gpg.nix
    ../../security/ssh.nix
    # Shell
    ../../shell/aliases.nix
    ../../shell/atuin.nix
    ../../shell/bash.nix
    ../../shell/defaults.nix
    ../../shell/eza.nix
    ../../shell/fish.nix
    ../../shell/fzf.nix
    ../../shell/readline.nix
    ../../shell/starship.nix
    ../../shell/zoxide.nix
    ../../shell/zsh
    # Theme
    ../../theme/catppuccin-mocha.nix
    ../../theme/default.nix
    # External
    nix-index-database.homeModules.nix-index
    nixvim.homeModules.nixvim
    stylix.homeModules.stylix
  ]
  ++ (if agent-skills != null then [ agent-skills.homeManagerModules.default ] else [ ]);

  # Home Manager config for system integration (darwin/nixos modules)
  # Used when home-manager is embedded in nix-darwin or NixOS
  mkSystemHomeConfig =
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

  # Standalone home-manager configuration (no system integration)
  # Used for pure home-manager setups (WSL, non-NixOS Linux)
  mkStandaloneHome =
    {
      system,
      homeModules ? [ ],
    }:
    let
      pkgs = import nixpkgs { inherit system; };
      # AI tools from llm-agents flake
      llmAgentsPkgs = if llm-agents != null then llm-agents.packages.${system} or { } else { };
    in
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = mkSpecialArgs system // {
        inherit llmAgentsPkgs antfu-skills;
      };
      modules =
        commonModules
        ++ userModules
        ++ homeModules
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
    platformModules
    mkSystemHomeConfig
    mkStandaloneHome
    ;
}
