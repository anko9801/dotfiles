{ config, ... }:
{
  home = {
    sessionPath = [ "$HOME/.juliaup/bin" ];
    sessionVariables.JULIA_NUM_PRECOMPILE_TASKS = if config.platform.os == "darwin" then "2" else "28";
  };
}
