_:

{
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        showIcons = true;
        theme = {
          lightTheme = false;
          activeBorderColor = [
            "green"
            "bold"
          ];
          inactiveBorderColor = [ "white" ];
          selectedLineBgColor = [ "reverse" ];
        };
      };
      git = {
        paging = {
          colorArg = "always";
          pager = "delta --dark --paging=never";
        };
        commit = {
          signOff = false;
        };
        merging = {
          manualCommit = false;
          args = "";
        };
      };
      keybinding = {
        universal = {
          quit = "q";
          quit-alt1 = "<c-c>";
        };
      };
      os = {
        editPreset = "nvim";
      };
    };
  };
}
