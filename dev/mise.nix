_:

{
  xdg.configFile."pnpm/rc".text = ''
    minimum-release-age=720
    save-prefix=~
  '';

  programs.mise = {
    enable = true;
    enableBashIntegration = false;
    enableZshIntegration = false;
    globalConfig = {
      settings = {
        experimental = true;
        warn_on_new_version = false;
        legacy_version_file = true;
        jobs = 4;
        task_output = "prefix";
        color_theme = "catppuccin";
        trusted_config_paths = [ "~/workspace" ];
        npm = {
          package_manager = "bun";
        };
        pipx = {
          uvx = true;
        };
        task = {
          monorepo_depth = 2;
        };
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
        java = "latest";
        pnpm = "latest";
        "npm:@antfu/ni" = "latest";
        "npm:czg" = "latest";
        "npm:ccmanager" = "latest";
        "npm:zenn-cli" = "latest";
        "npm:@anthropic-ai/claude-code" = "latest";
      };
    };
  };
}
