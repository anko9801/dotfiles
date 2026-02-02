{ pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      nodePackages.typescript-language-server
      oxlint
    ];
    sessionVariables.NODE_OPTIONS = "--max-old-space-size=4096";
    sessionPath = [ "$HOME/.npm-global/bin" ];
  };

  programs.npm = {
    enable = true;
    settings = {
      prefix = "~/.npm-global";
      fund = false;
      audit = false;
    };
  };
}
