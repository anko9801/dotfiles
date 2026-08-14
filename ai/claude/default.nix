{
  pkgs,
  inputs,
  lib,
  ...
}:

let
  antfu-skills = inputs.antfu-skills or null;
  anthropic-skills = inputs.anthropic-skills or null;
in
{
  home.packages = [
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.ccusage
  ];

  programs.agent-skills = {
    enable = true;
    sources =
      lib.optionalAttrs (antfu-skills != null) {
        antfu.path = antfu-skills;
      }
      // lib.optionalAttrs (anthropic-skills != null) {
        anthropic = {
          path = anthropic-skills;
          subdir = "skills";
        };
      };
    skills.enableAll = [
      "antfu"
      "anthropic"
    ];
    targets = {
      claude = {
        enable = true;
        dest = ".claude/skills";
        structure = "symlink-tree";
      };
      codex = {
        enable = true;
        dest = ".codex/skills";
        structure = "copy-tree";
      };
    };
  };
}
