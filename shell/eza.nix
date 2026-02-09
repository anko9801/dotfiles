_:

{
  programs.eza = {
    enable = true;
    enableZshIntegration = false; # Deferred in zsh.nix for faster startup
    icons = "auto";
    git = true;
  };
}
