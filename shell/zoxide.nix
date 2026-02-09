_:

{
  home.sessionVariables._ZO_DOCTOR = "0";

  programs.zoxide = {
    enable = true;
    enableZshIntegration = false; # Deferred in zsh.nix for faster startup
    options = [
      "--cmd"
      "cd"
    ];
  };
}
