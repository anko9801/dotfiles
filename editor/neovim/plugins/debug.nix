# Debug Adapter Protocol (DAP) configuration
{ pkgs, ... }:

{
  programs.nixvim = {
    # DAP adapters installed via extraPackages
    extraPackages = with pkgs; [
      # Node.js debugging
      vscode-js-debug

      # Python debugging
      python312Packages.debugpy

      # Go debugging
      delve

      # LLDB for C/C++/Rust
      lldb
    ];

    plugins = {
      # nvim-dap: Debug Adapter Protocol client
      dap = {
        enable = true;
        lazyLoad.settings = {
          cmd = [
            "DapToggleBreakpoint"
            "DapContinue"
          ];
          keys = [
            {
              __unkeyed-1 = "<leader>db";
              desc = "Toggle breakpoint";
            }
            {
              __unkeyed-1 = "<leader>dc";
              desc = "Continue";
            }
            {
              __unkeyed-1 = "<leader>di";
              desc = "Step into";
            }
            {
              __unkeyed-1 = "<leader>do";
              desc = "Step over";
            }
            {
              __unkeyed-1 = "<leader>dO";
              desc = "Step out";
            }
            {
              __unkeyed-1 = "<leader>dr";
              desc = "Toggle REPL";
            }
            {
              __unkeyed-1 = "<leader>dl";
              desc = "Run last";
            }
            {
              __unkeyed-1 = "<leader>dt";
              desc = "Terminate";
            }
          ];
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
          rust = [
            {
              type = "lldb";
              request = "launch";
              name = "Launch";
              program.__raw = ''
                function()
                  return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
                end
              '';
              cwd = "\${workspaceFolder}";
              stopOnEntry = false;
            }
          ];
          c = [
            {
              type = "lldb";
              request = "launch";
              name = "Launch";
              program.__raw = ''
                function()
                  return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                end
              '';
              cwd = "\${workspaceFolder}";
              stopOnEntry = false;
            }
          ];
          cpp = [
            {
              type = "lldb";
              request = "launch";
              name = "Launch";
              program.__raw = ''
                function()
                  return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                end
              '';
              cwd = "\${workspaceFolder}";
              stopOnEntry = false;
            }
          ];
        };
      };
    };

    # DAP keymaps
    keymaps = [
      {
        mode = "n";
        key = "<leader>db";
        action.__raw = ''function() require("dap").toggle_breakpoint() end'';
        options = {
          desc = "Toggle breakpoint";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>dB";
        action.__raw = ''function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end'';
        options = {
          desc = "Conditional breakpoint";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>dc";
        action.__raw = ''function() require("dap").continue() end'';
        options = {
          desc = "Continue";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>di";
        action.__raw = ''function() require("dap").step_into() end'';
        options = {
          desc = "Step into";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>do";
        action.__raw = ''function() require("dap").step_over() end'';
        options = {
          desc = "Step over";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>dO";
        action.__raw = ''function() require("dap").step_out() end'';
        options = {
          desc = "Step out";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>dr";
        action.__raw = ''function() require("dap").repl.toggle() end'';
        options = {
          desc = "Toggle REPL";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>dl";
        action.__raw = ''function() require("dap").run_last() end'';
        options = {
          desc = "Run last";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>dt";
        action.__raw = ''function() require("dap").terminate() end'';
        options = {
          desc = "Terminate";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>du";
        action.__raw = ''function() require("dapui").toggle() end'';
        options = {
          desc = "Toggle DAP UI";
          silent = true;
        };
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>de";
        action.__raw = ''function() require("dapui").eval() end'';
        options = {
          desc = "Eval expression";
          silent = true;
        };
      }
    ];
  };
}
