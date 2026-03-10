_:

{
  programs.mise = {
    enable = true;
    enableZshIntegration = false; # Loaded in fish.nix interactiveShellInit
    globalConfig = {
      settings = {
        experimental = true;
        legacy_version_file = true;
        jobs = 4;
        task_output = "prefix";
        color_theme = "catppuccin";
        cargo_binstall = true;
        "npm.package_manager" = "bun";
        "pipx.uvx" = true;
        trusted_config_paths = [ "~/workspace" ];
      };
      env = { };
      tools = {
        node = "lts";
        python = "latest";
        uv = "latest";
        "pipx:ty" = "latest"; # Python type checker (Astral)
        ruby = "latest";
        go = "latest";
        deno = "latest";
        bun = "latest";
        lua = "latest";
        java = "latest";
        pnpm = "latest";
        "npm:@antfu/ni" = "latest";
        "npm:czg" = "latest";
        "npm:ccmanager" = "latest";
        "npm:zenn-cli" = "latest";
        "cargo:keifu" = "latest"; # Lightweight git history viewer
      };
    };
  };
}
