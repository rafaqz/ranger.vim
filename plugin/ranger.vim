"ranger.vim
"
" Repo: rafaqz/ranger.vim
"
" Thanks airodactyl for code from neovim-ranger

"----------------------------------------------}}}
" {{{ Magic

function! s:RangerMagic(path)
	if exists('g:ranger_tempfile')
    call s:HandleOutput()

	elseif isdirectory(a:path)
    let g:ranger_tempfile = tempname()
    if has("nvim")
      exec 'silent terminal ranger --choosefiles=' . shellescape(g:ranger_tempfile) . ' ' . shellescape(a:path)
      exec 'normal i'
    else 
      let g:ranger_tempfile = tempname()
      let cmd = 'silent !ranger --choosefiles=' . shellescape(g:ranger_tempfile) . ' ' . shellescape(a:path)
      if has("gui_running") && (has("gui_gtk") || has("gui_motif"))
        let cmd = substitute(cmd, '!', '! urxvtr -e ', '')
      endif
      exec cmd
      if !(g:ranger_layout ==# "edit")
        exec 'close'
      endif
      call s:HandleOutput()
      redraw!
    endif
	endif
endfunction

function! s:HandleOutput()
  let names = s:ReadFile()
  unlet g:ranger_tempfile

  if empty(names)
    return
  endif

  if exists("g:ranger_action")
    exec "normal " . g:ranger_action . names[0]
    unlet g:ranger_action
  else
    exec g:ranger_layout . fnameescape(names[0])
      filetype detect
    for name in names[1:]
      exec g:ranger_layout . ' ' . fnameescape(name)
      filetype detect
    endfor
  endif
endfunction

au BufEnter * silent call s:RangerMagic(expand("<amatch>")) 
let g:loaded_netrwPlugin = 'disable'

"----------------------------------------------}}}
" {{{ Open files

function! s:Ranger(path)
  exec g:ranger_layout . '! ' . a:path
endfunction

function! s:ReadFile()
  if filereadable(g:ranger_tempfile)
    return readfile(g:ranger_tempfile)
  endif
endfunction

function! RangerEdit(layout, ...)
  let g:ranger_layout = a:layout
  if a:0 > 0
    let l:path = a:1
  else
    let l:path = expand("%:p:h")
  endif
  call s:Ranger(path)
endfunction

"----------------------------------------------}}}
" {{{ Insert and append filenames
function! RangerPaste(action)
  let g:ranger_action = a:action
  let g:ranger_layout = 'split'
  exec "lcd %:p:h"
  let path = fnameescape(expand("%:p:h"))
  call s:Ranger(path)
endfunction

"----------------------------------------------}}}
" {{{ Change filename selected by operator using ranger
function! RangerChangeOperator(type)
  if a:type ==# 'v'
      normal! `<v`>y
  elseif a:type ==# 'char'
      normal! `[v`]y
  else
      return
  endif

  let g:ranger_action =  "`<v`>xi"
  let g:ranger_layout = 'split'
  let path = fnamemodify(fnameescape(@@), ':h')
  call s:Ranger(path)
endfunction

"----------------------------------------------}}}
" {{{  Browse path from operator using ranger

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
  if a:type ==# 'v'
      normal! `<v`>y
  elseif a:type ==# 'char'
      normal! `[v`]y
  else
      return
  endif

  let path = fnamemodify(fnameescape(@@), ':h')
  call RangerEdit(a:layout, path)
endfunction

"----------------------------------------------}}}
" {{{  Commands

command! RangerEdit call RangerEdit("edit")
command! RangerSplit call RangerEdit("split")
command! RangerVSplit call RangerEdit("vertical split")
command! RangerTab call RangerEdit("tabedit")
command! RangerInsert call RangerPaste('i')
command! RangerAppend call RangerPaste('a')

"----------------------------------------------}}}

