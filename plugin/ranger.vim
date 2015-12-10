"ranger.vim
"
" Maintainer:   Rafael Schouten
" Version:      1.0
" Repo: rafaqz/ranger.vim
"
"----------------------------------------------
" Mappings {{{ 

map <leader>r :set operatorfunc=RangerOperator<cr>g@
map <leader>rr :RangerEdit<cr>
map <leader>rv :RangerVSplit<cr>
map <leader>rs :RangerSplit<cr>
map <leader>rt :RangerTab<cr>

"----------------------------------------------}}}
" Functions {{{ 

function! Ranger(path)
  let cmd = printf("silent !ranger --choosefiles=/tmp/chosenfiles %s",
        \ expand("%:p:h") . "/" . a:path)
  if has("gui_running") && (has("gui_gtk") || has("gui_motif"))
    let cmd = substitute(cmd, '!', '! urxvtr -e ', '')
  endif
  exec cmd
endfunction

function! RangerEdit(layout)
  exec Ranger("")
  if filereadable('/tmp/chosenfiles')
    let chosenfiles = system('cat /tmp/chosenfiles')
    let splitfiles = split(chosenfiles, "\n")
    for filename in splitfiles
      exec a:layout . " " . filename
    endfor
    call system('rm /tmp/chosenfiles')
  endif
  redraw!
endfunction

function! RangerOperator(type)
  exec "lcd %:p:h"

  if a:type ==# 'v'
      normal! `<v`>y
  elseif a:type ==# 'char'
      normal! `[v`]y
  else
      return
  endif

  let path = @@
  let dir = fnamemodify(path, ':h')
  call Ranger(dir)
  if filereadable('/tmp/chosenfiles')
    " Load filename, remove trailing null char
    let result = substitute(system('cat /tmp/chosenfiles'), "\n*$", '', '')
    echo "fooooobaaaar"
    exec "normal `<v`>xi" . result
    call system('rm /tmp/chosenfiles')
  endif
  redraw!
endfunction

"----------------------------------------------}}}
" Commands {{{ 

command! RangerEdit call RangerEdit("edit")
command! RangerSplit call RangerEdit("split")
command! RangerVSplit call RangerEdit("vertical split")
command! RangerTab call RangerEdit("tabedit")

" }}}

