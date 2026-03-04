_:

{
  home.sessionVariables._ZO_DOCTOR = "0";

  programs.zoxide = {
    enable = true;
    enableZshIntegration = false; # Deferred via zsh-defer (shell/zsh/deferred.nix)
    options = [
      "--cmd"
      "cd"
    ];
  };
}
