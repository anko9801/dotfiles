_:

{
  programs.zsh.shellAliases = {
    # Safety and utility (trashy - trash-cli compatible)
    rm = "trash";
    cp = "cp -i";
    mv = "mv -i";
    mkdir = "mkdir -p";

    # Modern CLI replacements
    ls = "eza";
    ll = "eza -l";
    la = "eza -la";
    lt = "eza --tree";
    lta = "eza --tree -a";
    cat = "bat";
    find = "fd";
    grep = "rg";
    top = "btm";
    htop = "btm";
    du = "dust";
    ps = "procs";
    sed = "sd";
    df = "df -h";
    free = "free -h";

    # Navigation
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    dl = "cd ~/Downloads";
    dt = "cd ~/Desktop";
    pj = "cd ~/repos";
    dot = "cd ~/dotfiles";

    # Git (using git aliases)
    g = "git";
    gst = "git st";
    gsw = "git sw";
    gf = "git f";
    gpl = "git pl";
    gps = "git ps";
    glg = "git lg";
    gla = "git la";
    gdf = "git df";
    gstaged = "git staged";
    gamend = "git amend";
    gundo = "git undo";
    gunstage = "git unstage";
    gcleanup = "git cleanup";
    gopen = "git open";
    gc = "ghq get";

    # Docker
    d = "docker";
    dc = "docker-compose";
    dps = "docker ps";
    dpsa = "docker ps -a";
    di = "docker images";
    drm = "docker rm";
    drmi = "docker rmi";

    # Editors
    v = "vim";
    nv = "nvim";
    c = "code";

    # zellij (tmux removed in favor of zellij)
    zj = "zellij";
    zja = "zellij attach";
    zjn = "zellij -s";
    zjl = "zellij list-sessions";
    zjk = "zellij kill-session";

    # Tools
    lg = "lazygit";

    # Development
    py = "python3";
    pip = "uv pip";
    venv = "uv venv";

    # GitHub CLI
    ghpr = "gh pr create";
    ghpv = "gh pr view";
    ghpl = "gh pr list";
    ghrc = "gh repo clone";
    ghrv = "gh repo view --web";

    # ghq
    gql = "ghq list";
    gqr = "ghq root";

    # Misc
    h = "history";
    j = "jobs";
    reload = "source ~/.zshrc";
  };
}
