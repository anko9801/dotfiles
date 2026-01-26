{
  pkgs,
  lib,
  ...
}:

{
  # Additional useful programs

  # dircolors - LS_COLORS configuration
  programs.dircolors = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = ''
      # Directories
      DIR 01;34
      LINK 01;36
      EXEC 01;32

      # Archives
      .tar 01;31
      .gz 01;31
      .zip 01;31
      .7z 01;31

      # Media
      .jpg 01;35
      .png 01;35
      .mp3 00;36
      .mp4 00;36

      # Code
      .py 00;33
      .js 00;33
      .ts 00;33
      .rs 00;33
      .go 00;33
      .nix 00;33
    '';
  };

  # noti - notifications when commands complete
  programs.noti = {
    enable = true;
    settings = {
      say = {
        voice = "Alex";
      };
    };
  };

  # Additional packages
  home.packages =
    with pkgs;
    [
      # System info
      neofetch # System info display
      onefetch # Git repository info

      # Development
      just # Command runner (like make but simpler)
      direnv # Per-directory environment

      # Productivity
      taskwarrior3 # Task management
      timewarrior # Time tracking

      # Network
      mtr # Network diagnostic tool
      nmap # Network scanner
      doggo # DNS client (dig replacement)

      # File management
      ouch # Compression tool

      # JSON/Data
      fx # JSON viewer
      dasel # Query/modify data formats

      # Git extras
      git-absorb # Auto-fixup commits
      git-branchless # Stacked diffs workflow
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      trashy # Trash CLI (Linux only)
    ];

  # Taskwarrior configuration
  home.file.".taskrc".text = ''
    data.location=~/.local/share/task
    color.active=bold white on green
    color.due=red
    color.due.today=bold red
    color.overdue=bold white on red
    color.tagged=yellow
    weekstart=monday
    default.command=next limit:10
  '';
}
