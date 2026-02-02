{ pkgs, userConfig, ... }:

{
  home.packages = with pkgs; [
    jujutsu # Modern Git alternative (jj)
  ];

  xdg.configFile."jj/config.toml".text = ''
    [user]
    name = "${userConfig.git.name}"
    email = "${userConfig.git.email}"

    [signing]
    behavior = "own"
    backend = "ssh"
    key = "${userConfig.git.sshKey}"

    [ui]
    default-command = "status"
    pager = "delta"

    [template-aliases]
    'format_short_change_id(id)' = 'id.shortest(4)'
  '';
}
