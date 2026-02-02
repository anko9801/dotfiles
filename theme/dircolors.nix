_:

{
  programs.dircolors = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = ''
      DIR 01;34
      LINK 01;36
      EXEC 01;32
      .tar 01;31
      .gz 01;31
      .zip 01;31
      .7z 01;31
      .jpg 01;35
      .png 01;35
      .mp3 00;36
      .mp4 00;36
      .py 00;33
      .js 00;33
      .ts 00;33
      .rs 00;33
      .go 00;33
      .nix 00;33
    '';
  };
}
