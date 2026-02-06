# Navigation and file finder keymaps
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

  # File explorer
  explorer = [
    (mkKey "n" "<leader>e" "<cmd>Oil<CR>" "File explorer")
    (mkKey "n" "-" "<cmd>Oil<CR>" "Parent directory")
  ];

  # Harpoon
  harpoon =
    let
      mkHarpoon =
        n:
        mkLuaKey "n" "<leader>${toString n}"
          "function() require('harpoon'):list():select(${toString n}) end"
          "Harpoon ${toString n}";
    in
    [
      (mkLuaKey "n" "<leader>ha" "function() require('harpoon'):list():add() end" "Harpoon add")
      (mkLuaKey "n" "<leader>hh"
        "function() require('harpoon').ui:toggle_quick_menu(require('harpoon'):list()) end"
        "Harpoon menu"
      )
    ]
    ++ map mkHarpoon [
      1
      2
      3
      4
    ];

  # fzf-lua
  fzf = [
    (mkKey "n" "<leader>ff" "<cmd>FzfLua files<CR>" "Find files")
    (mkKey "n" "<leader>fg" "<cmd>FzfLua live_grep<CR>" "Live grep")
    (mkKey "n" "<leader>fb" "<cmd>FzfLua buffers<CR>" "Buffers")
    (mkKey "n" "<leader>fh" "<cmd>FzfLua help_tags<CR>" "Help tags")
    (mkKey "n" "<leader>fr" "<cmd>FzfLua oldfiles<CR>" "Recent files")
  ];

  # Flash
  flash = [
    (mkLuaKey [ "n" "x" "o" ] "s" "function() require('flash').jump() end" "Flash jump")
    (mkLuaKey [ "n" "x" "o" ] "S" "function() require('flash').treesitter() end" "Flash treesitter")
    (mkLuaKey "o" "r" "function() require('flash').remote() end" "Flash remote")
  ];
in
{
  programs.nixvim.keymaps = lib.flatten [
    explorer
    harpoon
    fzf
    flash
  ];
}
