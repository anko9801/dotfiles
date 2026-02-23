# Shared shell defaults
{ lib, ... }:

{
  options.shell = {
    historySize = lib.mkOption {
      type = lib.types.int;
      default = 10000;
      description = "Number of history entries to keep";
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
      ];
      description = "Commands to exclude from history";
    };
  };
}
