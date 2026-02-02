_:

{
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    globalConfig = {
      settings = {
        experimental = true;
        legacy_version_file = true;
        jobs = 4;
        task_output = "prefix";
      };
      # Environment variables set in home.nix sessionVariables
      env = { };
      tools = {
        # Runtimes - LTS/stable versions to avoid constant re-downloads
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
        # npm tools (version-pinned to avoid timeout issues)
        "npm:@antfu/ni" = "28.2.0";
        "npm:@google/gemini-cli" = "0.25.2";
        "npm:czg" = "1.12.0";
        "npm:cz-git" = "1.12.0";
        "npm:ccmanager" = "3.6.1";
        "npm:zenn-cli" = "0.4.3";
        "npm:gitmoji-cli" = "9.7.0";
        # claude-code is managed by Nix (programs.claude-code)
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

  programs.npm = {
    enable = true;
    settings = {
      prefix = "~/.npm-global";
      fund = false;
      audit = false;
    };
  };
}
