{ pkgs, ... }:

{
  # Security scanning tools
  home.packages = with pkgs; [
    gitleaks # Secret detection in git repos
    trivy # Container/filesystem vulnerability scanner
  ];

  xdg.configFile."gitleaks/config.toml".text = ''
    title = "gitleaks config"

    [extend]
    useDefault = true

    [[rules]]
    id = "1password-secret-reference"
    description = "1Password secret reference"
    regex = '''op://[a-zA-Z0-9-_]+/[a-zA-Z0-9-_]+/[a-zA-Z0-9-_]+'''
    [rules.allowlist]
    description = "Allow 1Password references"
    regexes = [
        '''op://[a-zA-Z0-9-_]+/[a-zA-Z0-9-_]+/[a-zA-Z0-9-_]+'''
    ]

    [allowlist]
    description = "global allow list"
    paths = [
        '''\.gitleaks\.toml$''',
        '''\.gitleaksignore$''',
        '''(^|/)vendor/''',
        '''(^|/)node_modules/''',
        '''\.lock$''',
        '''\.md$''',
        '''\.txt$'''
    ]
    regexes = [
        '''(example|template|sample|test|demo)''',
        '''[A-Z_]+=(\$\{[A-Z_]+\}|<[^>]+>|TODO|CHANGEME|REPLACE_ME|your-.*-here)''',
        '''(localhost|127\.0\.0\.1|0\.0\.0\.0|example\.com)'''
    ]
  '';
}
