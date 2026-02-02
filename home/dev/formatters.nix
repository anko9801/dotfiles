{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Multi-language formatters
    treefmt

    # EditorConfig support
    editorconfig-core-c

    # YAML linter
    yamllint

    # Markdown linter
    markdownlint-cli
  ];
}
