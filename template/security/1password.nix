# 1Password CLI + shell plugins
# Add to baseModules in config.nix to enable
{
  config,
  lib,
  inputs,
  ...
}:
let
  p = config.platform;
in
{
  imports = [ inputs._1password-shell-plugins.hmModules.default ];

  programs._1password-shell-plugins = {
    enable = true;
    plugins = [ ];
  };
}
