# Development tools configuration (pre-commit, treefmt, devShell)
{ config, pkgs, ... }:
{
  # Pre-commit hooks
  pre-commit = {
    check.enable = false;
    settings.hooks = {
      treefmt = {
        enable = true;
        package = config.treefmt.build.wrapper;
      };
      deadnix.enable = true;
      statix.enable = true;
    };
  };

  # Treefmt with extended formatters
  treefmt = {
    projectRootFile = "flake.nix";
    programs = {
      nixfmt.enable = true;
      shfmt.enable = true;
      yamlfmt.enable = true;
    };
    settings = {
      global.excludes = [
        ".git/**"
        "*.lock"
      ];
      formatter = {
        fish-indent = {
          command = "${pkgs.fish}/bin/fish_indent";
          options = [ "--write" ];
          includes = [ "*.fish" ];
        };
        gitleaks = {
          command = "${pkgs.gitleaks}/bin/gitleaks";
          options = [
            "detect"
            "--no-git"
            "--exit-code"
            "0"
          ];
          includes = [ "*" ];
          excludes = [
            "*.png"
            "*.jpg"
            "*.gif"
            "node_modules/**"
            ".direnv/**"
          ];
        };
      };
    };
  };

  # DevShell with pre-commit hooks
  devShells.default = pkgs.mkShell {
    shellHook = config.pre-commit.installationScript;
    packages = with pkgs; [
      statix
      deadnix
      nvd
    ];
  };
}
