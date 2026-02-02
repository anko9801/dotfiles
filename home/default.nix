{
  ...
}:

{
  imports = [
    ./shell
    ./editor
    ./dev
    ./tools
    ./security
  ];

  home = {
    stateVersion = "24.11";
    sessionVariables.LANG = "ja_JP.UTF-8";
    sessionPath = [ "$HOME/.local/bin" ];
  };

  xdg.enable = true;
  programs.home-manager.enable = true;
}
