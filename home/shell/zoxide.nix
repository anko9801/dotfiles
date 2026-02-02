_:

{
  home.sessionVariables._ZO_DOCTOR = "0";

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [
      "--cmd"
      "cd"
    ];
  };
}
