" =============================================================================
" LSP Configuration - Based on vim-lsp
" =============================================================================
" This file will be sourced when vim-lsp is available through dpp.vim

if !exists('*lsp#register_server')
  finish
endif

" TypeScript/JavaScript
if executable('typescript-language-server')
  augroup LspTypeScript
    autocmd!
    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'typescript-language-server',
        \ 'cmd': {server_info->[&shell, &shellcmdflag, 'typescript-language-server --stdio']},
        \ 'root_uri':{server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'tsconfig.json'))},
        \ 'whitelist': ['typescript', 'javascript', 'typescriptreact', 'javascriptreact'],
        \ })
    autocmd FileType typescript,javascript,typescriptreact,javascriptreact setlocal omnifunc=lsp#complete
  augroup END
endif

" Python
if executable('pylsp')
  " pip install python-lsp-server
  augroup LspPython
    autocmd!
    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'pylsp',
        \ 'cmd': {server_info->['pylsp']},
        \ 'whitelist': ['python'],
        \ })
    autocmd FileType python setlocal omnifunc=lsp#complete
  augroup END
elseif executable('pyls')
  " Fallback to older python-language-server
  augroup LspPython
    autocmd!
    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'whitelist': ['python'],
        \ })
    autocmd FileType python setlocal omnifunc=lsp#complete
  augroup END
endif

" Go
if executable('gopls')
  augroup LspGo
    autocmd!
    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'gopls',
        \ 'cmd': {server_info->['gopls']},
        \ 'whitelist': ['go'],
        \ })
    autocmd FileType go setlocal omnifunc=lsp#complete
  augroup END
endif

" Ruby
if executable('solargraph')
  augroup LspRuby
    autocmd!
    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'solargraph',
        \ 'cmd': {server_info->[&shell, &shellcmdflag, 'solargraph stdio']},
        \ 'whitelist': ['ruby'],
        \ })
    autocmd FileType ruby setlocal omnifunc=lsp#complete
  augroup END
endif

" C/C++
if executable('clangd')
  augroup LspCpp
    autocmd!
    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'clangd',
        \ 'cmd': {server_info->['clangd']},
        \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp'],
        \ })
    autocmd FileType c,cpp,objc,objcpp setlocal omnifunc=lsp#complete
  augroup END
endif

" Rust
if executable('rust-analyzer')
  augroup LspRust
    autocmd!
    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'rust-analyzer',
        \ 'cmd': {server_info->['rust-analyzer']},
        \ 'whitelist': ['rust'],
        \ })
    autocmd FileType rust setlocal omnifunc=lsp#complete
  augroup END
endif

" =============================================================================
" LSP Key mappings
" =============================================================================
function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  setlocal signcolumn=yes
  if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
  
  " Navigation
  nmap <buffer> gd <plug>(lsp-definition)
  nmap <buffer> gs <plug>(lsp-document-symbol-search)
  nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
  nmap <buffer> gr <plug>(lsp-references)
  nmap <buffer> gi <plug>(lsp-implementation)
  nmap <buffer> gt <plug>(lsp-type-definition)
  nmap <buffer> [g <plug>(lsp-previous-diagnostic)
  nmap <buffer> ]g <plug>(lsp-next-diagnostic)
  nmap <buffer> K <plug>(lsp-hover)
  
  " Actions
  nmap <buffer> <leader>rn <plug>(lsp-rename)
  nmap <buffer> <leader>ca <plug>(lsp-code-action)
  nmap <buffer> <leader>f <plug>(lsp-document-format)
  xmap <buffer> <leader>f <plug>(lsp-document-range-format)
  
  " Workspace
  nmap <buffer> <leader>wa <plug>(lsp-workspace-add)
  nmap <buffer> <leader>wr <plug>(lsp-workspace-remove)
  nmap <buffer> <leader>wl <plug>(lsp-workspace-list)
endfunction

augroup lsp_install
  autocmd!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" =============================================================================
" LSP Settings
" =============================================================================
let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_float_cursor = 1
let g:lsp_diagnostics_highlights_enabled = 1
let g:lsp_diagnostics_signs_enabled = 1
let g:lsp_diagnostics_virtual_text_enabled = 0
let g:lsp_document_highlight_enabled = 1
let g:lsp_fold_enabled = 0
let g:lsp_hover_conceal = 0
let g:lsp_preview_float = 1
let g:lsp_async_completion = 1
let g:lsp_auto_enable = 1
let g:lsp_diagnostics_signs_error = {'text': '✗'}
let g:lsp_diagnostics_signs_warning = {'text': '⚠'}
let g:lsp_diagnostics_signs_information = {'text': 'ℹ'}
let g:lsp_diagnostics_signs_hint = {'text': '💡'}