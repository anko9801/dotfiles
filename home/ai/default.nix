# AI/LLM tools
{ pkgs, ... }:

{
  imports = [
    ./claude
  ];

  home.packages = with pkgs; [
    # Coding assistants
    aider-chat # AI pair programming

    # Local LLM
    ollama # Run LLMs locally

    # CLI tools
    llm # Python CLI for LLMs (Simon Willison)

    # Utilities
    shell-gpt # ChatGPT in terminal
  ];
}
