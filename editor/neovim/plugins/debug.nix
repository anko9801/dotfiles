# Debug Adapter Protocol (DAP) configuration
{ pkgs, ... }:

let
  # Helper to create DAP keymap
  mkDapKey = key: action: desc: {
    mode = "n";
    inherit key;
    action.__raw = ''function() require("dap").${action}() end'';
    options = {
      inherit desc;
      silent = true;
    };
  };

  # Helper to create DAP UI keymap
  mkDapUiKey = key: action: desc: mode: {
    inherit mode key;
    action.__raw = ''function() require("dapui").${action}() end'';
    options = {
      inherit desc;
      silent = true;
    };
  };

  # LLDB configuration for C-family languages
  mkLldbConfig = name: pathSuffix: [
    {
      type = "lldb";
      request = "launch";
      inherit name;
      program.__raw = ''
        function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "${pathSuffix}", "file")
        end
      '';
      cwd = "\${workspaceFolder}";
      stopOnEntry = false;
    }
  ];

  # All DAP keymaps (single source of truth)
  dapKeymaps = [
    (mkDapKey "<leader>db" "toggle_breakpoint" "Toggle breakpoint")
    {
      mode = "n";
      key = "<leader>dB";
      action.__raw = ''function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end'';
      options = {
        desc = "Conditional breakpoint";
        silent = true;
      };
    }
    (mkDapKey "<leader>dc" "continue" "Continue")
    (mkDapKey "<leader>di" "step_into" "Step into")
    (mkDapKey "<leader>do" "step_over" "Step over")
    (mkDapKey "<leader>dO" "step_out" "Step out")
    {
      mode = "n";
      key = "<leader>dr";
      action.__raw = ''function() require("dap").repl.toggle() end'';
      options = {
        desc = "Toggle REPL";
        silent = true;
      };
    }
    (mkDapKey "<leader>dl" "run_last" "Run last")
    (mkDapKey "<leader>dt" "terminate" "Terminate")
    (mkDapUiKey "<leader>du" "toggle" "Toggle DAP UI" "n")
    (mkDapUiKey "<leader>de" "eval" "Eval expression" [
      "n"
      "v"
    ])
  ];

  # Generate lazyLoad keys from keymaps
  lazyLoadKeys =
    map
      (km: {
        __unkeyed-1 = km.key;
        inherit (km.options) desc;
      })
      (
        builtins.filter (
          km:
          km.mode == "n"
          ||
            km.mode == [
              "n"
              "v"
            ]
        ) dapKeymaps
      );
in
{
  programs.nixvim = {
    extraPackages = with pkgs; [
      vscode-js-debug
      python312Packages.debugpy
      delve
      lldb
    ];

    plugins = {
      dap = {
        enable = true;
        lazyLoad.settings = {
          cmd = [
            "DapToggleBreakpoint"
            "DapContinue"
          ];
          keys = lazyLoadKeys;
        };
        extensions = {
          # dap-ui: UI for nvim-dap
          dap-ui = {
            enable = true;
            lazyLoad.settings.keys = [
              {
                __unkeyed-1 = "<leader>du";
                desc = "Toggle DAP UI";
              }
              {
                __unkeyed-1 = "<leader>de";
                desc = "Eval expression";
              }
            ];
          };

          # dap-virtual-text: Show variable values inline
          dap-virtual-text.enable = true;
        };
        adapters = {
          executables = {
            # Python
            python = {
              command = "python";
              args = [
                "-m"
                "debugpy.adapter"
              ];
            };
            # LLDB for C/C++/Rust
            lldb = {
              command = "lldb-dap";
            };
          };
          servers = {
            # Node.js/TypeScript via vscode-js-debug
            "pwa-node" = {
              host = "localhost";
              port = 8123;
              executable = {
                command = "js-debug-adapter";
              };
            };
            # Go via delve
            delve = {
              host = "127.0.0.1";
              port = 38697;
              executable = {
                command = "dlv";
                args = [
                  "dap"
                  "-l"
                  "127.0.0.1:38697"
                ];
              };
            };
          };
        };
        configurations = {
          python = [
            {
              type = "python";
              request = "launch";
              name = "Launch file";
              program = "\${file}";
              pythonPath = "python";
            }
          ];
          javascript = [
            {
              type = "pwa-node";
              request = "launch";
              name = "Launch file";
              program = "\${file}";
              cwd = "\${workspaceFolder}";
            }
          ];
          typescript = [
            {
              type = "pwa-node";
              request = "launch";
              name = "Launch file";
              program = "\${file}";
              cwd = "\${workspaceFolder}";
              runtimeExecutable = "npx";
              runtimeArgs = [ "ts-node" ];
            }
          ];
          go = [
            {
              type = "delve";
              request = "launch";
              name = "Launch file";
              program = "\${file}";
            }
            {
              type = "delve";
              request = "launch";
              name = "Launch package";
              program = "\${workspaceFolder}";
            }
          ];
          rust = mkLldbConfig "Launch" "/target/debug/";
          c = mkLldbConfig "Launch" "/";
          cpp = mkLldbConfig "Launch" "/";
        };
      };
    };

    keymaps = dapKeymaps;
  };
}
