{
  lib,
  ...
}:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      # Colors managed by Stylix (base16 palette)

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
        style_user = "fg:purple";
        style_root = "fg:base0F";
        format = "[$user]($style)";
      };

      hostname = {
        ssh_only = true;
        format = "[@$hostname]($style) ";
        style = "fg:purple";
      };

      directory = {
        style = "fg:yellow";
        read_only = " ";
        read_only_style = "fg:bright-black";
        format = "[$read_only]($read_only_style)[$path]($style) ";
        truncate_to_repo = true;
        truncation_length = 3;
      };

      character = {
        error_symbol = ''[╰─\(*;-;\)](bold green) [❯](bold base0F)'';
        success_symbol = ''[╰─\(*'-'\) ❯](bold green)'';
        vimcmd_symbol = ''[╰─\(*'o'\) ](bold cyan)'';
      };

      git_branch = {
        format = "[on](white) [$symbol$branch(:$remote_branch)]($style) ";
        symbol = " ";
        style = "fg:cyan";
        truncation_length = 20;
        truncation_symbol = "…";
      };

      git_commit = {
        commit_hash_length = 7;
        format = "[\\($tag$hash\\)]($style) ";
        only_detached = true;
        tag_disabled = false;
        tag_symbol = " ";
        style = "fg:cyan";
      };

      git_state = {
        format = "[\\($state( $progress_current/$progress_total)\\) ]($style)";
        style = "fg:cyan";
        rebase = "REBASING";
        merge = "MERGING";
        revert = "REVERTING";
        cherry_pick = "CHERRY-PICKING";
        bisect = "BISECTING";
        am = "AM";
        am_or_rebase = "AM/REBASE";
      };

      git_status = {
        format = "[$conflicted$staged$modified$untracked$renamed$deleted$stashed$stashed_count$ahead_behind]($style) ";
        style = "fg:cyan";
        conflicted = "=";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        up_to_date = "";
        untracked = "?\${count}";
        stashed = "\\$";
        modified = "!\${count}";
        staged = "+\${count}";
        renamed = "»\${count}";
        deleted = "✘\${count}";
      };

      cmd_duration = {
        min_time = 3000;
        format = "[ $duration]($style) ";
        style = "fg:base0F";
        show_notifications = false;
      };

      docker_context = {
        symbol = " ";
        style = "fg:blue";
        format = "[$symbol $context]($style) ";
      };

      nodejs = {
        format = "[via](white) [$symbol($version )]($style)";
        symbol = " ";
        style = "fg:green";
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
        style = "fg:blue";
      };

      rust = {
        format = "[via](white) [$symbol($version )]($style)";
        symbol = " ";
        style = "fg:base0F";
      };

      golang = {
        format = "[via](white) [$symbol($version )]($style)";
        symbol = "🐹 ";
        style = "fg:cyan";
      };

      java = {
        format = "[via](white) [$symbol($version )]($style)";
        symbol = " ";
        style = "fg:base0F";
      };

      package = {
        format = "[$symbol$version]($style) ";
        symbol = "󰏗 ";
        style = "fg:yellow";
      };

      aws = {
        format = "[on](white) [☁️  ($profile )(\\($region\\))]($style) ";
        style = "fg:yellow";
        symbol = " ";
      };

      gcloud = {
        format = "[on](white) [☁️  ($project )(\\($region\\))]($style) ";
        style = "fg:blue";
      };

      azure = {
        format = "[on](white) [☁️  ($subscription)]($style) ";
        style = "fg:blue";
      };

      memory_usage = {
        disabled = true;
        threshold = -1;
        format = "[󰍛 \${ram_pct}]($style) ";
        style = "fg:bright-black";
      };

      time = {
        disabled = true;
        format = "[$time]($style) ";
        style = "fg:bright-black";
        time_format = "%R";
      };
    };
  };
}
