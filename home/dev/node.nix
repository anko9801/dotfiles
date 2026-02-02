{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # TypeScript/JavaScript LSP
    nodePackages.typescript-language-server

    # JavaScript/TypeScript linter
    oxlint
  ];
}
