# File manager with image preview support
{ ... }:

{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    settings.manager = {
      show_hidden = true;
      sort_by = "natural";
      sort_dir_first = true;
    };
  };
}
