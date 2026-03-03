_:

{
  home.sessionVariables._ZO_DOCTOR = "0";

  programs.zoxide = {
    enable = true;
    enableZshIntegration = false;
    options = [
      "--cmd"
      "cd"
    ];
  };
}
