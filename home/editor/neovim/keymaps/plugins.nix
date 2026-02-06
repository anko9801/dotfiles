# Plugin-specific keymaps
{ lib, ... }:

let
  mkKey = mode: key: action: desc: {
    inherit mode key action;
    options = {
      inherit desc;
      silent = true;
    };
  };

  mkLuaKey = mode: key: lua: desc: {
    inherit mode key;
    action.__raw = lua;
    options = {
      inherit desc;
      silent = true;
    };
  };

  # Git
  git = [
    (mkLuaKey "n" "<leader>gg" ''
      function()
        vim.cmd("tabnew | terminal lazygit")
        vim.cmd("startinsert")
      end
    '' "Lazygit")
    (mkKey "n" "<leader>gd" "<cmd>DiffviewOpen<CR>" "Git diff")
    (mkKey "n" "<leader>gD" "<cmd>DiffviewClose<CR>" "Close diff")
    (mkKey "n" "<leader>gc" "<cmd>FzfLua git_commits<CR>" "Git commits")
    (mkKey "n" "<leader>gs" "<cmd>FzfLua git_status<CR>" "Git status")
  ];

  # GitHub (Octo)
  octo = [
    (mkKey "n" "<leader>op" "<cmd>Octo pr list<CR>" "List PRs")
    (mkKey "n" "<leader>oi" "<cmd>Octo issue list<CR>" "List issues")
    (mkKey "n" "<leader>or" "<cmd>Octo review start<CR>" "Start review")
  ];

  # AI (Avante)
  avante = [
    (mkKey "n" "<leader>aa" "<cmd>AvanteAsk<CR>" "Avante: Ask")
    (mkKey "v" "<leader>aa" "<cmd>AvanteAsk<CR>" "Avante: Ask (sel)")
    (mkKey "n" "<leader>ae" "<cmd>AvanteEdit<CR>" "Avante: Edit")
    (mkKey "v" "<leader>ae" "<cmd>AvanteEdit<CR>" "Avante: Edit (sel)")
    (mkKey "n" "<leader>at" "<cmd>AvanteToggle<CR>" "Avante: Toggle")
    (mkKey "n" "<leader>ar" "<cmd>AvanteRefresh<CR>" "Avante: Refresh")
  ];

  # Terminal
  terminal = [
    (mkKey "n" "<leader>tf" "<cmd>ToggleTerm direction=float<CR>" "Float terminal")
    (mkKey "n" "<leader>th" "<cmd>ToggleTerm direction=horizontal<CR>" "Horizontal terminal")
    (mkKey "n" "<leader>tv" "<cmd>ToggleTerm direction=vertical<CR>" "Vertical terminal")
    (mkKey "t" "<C-\\>" "<cmd>ToggleTerm<CR>" "Toggle terminal")
    (mkKey "t" "<Esc><Esc>" "<C-\\><C-n>" "Exit terminal mode")
  ];

  # Session (Persistence)
  session = [
    (mkLuaKey "n" "<leader>qs" "function() require('persistence').load() end" "Restore session")
    (mkLuaKey "n" "<leader>ql" "function() require('persistence').load({ last = true }) end"
      "Restore last"
    )
    (mkLuaKey "n" "<leader>qd" "function() require('persistence').stop() end" "Don't save")
  ];

  # Diagnostics (Trouble)
  trouble = [
    (mkKey "n" "<leader>xx" "<cmd>Trouble diagnostics toggle<CR>" "Diagnostics")
    (mkKey "n" "<leader>xX" "<cmd>Trouble diagnostics toggle filter.buf=0<CR>" "Buffer diagnostics")
    (mkKey "n" "<leader>cs" "<cmd>Trouble symbols toggle focus=false<CR>" "Symbols")
    (mkKey "n" "<leader>cl" "<cmd>Trouble lsp toggle focus=false win.position=right<CR>" "LSP")
    (mkKey "n" "<leader>xL" "<cmd>Trouble loclist toggle<CR>" "Location list")
    (mkKey "n" "<leader>xQ" "<cmd>Trouble qflist toggle<CR>" "Quickfix list")
  ];
in
{
  programs.nixvim.keymaps = lib.flatten [
    git
    octo
    avante
    terminal
    session
    trouble
  ];
}
