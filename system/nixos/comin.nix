{
  services.comin = {
    enable = true;
    remotes = [
      {
        name = "origin";
        url = "https://github.com/anko9801/dotfiles.git";
        poller.period = 300;
        branches.main.name = "master";
      }
    ];
  };
}
