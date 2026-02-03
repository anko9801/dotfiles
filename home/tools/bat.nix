_:

{
  programs.bat = {
    enable = true;
    config = {
      # Theme managed by Stylix
      style = "numbers,changes,header";
      pager = "less -FR";
    };
  };
}
