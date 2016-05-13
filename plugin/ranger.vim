"ranger.vim
"
" Maintainer:   Rafael Schouten
" Version:      1.0
" Repo: rafaqz/ranger.vim
"

"----------------------------------------------}}}
" Functions {{{ 

function! Ranger(path)
  let cmd = printf("silent !ranger --choosefiles=/tmp/chosenfiles %s", a:path)
  if has("gui_running") && (has("gui_gtk") || has("gui_motif"))
    let cmd = substitute(cmd, '!', '! urxvtr -e ', '')
  endif
  exec cmd
endfunction

function! RangerEdit(layout, ...)
  if a:0 > 0
    let path = a:1
  else
    let path = expand("%:p:h")
  endif
  exec Ranger(path)
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

function! RangerChangeOperator(type)
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

function! RangerBrowseEdit(type)
  call RangerBrowseOperator(a:type, 'edit')
endfunction
function! RangerBrowseTab(type)
  call RangerBrowseOperator(a:type, 'tabedit')
endfunction
function! RangerBrowseSplit(type)
  call RangerBrowseOperator(a:type, 'split')
endfunction
function! RangerBrowseVSplit(type)
  call RangerBrowseOperator(a:type, 'vertical split')
endfunction

function! RangerBrowseOperator(type, layout)
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
  call RangerEdit(a:layout, path)
endfunction

"----------------------------------------------}}}
" Commands {{{ 

command! RangerEdit call RangerEdit("edit")
command! RangerSplit call RangerEdit("split")
command! RangerVSplit call RangerEdit("vertical split")
command! RangerTab call RangerEdit("tabedit")

" }}}

