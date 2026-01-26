{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.packages = with pkgs; [
    # JavaScript/TypeScript linting
    oxlint # Fast JS/TS linter (new addition)

    # Multi-language formatters
    treefmt # One CLI to format the code tree

    # Shell
    shellcheck # Shell script linter
    shfmt # Shell script formatter

    # Nix
    nixfmt # Nix formatter
    nil # Nix language server
    statix # Nix linter

    # YAML/JSON
    yamllint # YAML linter

    # Markdown
    markdownlint-cli # Markdown linter

    # Security
    gitleaks # Secret detection
    trivy # Vulnerability scanner

    # General
    editorconfig-core-c # EditorConfig support
  ];
}
