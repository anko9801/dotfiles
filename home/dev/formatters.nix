{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Multi-language formatters
    treefmt

    # EditorConfig support
    editorconfig-core-c

    # Shell script
    shellcheck
    shfmt

    # YAML
    yamllint

    # Markdown
    markdownlint-cli
  ];
}
