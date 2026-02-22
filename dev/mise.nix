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
        "npm:@google/gemini-cli" = "latest";
        "npm:czg" = "latest";
        "npm:ccmanager" = "latest";
        "npm:zenn-cli" = "latest";
        "cargo:keifu" = "latest"; # Lightweight git history viewer
      };
    };
  };
}
