{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Python LSP
    pyright

    # Python linter & formatter
    ruff
  ];
}
