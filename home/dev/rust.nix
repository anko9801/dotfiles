{ pkgs, lib, ... }:

{
  home = {
    packages = with pkgs; [
      rustup
      cargo-watch
    ];

    activation.setupRust = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if command -v rustup &>/dev/null; then
        if ! rustup show active-toolchain &>/dev/null; then
          $DRY_RUN_CMD rustup default stable 2>/dev/null || true
        fi
      fi
    '';
  };

  programs.cargo = {
    enable = true;
    settings = {
      build.jobs = 4;
      net.git-fetch-with-cli = true;
    };
  };
}
