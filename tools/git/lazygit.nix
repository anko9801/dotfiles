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
        pagers = [
          {
            pager = "delta --dark --paging=never";
            colorArg = "always";
            externalDiffCommand = "difft --color=always --display=inline";
          }
        ];
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
      customCommands = [
        {
          key = "C";
          context = "files";
          command = "czg";
          description = "Commit with czg (conventional + emoji)";
          loadingText = "Opening czg...";
          output = "terminal";
        }
      ];
      os = {
        editPreset = "nvim";
      };
    };
  };
}
