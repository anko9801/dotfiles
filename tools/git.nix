# Git — version control
{ config, ... }:

let
  inherit (config.defaults.identity) name email;
in
{
  programs.git = {
    enable = true;

    settings = {
      user = { inherit name email; };

      alias = {
        st = "status -sb";
        lg = "log --graph --all --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --abbrev-commit";
        sw = "switch";
        ps = "push";
        pl = "pull";
      };

      color.ui = "auto";
      init.defaultBranch = "main";

      core = {
        autocrlf = false;
        quotepath = false;
        inherit (config.defaults) editor;
      };

      diff.algorithm = "histogram";

      pull = {
        ff = "only";
        rebase = true;
      };

      push = {
        autoSetupRemote = true;
        default = "current";
      };

      fetch = {
        prune = true;
        all = true;
      };

      rebase = {
        autostash = true;
        autosquash = true;
      };

      rerere.enabled = true;
      commit.verbose = true;
    };

    ignores = [
      ".DS_Store"
      "Thumbs.db"
      "*.swp"
      "*.swo"
      "*~"
      ".idea/"
      ".vscode/"
      "node_modules/"
      "__pycache__/"
      ".env"
      ".env.local"
      ".direnv/"
    ];
  };
}
