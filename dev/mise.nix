{ config, lib, ... }:

{
  xdg.configFile."pnpm/rc".text = ''
    minimum-release-age=720
    save-prefix=~
  '';

  programs.mise = {
    enable = true;
    enableBashIntegration = false;
    enableZshIntegration = false;
    enableFishIntegration = true;
    globalConfig = {
      settings = {
        experimental = true;
        auto_install = config.platform.os != "darwin";
        legacy_version_file = true;
        jobs = 4;
        task_output = "prefix";
        color_theme = "catppuccin";
        npm = {
          package_manager = "bun";
        };
        pipx = {
          uvx = true;
        };
        task = {
          monorepo_depth = 2;
        };
      }
      // lib.optionalAttrs (config.platform.os == "darwin") {
        not_found_auto_install = false;
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
      };
    };
  };
}
