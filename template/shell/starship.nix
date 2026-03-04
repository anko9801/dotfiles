# baseModule: cross-shell prompt
{ lib, config, ... }:
{
  programs.starship = {
    enable = true;

    settings = lib.mkMerge [
      (lib.mkIf (!config.defaults.terminal.nerdFonts) {
        character.success_symbol = lib.mkDefault "[>](green)";
        git_branch.symbol = lib.mkDefault "";
      })
      {
        format = "$directory$git_branch$git_status$cmd_duration\n$character";
        add_newline = true;

        directory = {
          truncation_length = 3;
          truncate_to_repo = true;
        };

        character = {
          success_symbol = "[>](green)";
          error_symbol = "[>](red)";
        };

        git_branch = {
          format = "on [$branch(:$remote_branch)]($style) ";
          style = "cyan";
        };

        git_status = {
          format = "[$all_status$ahead_behind]($style) ";
          style = "cyan";
        };

        cmd_duration = {
          min_time = 3000;
          format = "[$duration]($style) ";
        };
      }
    ];
  };
}
