"finish
if executable('typescript-language-server')
  augroup LspTypeScript
    au!
    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'typescript-language-server',
        \ 'cmd': {server_info->[&shell, &shellcmdflag, 'typescript-language-server --stdio']},
        \ 'root_uri':{server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'tsconfig.json'))},
        \ 'whitelist': ['typescript'],
        \ })
    autocmd FileType typescript setlocal omnifunc=lsp#complete
  augroup END
endif
if executable('pyls')
  " pip install python-language-server
  augroup LspPython
    au!
    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'whitelist': ['python'],
        \ })
    autocmd FileType python setlocal omnifunc=lsp#complete
  augroup END
endif
if executable('golsp')
  augroup LspGo
    au!
    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'go-lang',
        \ 'cmd': {server_info->['golsp']},
        \ 'whitelist': ['go'],
        \ })
    autocmd FileType go setlocal omnifunc=lsp#complete
    autocmd FileType python,go nmap gd <plug>(lsp-definition)
  augroup END
elseif executable('go-langserver')
  augroup LspGo
    au!
    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'go-lang',
        \ 'cmd': {server_info->['go-langserver', '-mode', 'stdio', '-gocodecompletion']},
        \ 'whitelist': ['go'],
        \ })
    autocmd FileType go setlocal omnifunc=lsp#complete
  augroup END
endif
if executable('solargraph')
  augroup LspRuby
    au!
    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'solargraph',
        \ 'cmd': {server_info->[&shell, &shellcmdflag, 'solargraph stdio']},
        \ 'whitelist': ['ruby'],
        \ })
    autocmd FileType ruby setlocal omnifunc=lsp#complete
  augroup END
endif
if executable('clangd')
  augroup LspCpp
    au!
    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'clangd',
        \ 'cmd': {server_info->['clangd']},
        \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp'],
        \ })
    autocmd FileType c,cpp setlocal omnifunc=lsp#complete
  augroup END
endif

let g:lsp_async_completion = 0
