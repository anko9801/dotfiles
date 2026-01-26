" WSL Clipboard Integration
" Provides seamless clipboard integration between Vim and Windows clipboard in WSL

if system('uname -a | grep -i microsoft') != ''
  " Auto-yank to Windows clipboard
  augroup WslYank
    autocmd!
    autocmd TextYankPost * if v:event.operator ==# 'y' | call system('clip.exe', @") | endif
  augroup END

  " Advanced WSL clipboard functions for handling multi-line content
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
    let l:tmpfile = tempname()
    call writefile(split(@@, "\n", 1), l:tmpfile, 'b')
    call system('cat ' . shellescape(l:tmpfile) . ' | clip.exe')
    call delete(l:tmpfile)
  endfunction

  " This function only works when there are no newlines:
  function! WslSendLastYankedToClip() abort
    silent execute '! printf ' . shellescape(@@) . ' | clip.exe'
  endfunction

  " Paste from Windows clipboard
  nnoremap <silent> <leader>p :r !powershell.exe -Command Get-Clipboard<cr>
  vnoremap <silent> <leader>p :r !powershell.exe -Command Get-Clipboard<cr>
endif