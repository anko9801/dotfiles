_:

{
  home.sessionVariables = {
    FZF_DEFAULT_COMMAND = "fd --type f --hidden --follow --exclude .git";
    FZF_CTRL_T_COMMAND = "fd --type f --hidden --follow --exclude .git";
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = false; # Deferred via zsh-defer (shell/zsh/deferred.nix)
    defaultOptions = [
      "--height=40%"
      "--layout=reverse"
      "--border"
    ];
  };
}
