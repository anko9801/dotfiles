# AI/LLM tools
{
  pkgs,
  lib,
  config,
  llmAgentsPkgs ? { },
  ...
}:

{
  imports = [
    ./claude
  ];

  home.packages =
    (with pkgs; [
      # Coding assistants
      aider-chat # AI pair programming

      # Local LLM
      ollama # Run LLMs locally

      # CLI tools
      llm # Python CLI for LLMs (Simon Willison)

      # Utilities
      shell-gpt # ChatGPT in terminal
    ])
    # AI coding agents from llm-agents.nix (skip in CI - heavy builds)
    ++ lib.optionals (!config.platform.isCI && llmAgentsPkgs != { }) (
      lib.filter (p: p != null) [
        (llmAgentsPkgs.codex or null) # OpenAI Codex CLI
        (llmAgentsPkgs.gemini-cli or null) # Google Gemini CLI
        (llmAgentsPkgs.opencode or null) # Open source coding agent
      ]
    );
}
