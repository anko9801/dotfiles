{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Additional git tools
    gibo # .gitignore templates
    git-lfs # Git Large File Storage
    git-wt # Git worktree management
  ];
}
