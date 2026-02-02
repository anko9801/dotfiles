_:

{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      search_mode = "fuzzy";
      filter_mode = "global";
      filter_mode_shell_up_key_binding = "session";
      show_preview = true;
      invert = false;
      exit_mode = "return-query";
      style = "auto";
      max_history_length = 10000;
      history_filter = [
        "^ls"
        "^cd"
        "^pwd"
        "^exit"
        "^history"
        "^clear"
      ];
      enter_accept = true;
      secrets_filter = true;
      show_help = false;
    };
  };
}
