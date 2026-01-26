import {
  BaseConfig,
  ConfigReturn,
  ContextBuilder,
  Dpp,
  Plugin,
} from "https://deno.land/x/dpp_vim@v0.0.5/types.ts";
import { Denops, fn } from "https://deno.land/x/dpp_vim@v0.0.5/deps.ts";

export class Config extends BaseConfig {
  override async config(args: {
    denops: Denops;
    contextBuilder: ContextBuilder;
    basePath: string;
    dpp: Dpp;
  }): Promise<ConfigReturn> {
    const [context, options] = await args.contextBuilder.get(args.denops);
    
    // Plugin list
    const plugins: Plugin[] = [
      // ==========================================================================
      // UI Enhancement
      // ==========================================================================
      {
        repo: "vim-airline/vim-airline",
        lazy: false,
        hook_add: `
          let g:airline_theme = 'onedark'
          let g:airline#extensions#tabline#enabled = 1
          let g:airline#extensions#branch#enabled = 1
          let g:airline_powerline_fonts = 1
        `,
      },
      {
        repo: "vim-airline/vim-airline-themes",
        lazy: false,
        depends: ["vim-airline"],
      },
      {
        repo: "cocopon/iceberg.vim",
        lazy: false,
      },
      {
        repo: "joshdick/onedark.vim",
        lazy: false,
      },
      
      // ==========================================================================
      // File Management
      // ==========================================================================
      {
        repo: "junegunn/fzf",
        build: "./install --bin",
        merged: false,
      },
      {
        repo: "junegunn/fzf.vim",
        depends: ["fzf"],
        lazy: true,
        on_cmd: ["Files", "GFiles", "Buffers", "Rg", "Lines", "BLines", "Commands"],
        hook_add: `
          nnoremap <leader>f :Files<CR>
          nnoremap <leader>g :GFiles<CR>
          nnoremap <leader>b :Buffers<CR>
          nnoremap <leader>r :Rg<CR>
          nnoremap <leader>l :Lines<CR>
        `,
      },
      {
        repo: "preservim/nerdtree",
        lazy: true,
        on_cmd: ["NERDTree", "NERDTreeToggle", "NERDTreeFind"],
        hook_add: `
          nnoremap <leader>n :NERDTreeToggle<CR>
          nnoremap <leader>nf :NERDTreeFind<CR>
          let g:NERDTreeShowHidden = 1
          let g:NERDTreeIgnore = ['\\.git$', '\\.DS_Store$']
        `,
      },
      
      // ==========================================================================
      // Git Integration
      // ==========================================================================
      {
        repo: "tpope/vim-fugitive",
        lazy: true,
        on_cmd: ["Git", "Gstatus", "Gblame", "Gdiff", "Glog"],
      },
      {
        repo: "airblade/vim-gitgutter",
        lazy: false,
        hook_add: `
          let g:gitgutter_map_keys = 0
          nmap ]h <Plug>(GitGutterNextHunk)
          nmap [h <Plug>(GitGutterPrevHunk)
          nmap <leader>hp <Plug>(GitGutterPreviewHunk)
          nmap <leader>hs <Plug>(GitGutterStageHunk)
          nmap <leader>hu <Plug>(GitGutterUndoHunk)
        `,
      },
      
      // ==========================================================================
      // Coding Support
      // ==========================================================================
      {
        repo: "prabirshrestha/vim-lsp",
        lazy: false,
        hook_add: `
          let g:lsp_diagnostics_enabled = 1
          let g:lsp_diagnostics_echo_cursor = 1
          let g:lsp_text_edit_enabled = 1
          let g:lsp_signs_enabled = 1
          let g:lsp_virtual_text_enabled = 1
        `,
      },
      {
        repo: "mattn/vim-lsp-settings",
        lazy: false,
        depends: ["vim-lsp"],
      },
      {
        repo: "prabirshrestha/asyncomplete.vim",
        lazy: false,
      },
      {
        repo: "prabirshrestha/asyncomplete-lsp.vim",
        lazy: false,
        depends: ["asyncomplete.vim", "vim-lsp"],
      },
      {
        repo: "hrsh7th/vim-vsnip",
        lazy: false,
        hook_add: `
          imap <expr> <C-j> vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<C-j>'
          smap <expr> <C-j> vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<C-j>'
          imap <expr> <Tab> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<Tab>'
          smap <expr> <Tab> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<Tab>'
          imap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'
          smap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'
        `,
      },
      {
        repo: "hrsh7th/vim-vsnip-integ",
        lazy: false,
        depends: ["vim-vsnip"],
      },
      
      // ==========================================================================
      // Syntax & Language Support
      // ==========================================================================
      {
        repo: "sheerun/vim-polyglot",
        lazy: false,
      },
      {
        repo: "dense-analysis/ale",
        lazy: false,
        hook_add: `
          let g:ale_linters_explicit = 1
          let g:ale_fix_on_save = 1
          let g:ale_sign_column_always = 1
          let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
          let g:ale_linters = {
          \   'python': ['flake8', 'mypy'],
          \   'javascript': ['eslint'],
          \   'typescript': ['eslint', 'tsserver'],
          \   'go': ['gopls', 'golint'],
          \   'rust': ['rustc', 'cargo'],
          \}
          let g:ale_fixers = {
          \   '*': ['remove_trailing_lines', 'trim_whitespace'],
          \   'python': ['black', 'isort'],
          \   'javascript': ['prettier'],
          \   'typescript': ['prettier'],
          \   'go': ['gofmt'],
          \   'rust': ['rustfmt'],
          \}
        `,
      },
      
      // ==========================================================================
      // Editor Enhancement
      // ==========================================================================
      {
        repo: "tpope/vim-surround",
        lazy: true,
        on_event: ["InsertEnter"],
      },
      {
        repo: "tpope/vim-commentary",
        lazy: true,
        on_map: { n: "gc", v: "gc" },
      },
      {
        repo: "jiangmiao/auto-pairs",
        lazy: true,
        on_event: ["InsertEnter"],
      },
      {
        repo: "junegunn/vim-easy-align",
        lazy: true,
        on_cmd: ["EasyAlign"],
        on_map: { n: "ga", x: "ga" },
        hook_add: `
          nmap ga <Plug>(EasyAlign)
          xmap ga <Plug>(EasyAlign)
        `,
      },
      {
        repo: "easymotion/vim-easymotion",
        lazy: true,
        on_map: { n: "<Leader>" },
        hook_add: `
          let g:EasyMotion_do_mapping = 0
          let g:EasyMotion_smartcase = 1
          nmap <Leader>s <Plug>(easymotion-overwin-f2)
          nmap <Leader>w <Plug>(easymotion-overwin-w)
        `,
      },
      
      // ==========================================================================
      // Utility
      // ==========================================================================
      {
        repo: "mbbill/undotree",
        lazy: true,
        on_cmd: ["UndotreeToggle"],
        hook_add: `
          nnoremap <leader>u :UndotreeToggle<CR>
        `,
      },
      {
        repo: "vim-scripts/sudo.vim",
        lazy: true,
        on_cmd: ["SudoRead", "SudoWrite"],
      },
      {
        repo: "tpope/vim-repeat",
        lazy: true,
        on_event: ["CursorMoved"],
      },
    ];

    return {
      plugins: plugins,
      stateLines: [],
    };
  }
}