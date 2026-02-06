{ config, ... }:

{
  programs.zellij.enable = true;

  # Use mkOutOfStoreSymlink for instant config changes (no home-manager switch needed)
  # Edit ~/dotfiles/home/terminal/zellij/config.kdl directly
  xdg.configFile."zellij/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/home/terminal/zellij/config.kdl";
}
