# Shared shell configuration defaults
{ lib, ... }:

{
  options.shell = {
    historySize = lib.mkOption {
      type = lib.types.int;
      default = 10000;
      description = "Number of history entries to keep in memory and file";
    };

    historyIgnorePatterns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "ls"
        "cd"
        "pwd"
        "exit"
        "clear"
        "history"
        "fg"
        "bg"
        "jobs"
      ];
      description = "Commands to exclude from history (prefix match)";
    };

    fzf = {
      height = lib.mkOption {
        type = lib.types.str;
        default = "40%";
        description = "FZF popup height";
      };

      defaultFlags = lib.mkOption {
        type = lib.types.str;
        default = "--height=40% --layout=reverse --border";
        description = "Default FZF flags for custom functions";
      };
    };
  };
}
