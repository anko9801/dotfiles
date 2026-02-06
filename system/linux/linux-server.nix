# Server platform configuration
# Lightweight setup for remote servers
{ pkgs, lib, ... }:

{
  imports = [
    ../../home/editor/vim.nix
    ../../home/tools/git
    ../../home/tools/cli.nix
    ../../home/tools/bat.nix
    ../../home/tools/tmux.nix
  ];

  home = {
    packages = with pkgs; [
      # Essential tools
      git
      curl
      wget
      htop

      tree
      jq
      ripgrep
      fd

      # Network tools
      netcat
      dig
    ];

    sessionVariables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };
  };

  programs = {
    # Use Vim as default editor on servers
    vim.defaultEditor = true;

    # Basic shell setup (inherits aliases from home/shell/aliases.nix)
    bash.enable = true;

    # Git with minimal config
    git = {
      enable = true;
      settings = {
        core.editor = lib.mkForce "vim";
      };
    };

  };
}
