{ config, dotfilesPath, ... }:

{
  programs.zellij.enable = true;

  xdg.configFile."zellij/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/terminal/zellij/config.kdl";
}
