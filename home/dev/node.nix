{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nodePackages.typescript-language-server
    oxlint
  ];

  programs.npm = {
    enable = true;
    settings = {
      prefix = "~/.npm-global";
      fund = false;
      audit = false;
    };
  };
}
