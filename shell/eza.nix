_:

{
  programs.eza = {
    enable = true;
    enableZshIntegration = false; # Deferred via zsh-defer (shell/zsh/deferred.nix)
    icons = "auto";
    git = true;
  };
}
