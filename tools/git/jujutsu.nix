{ pkgs, config, ... }:

let
  inherit (config.defaults.identity) name email sshKey;
in
{
  home.packages = with pkgs; [
    jujutsu # Modern Git alternative (jj)
  ];

  xdg.configFile."jj/config.toml".text = ''
    [user]
    name = "${name}"
    email = "${email}"

    [signing]
    behavior = "own"
    backend = "ssh"
    key = "${sshKey}"

    [ui]
    default-command = "status"
    pager = "delta"

    [template-aliases]
    'format_short_change_id(id)' = 'id.shortest(4)'
  '';
}
