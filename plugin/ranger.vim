. " ranger.vim
"
" Repo: rafaqz/ranger.vim
"
" Thanks airodactyl for code from neovim-ranger

"----------------------------------------------}}}
function! s:RangerMagic(path) " {{{ 
  " Ranger has already run, so do something with the output.
	if exists('g:ranger_tempfile')
    call s:HandleRangerOutput()
  " Otherwise, run ranger if the specified path actually exists.
	elseif isdirectory(a:path)
    " Opening in the current window is the default.
    if !(exists("g:ranger_layout"))
      let g:ranger_layout = "edit"
    endif
    " Create a new temporary file name
    let g:ranger_tempfile = tempname()

    let opts = ' --choosefiles=' . shellescape(g:ranger_tempfile) . ' ' . shellescape(a:path)
    " Nvim 
    if has('nvim')
      exec 'silent terminal ranger' . opts 
      exec 'normal i'
    " Vim
    else 
      let cmd = 'silent !ranger' . opts
      " Gvim probably doesn't work even with this modification
      if has("gui_running") && (has("gui_gtk") || has("gui_motif"))
        let cmd = '!' . g:ranger_terminal . ' ranger' . opts
      endif
      exec cmd
      " Fudge to end up in the right window
      if !(g:ranger_layout ==# "edit")
        exec 'close'
      endif
      " Open/insert/past/etc. whatever ranger returns.
      call s:HandleRangerOutput()
      redraw!
    endif
	endif
endfunction

" Swap vims native file browser for ranger.
au BufEnter * silent call s:RangerMagic(expand("<amatch>")) 
let g:loaded_netrwPlugin = 'disable'

"---------------------------------------}}}
function! s:HandleRangerOutput() " {{{ 
  let names = s:ReadRangerOutput()
  unlet g:ranger_tempfile

  if empty(names)
    execute "normal \<C-O>"
    return
  endif

  " Run an action on returned filename
  if exists("g:ranger_command") 
    if g:ranger_command == "lcd" || g:ranger_command == "lcd" 
      let parent_dir = fnamemodify(names[0], ':h')
      exec g:ranger_command . ' ' . parent_dir 
    elseif g:ranger_command == "action" 
      " Relative to pwd, otherwise home dir, otherwise root.
      let filename = fnamemodify(names[0], ':~:.')
      exec "normal " . g:ranger_action . filename
    endif
    unlet g:ranger_command
  " Open returned filenames in chosen layout
  else 
    for name in names
      exec g:ranger_layout . ' ' . fnameescape(name)
      doau BufRead
    endfor
  endif
endfunction

function! s:ReadRangerOutput() " {{{ 
  if filereadable(g:ranger_tempfile)
    return readfile(g:ranger_tempfile)
  endif
endfunction

"---------------------------------------}}}

"----------------------------------------------}}}
function! s:Ranger(path) " {{{
  " Open a new layout at a path to start ranger
  exec g:ranger_layout . '! ' . a:path
endfunction

"----------------------------------------------}}}
function! RangerEdit(layout, ...) " {{{
  let g:ranger_layout = a:layout
  if a:0 > 0
    let l:path = a:1
  else
    let l:path = expand("%:p:h")
  endif
  call s:Ranger(path)
endfunction

"----------------------------------------------}}}
function! RangerPWD(command) " {{{
  let g:ranger_command = a:command 
  let g:ranger_layout = 'split'
  let path = fnameescape(expand("%:p:h"))
  call s:Ranger(path)
endfunction

"----------------------------------------------}}}
function! RangerPaste(action) " {{{ 
  " Insert or append filenames
  let g:ranger_command = "action"
  let g:ranger_action = a:action
  let g:ranger_layout = 'split'
  let path = fnameescape(expand("%:p:h"))
  call s:Ranger(path)
endfunction

"----------------------------------------------}}}
function! RangerChangeOperator(type) " {{{ 
  " Change filename selected by operator using ranger
  let g:ranger_command = "action"
  let g:ranger_action =  "`<v`>xi"
  let g:ranger_layout = 'split'
  let path = s:GetSelectedPath(a:type)
  call s:Ranger(path)
endfunction

"----------------------------------------------}}}
function! s:GetSelectedPath(type) " {{{
  " Get text from action
  if a:type ==# 'v'
      normal! `<v`>y
  elseif a:type ==# 'char'
      normal! `[v`]y
  else
      return ""
  endif
  return fnamemodify(fnameescape(@@), ':h')
endfunction

"----------------------------------------------}}}
" {{{  Commands
command! RangerEdit call RangerEdit("edit")
command! RangerSplit call RangerEdit("split")
command! RangerVSplit call RangerEdit("vertical split")
command! RangerTab call RangerEdit("tabedit")
command! RangerInsert call RangerPaste('i')
command! RangerAppend call RangerPaste('a')
command! RangerLCD call RangerPWD('lcd')
command! RangerCD call RangerPWD('cd')

"----------------------------------------------}}}

