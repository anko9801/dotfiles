# File manager with image preview support
_:

{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    settings.manager = {
      show_hidden = true;
      sort_by = "natural";
      sort_dir_first = true;
      ratio = [
        0
        1
        0
      ]; # Simple single-column display
    };
  };
}
