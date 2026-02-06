# Core keymaps with data-driven approach
{ lib, ... }:

let
  # Helper to create keymap
  mkKey = mode: key: action: desc: {
    inherit mode key action;
    options = {
      inherit desc;
      silent = true;
    };
  };

  # Helper for raw Lua actions
  mkLuaKey = mode: key: lua: desc: {
    inherit mode key;
    action.__raw = lua;
    options = {
      inherit desc;
      silent = true;
    };
  };

  # Navigation keymaps (wrapped lines)
  navigation = [
    (mkKey [ "n" "v" ] "j" "gj" "Down (wrapped)")
    (mkKey [ "n" "v" ] "k" "gk" "Up (wrapped)")
  ];

  # Yank/Search keymaps
  yankSearch = [
    (mkKey "n" "Y" "y$" "Yank to end of line")
    (mkKey "n" "n" "nzzzv" "Next search (centered)")
    (mkKey "n" "N" "Nzzzv" "Prev search (centered)")
    (mkKey "n" "J" "mzJ`z" "Join lines (keep cursor)")
    (mkKey "n" "<Esc>" "<cmd>nohlsearch<CR>" "Clear search highlight")
  ];

  # Insert mode
  insert = [
    (mkKey "i" "jk" "<Esc>" "Escape")
  ];

  # QuickFix
  quickfix = [
    (mkKey "n" "]q" "<cmd>cnext<CR>zz" "Next quickfix")
    (mkKey "n" "[q" "<cmd>cprevious<CR>zz" "Prev quickfix")
    (mkKey "n" "<leader>xq" "<cmd>copen<CR>" "Open quickfix")
  ];

  # Command-line (Emacs style)
  cmdline = [
    (mkKey "c" "<C-a>" "<Home>" "Beginning of line")
    (mkKey "c" "<C-e>" "<End>" "End of line")
    (mkKey "c" "<C-b>" "<Left>" "Left")
    (mkKey "c" "<C-f>" "<Right>" "Right")
  ];

  # Window navigation (smart-splits)
  windowNav = [
    (mkLuaKey "n" "<C-h>" "function() require('smart-splits').move_cursor_left() end" "Window left")
    (mkLuaKey "n" "<C-j>" "function() require('smart-splits').move_cursor_down() end" "Window down")
    (mkLuaKey "n" "<C-k>" "function() require('smart-splits').move_cursor_up() end" "Window up")
    (mkLuaKey "n" "<C-l>" "function() require('smart-splits').move_cursor_right() end" "Window right")
  ];

  # Window resize (smart-splits)
  windowResize = [
    (mkLuaKey "n" "<C-Left>" "function() require('smart-splits').resize_left() end" "Resize left")
    (mkLuaKey "n" "<C-Down>" "function() require('smart-splits').resize_down() end" "Resize down")
    (mkLuaKey "n" "<C-Up>" "function() require('smart-splits').resize_up() end" "Resize up")
    (mkLuaKey "n" "<C-Right>" "function() require('smart-splits').resize_right() end" "Resize right")
  ];

  # Visual mode
  visual = [
    (mkKey "v" "<" "<gv" "Indent left")
    (mkKey "v" ">" ">gv" "Indent right")
  ];

  # Move lines
  moveLines = [
    (mkKey "n" "<A-j>" "<cmd>m .+1<CR>==" "Move line down")
    (mkKey "n" "<A-k>" "<cmd>m .-2<CR>==" "Move line up")
    (mkKey "v" "<A-j>" ":m '>+1<CR>gv=gv" "Move selection down")
    (mkKey "v" "<A-k>" ":m '<-2<CR>gv=gv" "Move selection up")
  ];

  # Buffer navigation
  buffer = [
    (mkKey "n" "<S-h>" "<cmd>bprevious<CR>" "Prev buffer")
    (mkKey "n" "<S-l>" "<cmd>bnext<CR>" "Next buffer")
  ];

  # Leader commands
  leader = [
    (mkKey "n" "<leader>w" "<cmd>w<CR>" "Save file")
    (mkKey "n" "<leader>q" "<cmd>q<CR>" "Quit")
    (mkKey "n" "<leader>Q" "<cmd>qa!<CR>" "Quit all force")
    (mkKey "n" "<leader>cf" "<cmd>lua require('conform').format()<CR>" "Format file")
  ];

  # Window splits
  splits = [
    (mkKey "n" "<leader>sv" "<C-w>v" "Split vertical")
    (mkKey "n" "<leader>sh" "<C-w>s" "Split horizontal")
    (mkKey "n" "<leader>se" "<C-w>=" "Equal splits")
    (mkKey "n" "<leader>sx" "<cmd>close<CR>" "Close split")
  ];

  # Tabs
  tabs = [
    (mkKey "n" "<leader>to" "<cmd>tabnew<CR>" "New tab")
    (mkKey "n" "<leader>tx" "<cmd>tabclose<CR>" "Close tab")
    (mkKey "n" "<leader>tn" "<cmd>tabn<CR>" "Next tab")
    (mkKey "n" "<leader>tp" "<cmd>tabp<CR>" "Prev tab")
  ];
in
{
  programs.nixvim.keymaps = lib.flatten [
    navigation
    yankSearch
    insert
    quickfix
    cmdline
    windowNav
    windowResize
    visual
    moveLines
    buffer
    leader
    splits
    tabs
  ];
}
