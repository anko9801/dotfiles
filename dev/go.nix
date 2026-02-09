{ pkgs, ... }:

{
  home = {
    packages = [ pkgs.gopls ];
    sessionVariables.GOPATH = "$HOME/go";
    sessionPath = [ "$HOME/go/bin" ];
  };
}
