_:

{
  programs.mise = {
    enable = true;
    enableZshIntegration = false; # Lazy loaded in zsh config
    globalConfig = {
      settings = {
        experimental = true;
        legacy_version_file = true;
        jobs = 4;
        task_output = "prefix";
      };
      env = { };
      tools = {
        node = "22";
        python = "latest";
        uv = "latest";
        ruby = "latest";
        go = "latest";
        deno = "latest";
        bun = "latest";
        lua = "latest";
        java = "openjdk-21";
        pnpm = "10.28.1";
        "npm:@antfu/ni" = "28.2.0";
        "npm:@google/gemini-cli" = "0.25.2";
        "npm:czg" = "latest";
        "npm:ccmanager" = "3.6.1";
        "npm:zenn-cli" = "0.4.3";
      };
      tasks = {
        update = {
          description = "Update all tools to latest versions";
          run = ''
            echo "📦 Updating mise tools..."
            mise update
            mise prune
            echo "✅ All tools updated!"
          '';
        };
        doctor = {
          description = "Check mise configuration and health";
          run = ''
            mise doctor
            echo "---"
            mise list
          '';
        };
        clean = {
          description = "Clean up old tool versions";
          run = ''
            echo "🧹 Cleaning up old versions..."
            mise prune --yes
            echo "✅ Cleanup complete!"
          '';
        };
      };
    };
  };
}
