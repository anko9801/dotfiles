{
  pkgs,
  ...
}:

{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    # Disable aliases to avoid conflict with vim
    viAlias = false;
    vimAlias = false;
    vimdiffAlias = false;

    # Performance: byte compilation
    performance.byteCompileLua = {
      enable = true;
      nvimRuntime = true;
      configs = true;
      plugins = true;
    };

    # Colorscheme
    colorschemes.tokyonight = {
      enable = true;
      settings = {
        style = "night";
        transparent = false;
        terminal_colors = true;
        styles = {
          comments.italic = true;
          keywords.italic = true;
          sidebars = "dark";
          floats = "dark";
        };
      };
    };

    # Extra packages (formatters and linters for conform/lint plugins)
    extraPackages = with pkgs; [
      # Formatters
      stylua
      prettierd
      ruff

      # Linters
      eslint_d
    ];
  };
}
