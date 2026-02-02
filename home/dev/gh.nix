_:

{
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
      aliases = {
        co = "pr checkout";
        pv = "pr view";
        pc = "pr create";
        pm = "pr merge";
        il = "issue list";
        ic = "issue create";
        iv = "issue view";
      };
    };
  };
}
