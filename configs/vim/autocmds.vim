" =============================================================================
" Vim Autocommands - Useful features from backup
" =============================================================================

" =============================================================================
" Filetype specific settings
" =============================================================================
augroup FileTypeSettings
  autocmd!
  " UI files as XML
  autocmd BufRead,BufNewFile *.ui setfiletype xml
  autocmd BufRead,BufNewFile *.sage setfiletype python
  
  " JavaScript/TypeScript
  autocmd FileType javascript setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
  autocmd FileType typescript setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
  autocmd FileType javascriptreact setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
  autocmd FileType typescriptreact setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
  
  " Web development
  autocmd FileType html setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
  autocmd FileType css setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
  autocmd FileType scss setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
  autocmd FileType vue setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
  
  " Python - Special handling with tabs
  autocmd FileType python setlocal autoindent
  autocmd FileType python setlocal smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
  autocmd FileType python setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=4
  
  " XML
  autocmd FileType xml setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
  
  " Quickfix window
  autocmd FileType qf setlocal wrap
  
  " Vim files - use marker folding
  autocmd FileType vim setlocal foldmethod=marker
augroup END

" =============================================================================
" WSL clipboard integration
" =============================================================================
if system('uname -a | grep -i microsoft') != ''
  augroup WslYank
    autocmd!
    autocmd TextYankPost * if v:event.operator ==# 'y' | call system('clip.exe', @0) | endif
  augroup END
  
  " Advanced WSL copy functionality from backup
  nnoremap <silent> <Plug>WslCopy :set operatorfunc=WslSendToClipboard<cr>g@
  xnoremap <silent> <Plug>WslCopy :<C-U>call WslSendToClipboard(visualmode(),1)<cr>
  command! -range Wsly exe "normal gv \<Plug>WslCopy"
  
  function! WslSendToClipboard(type, ...) abort
    let l:sel_save = &selection
    let &selection = 'inclusive'
    let l:reg_save = @@
    
    if !(has('unix') && executable('clip.exe'))
      echoerr 'wsl-copy: invalid config - are u on wsl?'
      return
    endif
    
    if a:0 " Invoked from visual mode, use gv command
      normal! gvy
      call WslSendLastYankedToTmpFileAndSendToClip()
    elseif a:type ==# 'line'
      normal! '[V']y
      call WslSendLastYankedToTmpFileAndSendToClip()
    elseif a:type ==# 'char'
      normal! `[v`]y
      call WslSendLastYankedToClip()
    endif
    
    redraw!
    echo 'wsl-copy: text yanked to clip.exe'
    let &selection = l:sel_save
    let @@ = l:reg_save
  endfunction
  
  function! WslSendLastYankedToTmpFileAndSendToClip() abort
    silent new /tmp/vimBuffer
    silent %d
    silent normal! "0P
    if line('$') > 1 " Remove excess newlines if necessary
      silent normal! Gdd
    endif
    silent normal! ZZ
    silent ! cat /tmp/vimBuffer | clip.exe
  endfunction
  
  " This function only works when there are no newlines:
  function! WslSendLastYankedToClip() abort
    silent execute '! printf ' . shellescape(@@) . ' | clip.exe'
  endfunction
endif

" =============================================================================
" OPAM (OCaml) integration
" =============================================================================
if executable('opam')
  let s:opam_share_dir = system("opam config var share 2>/dev/null")
  let s:opam_share_dir = substitute(s:opam_share_dir, '[\r\n]*$', '', '')
  
  if !empty(s:opam_share_dir) && isdirectory(s:opam_share_dir)
    let s:opam_configuration = {}
    
    function! OpamConfOcpIndent()
      execute "set rtp^=" . s:opam_share_dir . "/ocp-indent/vim"
    endfunction
    let s:opam_configuration['ocp-indent'] = function('OpamConfOcpIndent')
    
    function! OpamConfOcpIndex()
      execute "set rtp+=" . s:opam_share_dir . "/ocp-index/vim"
    endfunction
    let s:opam_configuration['ocp-index'] = function('OpamConfOcpIndex')
    
    function! OpamConfMerlin()
      let l:dir = s:opam_share_dir . "/merlin/vim"
      execute "set rtp+=" . l:dir
    endfunction
    let s:opam_configuration['merlin'] = function('OpamConfMerlin')
    
    let s:opam_packages = ["ocp-indent", "ocp-index", "merlin"]
    let s:opam_check_cmdline = ["opam list --installed --short --safe --color=never"] + s:opam_packages
    let s:opam_available_tools = split(system(join(s:opam_check_cmdline)))
    for tool in s:opam_packages
      " Respect package order (merlin should be after ocp-index)
      if count(s:opam_available_tools, tool) > 0
        call s:opam_configuration[tool]()
      endif
    endfor
  endif
endif

" =============================================================================
" Retab on load (from backup)
" =============================================================================
augroup RetabOnLoad
  autocmd!
  autocmd BufReadPost * if &modifiable | retab 4 | retab! | endif
augroup END