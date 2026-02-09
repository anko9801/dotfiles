{ pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      ruff
    ];
    sessionVariables.PYTHONUNBUFFERED = "1";
  };
}
