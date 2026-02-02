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

  # Additional packages
  home.packages =
    with pkgs;
    [
      # System info
      onefetch # Git repository info

      # Network
      nmap # Network scanner

      # File management
      ouch # Compression tool

      # JSON/Data
      dasel # Query/modify data formats

      # Git extras
      git-absorb # Auto-fixup commits
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      trashy # Trash CLI (Linux only)
    ];

}
