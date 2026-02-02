{ pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      pyright
      ruff
    ];
    sessionVariables.PYTHONUNBUFFERED = "1";
  };
}
