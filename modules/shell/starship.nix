{
  lib,
  ...
}:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      # Inspired by Ayu Mirage color palette
      # Colors: #707A8C (gray) / #5CCFE6 (cyan) / #73D0FF (blue) / #FFAD66 (orange)
      #         #87D96C (green) / #F27983 (red) / #F28779 (light red) / #DFBFFF (purple)

      format = lib.concatStrings [
        "[╭─ ](bold green)"
        "$directory"
        "$git_branch$git_commit$git_state$git_status"
        "$nodejs$python$rust$golang$java$kotlin$scala$swift"
        "$aws$gcloud$azure"
        "$docker_context$package"
        "$cmd_duration"
        "\n$character"
      ];

      add_newline = true;

      username = {
        show_always = false;
        style_user = "fg:#DFBFFF";
        style_root = "fg:#F27983";
        format = "[$user]($style)";
      };

      hostname = {
        ssh_only = true;
        format = "[@$hostname]($style) ";
        style = "fg:#DFBFFF";
      };

      directory = {
        style = "fg:#FFAD66";
        read_only = " ";
        read_only_style = "fg:#707A8C";
        format = "[$read_only]($read_only_style)[$path]($style) ";
        truncate_to_repo = true;
        truncation_length = 3;
      };

      character = {
        error_symbol = ''[╰─\(*;-;\)](bold green) [❯](bold red)'';
        success_symbol = ''[╰─\(*'-'\) ❯](bold green)'';
        vimcmd_symbol = ''[╰─\(*'o'\) ](bold cyan)'';
      };

      git_branch = {
        format = "[on](white) [$symbol$branch(:$remote_branch)]($style) ";
        symbol = " ";
        style = "fg:#5CCFE6";
        truncation_length = 20;
        truncation_symbol = "…";
      };

      git_commit = {
        commit_hash_length = 7;
        format = "[\\($tag$hash\\)]($style) ";
        only_detached = true;
        tag_disabled = false;
        tag_symbol = " ";
        style = "fg:#5CCFE6";
      };

      git_state = {
        format = "[\\($state( $progress_current/$progress_total)\\) ]($style)";
        style = "fg:#5CCFE6";
        rebase = "REBASING";
        merge = "MERGING";
        revert = "REVERTING";
        cherry_pick = "CHERRY-PICKING";
        bisect = "BISECTING";
        am = "AM";
        am_or_rebase = "AM/REBASE";
      };

      git_status = {
        format = "[\\[$all_status$ahead_behind\\] ]($style)";
        style = "fg:#5CCFE6";
        conflicted = "=";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        up_to_date = "";
        untracked = "?\${count}";
        stashed = ''\\$''${count}'';
        modified = "!\${count}";
        staged = "+\${count}";
        renamed = "»\${count}";
        deleted = "✘\${count}";
      };

      cmd_duration = {
        min_time = 3000;
        format = "[ $duration]($style) ";
        style = "fg:#F28779";
        show_notifications = false;
      };

      docker_context = {
        symbol = " ";
        style = "fg:#73D0FF";
        format = "[$symbol $context]($style) ";
      };

      nodejs = {
        format = "[via](white) [$symbol($version )]($style)";
        symbol = " ";
        style = "fg:#87D96C";
        detect_extensions = [
          "js"
          "mjs"
          "cjs"
          "ts"
          "mts"
          "cts"
        ];
      };

      python = {
        format = ''[via](white) [''${symbol}''${pyenv_prefix}($version )(\($virtualenv\) )]($style)'';
        symbol = " ";
        style = "fg:#73D0FF";
      };

      rust = {
        format = "[via](white) [$symbol($version )]($style)";
        symbol = " ";
        style = "fg:#F28779";
      };

      golang = {
        format = "[via](white) [$symbol($version )]($style)";
        symbol = "🐹 ";
        style = "fg:#5CCFE6";
      };

      java = {
        format = "[via](white) [$symbol($version )]($style)";
        symbol = " ";
        style = "fg:#F28779";
      };

      package = {
        format = "[$symbol$version]($style) ";
        symbol = "󰏗 ";
        style = "fg:#FFAD66";
      };

      aws = {
        format = "[on](white) [☁️  ($profile )(\\($region\\))]($style) ";
        style = "fg:#FFAD66";
        symbol = " ";
      };

      gcloud = {
        format = "[on](white) [☁️  ($project )(\\($region\\))]($style) ";
        style = "fg:#73D0FF";
      };

      azure = {
        format = "[on](white) [☁️  ($subscription)]($style) ";
        style = "fg:#73D0FF";
      };

      memory_usage = {
        disabled = true;
        threshold = -1;
        format = "[󰍛 \${ram_pct}]($style) ";
        style = "fg:#707A8C";
      };

      time = {
        disabled = true;
        format = "[$time]($style) ";
        style = "fg:#707A8C";
        time_format = "%R";
      };
    };
  };
}
