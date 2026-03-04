# Delta (git diff pager) configuration
{ lib, config, ... }:

{
  options.tools.git.pager = {
    command = lib.mkOption {
      type = lib.types.str;
      default = "delta";
      description = "Git pager command";
    };
    interactiveFilter = lib.mkOption {
      type = lib.types.str;
      default = "delta --color-only";
      description = "Git interactive diff filter";
    };
    lazygitArgs = lib.mkOption {
      type = lib.types.str;
      default = "delta --dark --paging=never";
      description = "Pager command for lazygit";
    };
  };

  config.programs.delta = {
    enable = true;
    options = {
      navigate = true;
      line-numbers = true;
      side-by-side = true;
      syntax-theme = "TwoDark";
      features = "decorations";
      hyperlinks = true;
      hyperlinks-file-link-format = "vscode://file/{path}:{line}";
      blame-palette = "${config.theme.colors.base} ${config.theme.colors.surface0} ${config.theme.colors.surface1}";
      decorations = {
        commit-decoration-style = "bold yellow box ul";
        file-style = "bold yellow ul";
        file-decoration-style = "none";
        hunk-header-decoration-style = "cyan box ul";
      };
    };
  };
}
