# 1Password CLI + shell plugins
# Sets defaults.ssh.agentSocket/signProgram for other modules to consume
# Add to baseModules in config.nix to enable
{
  config,
  inputs,
  ...
}:
let
  p = config.platform;
in
{
  imports = [ inputs._1password-shell-plugins.hmModules.default ];

  config.defaults.ssh = {
    agentSocket =
      if p.os == "darwin" then
        "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
      else
        "~/.1password/agent.sock";
    signProgram = "op-ssh-sign";
  };
}
