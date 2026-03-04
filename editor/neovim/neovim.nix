{
  pkgs,
  ...
}:

{
  # Disable vim's defaultEditor when using nixvim
  programs.vim.defaultEditor = false;

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

    # Colorscheme managed by Stylix

    # Extra packages (formatters and linters for conform/lint plugins)
    extraPackages = with pkgs; [
      # Formatters
      stylua
      prettierd

      # Linters
      eslint_d

      # LSPs (not managed by dev modules)
      lua-language-server
      yaml-language-server
    ];
  };
}
