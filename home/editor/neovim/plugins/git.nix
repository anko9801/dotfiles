_:

{
  programs.nixvim.plugins = {
    # gitsigns: Git signs in gutter and hunk operations
    gitsigns = {
      enable = true;
      lazyLoad.settings.event = [
        "BufReadPost"
        "BufNewFile"
      ];
      settings = {
        signs = {
          add.text = "│";
          change.text = "│";
          delete.text = "_";
          topdelete.text = "‾";
          changedelete.text = "~";
          untracked.text = "┆";
        };
        signs_staged_enable = true;
        current_line_blame = true;
        on_attach.__raw = ''
          function(bufnr)
            local gs = package.loaded.gitsigns
            local function map(mode, l, r, opts)
              opts = opts or {}
              opts.buffer = bufnr
              vim.keymap.set(mode, l, r, opts)
            end
            map("n", "]c", function()
              if vim.wo.diff then return "]c" end
              vim.schedule(function() gs.next_hunk() end)
              return "<Ignore>"
            end, { expr = true, desc = "Next hunk" })
            map("n", "[c", function()
              if vim.wo.diff then return "[c" end
              vim.schedule(function() gs.prev_hunk() end)
              return "<Ignore>"
            end, { expr = true, desc = "Previous hunk" })
            map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
            map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
            map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Stage hunk" })
            map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Reset hunk" })
            map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage buffer" })
            map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
            map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset buffer" })
            map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
            map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, { desc = "Blame line" })
            map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "Toggle blame" })
            map("n", "<leader>hd", gs.diffthis, { desc = "Diff this" })
            map("n", "<leader>hD", function() gs.diffthis("~") end, { desc = "Diff this ~" })
            map("n", "<leader>td", gs.toggle_deleted, { desc = "Toggle deleted" })
          end
        '';
      };
    };

    # diffview: Git diff viewer with side-by-side comparison
    diffview = {
      enable = true;
      lazyLoad.settings = {
        cmd = [
          "DiffviewOpen"
          "DiffviewFileHistory"
        ];
        keys = [
          {
            __unkeyed-1 = "<leader>gd";
            desc = "Git diff";
          }
          {
            __unkeyed-1 = "<leader>gD";
            desc = "Close diff";
          }
        ];
      };
    };

    # Octo: GitHub PR/Issue management in Neovim
    octo = {
      enable = true;
      lazyLoad.settings = {
        cmd = [ "Octo" ];
        keys = [
          {
            __unkeyed-1 = "<leader>op";
            desc = "List PRs";
          }
          {
            __unkeyed-1 = "<leader>oi";
            desc = "List issues";
          }
          {
            __unkeyed-1 = "<leader>or";
            desc = "Start review";
          }
        ];
      };
      settings = {
        use_local_fs = false;
        enable_builtin = true;
        default_remote = [
          "upstream"
          "origin"
        ];
        ssh_aliases = { };
        picker = "fzf-lua";
        picker_config = {
          use_emojis = true;
        };
        suppress_missing_scope = {
          projects_v2 = true;
        };
      };
    };

    # git-conflict: Visualize and resolve merge conflicts
    git-conflict = {
      enable = true;
      lazyLoad.settings.event = [ "BufReadPost" ];
      settings.default_mappings = true;
    };
  };
}
