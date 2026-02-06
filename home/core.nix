{ versions, ... }:

let
  isCI = builtins.getEnv "CI" != "";
in
{
  home = {
    stateVersion = versions.home;
    sessionVariables.LANG = "ja_JP.UTF-8";
    sessionPath = [ "$HOME/.local/bin" ];
  };

  # Disable systemd user service management in CI (runner/activation user mismatch)
  systemd.user.startServices = if isCI then false else "sd-switch";

  xdg.enable = true;
  programs.home-manager.enable = true;
}
