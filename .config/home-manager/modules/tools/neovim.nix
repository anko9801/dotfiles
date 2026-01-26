{ config, pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # Plugins from nixpkgs (optional - can also use lazy.nvim)
    # plugins = with pkgs.vimPlugins; [
    #   nvim-treesitter.withAllGrammars
    # ];

    # Extra packages available to neovim
    extraPackages = with pkgs; [
      # LSP servers
      lua-language-server
      nil  # Nix LSP

      # Formatters
      stylua
      nixfmt

      # Linters (additional)
      selene  # Lua linter

      # Tools for plugins
      tree-sitter
      nodejs  # For some plugins
    ];
  };
}
