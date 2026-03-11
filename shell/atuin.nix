{
  config,
  lib,
  pkgs,
  ...
}:

let
  p = config.platform;
in
{
  programs.atuin = {
    enable = true;
    enableZshIntegration = false; # Deferred via zsh-defer (shell/zsh/deferred.nix)
    settings = {
      search_mode = "fuzzy";
      filter_mode = "global";
      filter_mode_shell_up_key_binding = "session";
      show_preview = true;
      invert = false;
      exit_mode = "return-query";
      style = "auto";
      max_history_length = config.shell.historySize;
      history_filter = map (pat: "^${pat}") config.shell.historyIgnorePatterns;
      enter_accept = true;
      secrets_filter = true;
      show_help = false;
    };
  };

  # Auto-sync timer (hourly)
  systemd.user = lib.mkIf (p.os == "linux") {
    timers.atuin-sync = {
      Unit.Description = "Atuin auto sync";
      Timer = {
        OnUnitActiveSec = "1h";
        OnBootSec = "5m";
      };
      Install.WantedBy = [ "timers.target" ];
    };
    services.atuin-sync = {
      Unit.Description = "Atuin auto sync";
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.atuin}/bin/atuin sync";
        IOSchedulingClass = "idle";
      };
    };
  };

  launchd.agents.atuin-sync = lib.mkIf (p.os == "darwin") {
    enable = true;
    config = {
      Label = "com.atuin.sync";
      ProgramArguments = [
        "${pkgs.atuin}/bin/atuin"
        "sync"
      ];
      StartInterval = 3600;
      StandardOutPath = "/tmp/atuin-sync.log";
      StandardErrorPath = "/tmp/atuin-sync.log";
    };
  };
}
