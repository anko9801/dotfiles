# winget configure packages (WHM module)
_: {
  programs.winget = {
    enable = true;

    manager = {
      useLatest = true;
    };

    assertions = [
      {
        resource = "Microsoft.Windows.Developer/OsVersion";
        allowPrerelease = true;
        settings.MinVersion = "10.0.22621";
      }
    ];

    packages = [
      # System
      "7zip.7zip"
      "Microsoft.PowerShell"
      "Microsoft.WindowsTerminal"
      "Microsoft.PowerToys"

      # Dev
      "Git.Git"
      "GitHub.cli"
      "dandavison.delta"
      "sharkdp.fd"
      "BurntSushi.ripgrep.MSVC"
      "sharkdp.bat"
      "junegunn.fzf"
      "JesseDuffield.lazygit"
      "eza-community.eza"
      "Microsoft.VisualStudioCode"
      "ZedIndustries.Zed"
      "Docker.DockerDesktop"
      "GoLang.Go"

      # Browser / Apps
      "Google.Chrome"
      "AgileBits.1Password"
      "AgileBits.1Password.CLI"
      "Anthropic.Claude"
      "Notion.Notion"
      "Obsidian.Obsidian"
      "SlackTechnologies.Slack"
      "Zoom.Zoom"
      "Discord.Discord"
      "Spotify.Spotify"
      "VideoLAN.VLC"
      "OBSProject.OBSStudio"

      # Networking
      "Tailscale.Tailscale"
      "Parsec.Parsec"

      # Shell
      "Starship.Starship"
      "ajeetdsouza.zoxide"

      # Input
      "jtroo.kanata_gui"
      "nathancorvussolis.corvusskk"

      # Utilities
      "AntibodySoftware.WizTree"
      "FilesCommunity.Files"
      "voidtools.Everything"
      "Ditto.Ditto"
      "ShareX.ShareX"
      "xanderfrangos.twinkletray"
      "TrackerSoftware.PDF-XChangeEditor"
      "SumatraPDF.SumatraPDF"
      "REALiX.HWiNFO"
      "DevToys-app.DevToys"
      "File-New-Project.EarTrumpet"

      # Window Manager
      "LGUG2Z.komorebi"
      "LGUG2Z.whkd"
    ];
  };
}
