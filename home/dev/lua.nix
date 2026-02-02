{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Lua LSP
    lua-language-server
  ];
}
