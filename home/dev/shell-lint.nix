{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Shell script linter & formatter
    shellcheck
    shfmt
  ];
}
