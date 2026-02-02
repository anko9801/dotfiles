{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # CLI tools (migrated from cargo)
    just # Task runner
    typst # Document processor
    ast-grep # Structural code search
  ];
}
