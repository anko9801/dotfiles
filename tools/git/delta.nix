# Delta (git diff pager) configuration
_:

{
  programs.delta = {
    enable = true;
    options = {
      navigate = true;
      line-numbers = true;
      side-by-side = true;
      syntax-theme = "TwoDark";
      features = "decorations";
      hyperlinks = true;
      hyperlinks-file-link-format = "vscode://file/{path}:{line}";
      blame-palette = "#1e1e2e #313244 #45475a";
      decorations = {
        commit-decoration-style = "bold yellow box ul";
        file-style = "bold yellow ul";
        file-decoration-style = "none";
        hunk-header-decoration-style = "cyan box ul";
      };
    };
  };
}
