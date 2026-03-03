{ lib, config, ... }:

{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = false;
    extraConfig = lib.mkAfter (builtins.readFile ./config.lua);
  };

  # Load wezterm shell integration only when running inside wezterm
  programs.zsh.initContent = lib.mkAfter ''
    if [[ "$TERM_PROGRAM" == "WezTerm" ]]; then
      source "${config.programs.wezterm.package}/etc/profile.d/wezterm.sh"
    fi
  '';
}
