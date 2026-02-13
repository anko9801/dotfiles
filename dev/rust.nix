{ pkgs, lib, ... }:

{
  home = {
    packages = with pkgs; [
      rustup
      cargo-watch
    ];

    sessionPath = [ "$HOME/.cargo/bin" ];

    # Configure cargo (rustup provides the cargo binary)
    file.".cargo/config.toml".text = ''
      [build]
      jobs = 4

      [net]
      git-fetch-with-cli = true
    '';

    activation.setupRust = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if command -v rustup &>/dev/null; then
        if ! rustup show active-toolchain &>/dev/null; then
          $DRY_RUN_CMD rustup default stable 2>/dev/null || true
        fi
      fi
    '';
  };
}
