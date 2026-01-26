" OPAM Integration for OCaml Development
" Provides integration with OPAM-installed OCaml development tools

" Only load if opam is available
if !executable('opam')
  finish
endif

" Get OPAM share directory
let s:opam_share_dir = system("opam var share 2>/dev/null")
let s:opam_share_dir = substitute(s:opam_share_dir, '[\r\n]*$', '', '')

" Check if OPAM is properly initialized
if v:shell_error != 0 || empty(s:opam_share_dir)
  finish
endif

let s:opam_configuration = {}

" OCP-Indent: OCaml auto-indentation
function! OpamConfOcpIndent()
  let l:dir = s:opam_share_dir . "/ocp-indent/vim"
  if isdirectory(l:dir)
    execute "set rtp^=" . l:dir
  endif
endfunction
let s:opam_configuration['ocp-indent'] = function('OpamConfOcpIndent')

" OCP-Index: OCaml code navigation
function! OpamConfOcpIndex()
  let l:dir = s:opam_share_dir . "/ocp-index/vim"
  if isdirectory(l:dir)
    execute "set rtp+=" . l:dir
  endif
endfunction
let s:opam_configuration['ocp-index'] = function('OpamConfOcpIndex')

" Merlin: OCaml IDE features
function! OpamConfMerlin()
  let l:dir = s:opam_share_dir . "/merlin/vim"
  if isdirectory(l:dir)
    execute "set rtp+=" . l:dir
    " Merlin configuration
    let g:merlin_display_occurrence_list = 0
    nmap <LocalLeader>m <Plug>(MerlinTypeOf)
    nmap <LocalLeader>n <Plug>(MerlinTypeOfSel)
    nmap <LocalLeader>g <Plug>(MerlinGrowEnclosing)
    nmap <LocalLeader>s <Plug>(MerlinShrinkEnclosing)
  endif
endfunction
let s:opam_configuration['merlin'] = function('OpamConfMerlin')

" Check which tools are installed and configure them
let s:opam_packages = ["ocp-indent", "ocp-index", "merlin"]
let s:opam_check_cmdline = ["opam", "list", "--installed", "--short", "--safe", "--color=never"] + s:opam_packages
let s:opam_available_tools = systemlist(join(s:opam_check_cmdline))

for tool in s:opam_packages
  " Respect package order (merlin should be after ocp-index)
  if index(s:opam_available_tools, tool) >= 0
    call s:opam_configuration[tool]()
  endif
endfor

" OCaml specific settings
augroup OCamlSettings
  autocmd!
  autocmd FileType ocaml setlocal commentstring=(*%s*)
  autocmd FileType ocaml setlocal shiftwidth=2
  autocmd FileType ocaml setlocal tabstop=2
  autocmd FileType ocaml setlocal expandtab
  autocmd FileType ocaml setlocal textwidth=80
  " .mli files are OCaml interface files
  autocmd BufRead,BufNewFile *.mli set filetype=ocaml
augroup END