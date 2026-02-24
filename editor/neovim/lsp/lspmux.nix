{ pkgs, lib, ... }:

let
  lspmuxCmd = {
    __raw = ''vim.lsp.rpc.connect("127.0.0.1", 27631)'';
  };

  mkLspmuxServer = server: args: {
    extraOptions = {
      cmd = lspmuxCmd;
      init_options = {
        lspMux = {
          version = "1";
          method = "connect";
          inherit server;
        }
        // lib.optionalAttrs (args != [ ]) { inherit args; };
      };
    };
  };
in
{
  systemd.user.services.lspmux = {
    Unit.Description = "LSP multiplexer daemon";
    Install.WantedBy = [ "default.target" ];
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.lspmux}/bin/lspmux server";
      Restart = "on-failure";
    };
  };

  programs.nixvim.plugins.lsp.servers = {
    nixd = mkLspmuxServer "nixd" [ ];
    lua_ls = mkLspmuxServer "lua-language-server" [ ];
    gopls = mkLspmuxServer "gopls" [ ];

    # rust-analyzer: lspMux goes in settings (nvim-lspconfig auto-copies to initializationOptions)
    rust_analyzer = {
      extraOptions.cmd = lspmuxCmd;
      settings."rust-analyzer".lspMux = {
        version = "1";
        method = "connect";
        server = "rust-analyzer";
      };
    };
  };
}
