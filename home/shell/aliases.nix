# Common shell aliases shared across zsh, fish, and bash
# Shell-specific abbreviations remain in their respective configs
{ config, ... }:

{
  home.shellAliases = {
    # Modern CLI replacements
    ls = "eza";
    ll = "eza -la";
    la = "eza -a";
    lt = "eza --tree";
    cat = "bat";
    find = "fd";
    grep = "rg";
    top = "btm";
    du = "dust";
    ps = "procs";

    # Safety (trashy is Linux-only; macOS uses trash from Homebrew)
    rm = if config.platform.isLinux then "trash" else "rm -i";
    cp = "cp -i";
    mv = "mv -i";
    mkdir = "mkdir -p";

    # Shortcuts
    v = "nvim";
    vim = "nvim";
    lg = "lazygit";
  };
}
