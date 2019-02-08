. " ranger.vim
"
" Repo: rafaqz/ranger.vim
"
" Thanks airodactyl for code from neovim-ranger

"----------------------------------------------
function! s:RangerMagic(path) abort " {{{
	if !(isdirectory(a:path))
    return
	endif

  " Open in the current window if opened from vim netrw.
  if !(exists("g:ranger_layout"))
    let g:ranger_layout = "edit"
  endif

  " Create a new temporary file name
  let g:ranger_tempfile = tempname()
  if g:ranger_cd_mode
    let l:choose_arg = 'choosedir'
  else
    let l:choose_arg = 'choosefiles'
  endif
  let l:opts =  printf('--%s=%s %s', l:choose_arg, shellescape(g:ranger_tempfile), shellescape(a:path))

  if has('nvim')
    call s:RangerNVim(l:opts)
  else
    call s:RangerVim(l:opts)
  endif

endfunction

function! s:RangerNVim(opts) abort
  let l:rangerCallback = { 'name': 'ranger' }
  function! l:rangerCallback.on_exit(id, code, _event)
    if g:ranger_layout != 'edit'
      silent! bdelete!
    else
      if bufnr('%') != bufnr('#')
        setl bufhidden=delete | buffer! #
      else
        enew | bdelete! #
      endif
    endif
    call s:HandleRangerOutput()
  endfunction

  call termopen("ranger " . a:opts, l:rangerCallback)
  startinsert
endfunction

function! s:RangerVim(opts) abort
  let l:cmd = 'silent !ranger ' . a:opts
  " TODO: Gvim will now need a callback to work
  if has("gui_running") && (has("gui_gtk") || has("gui_motif"))
    let l:cmd = '!' . g:ranger_terminal . ' ranger ' . a:opts
  endif
  exec l:cmd
  if g:ranger_layout != 'edit'
    silent! bdelete!
  else
    if bufnr('%') != bufnr('#')
      setl bufhidden=delete | buffer! #
    else
      enew | bdelete! #
    endif
  endif

  call s:HandleRangerOutput()
  redraw!
endfunction

"---------------------------------------}}}
function! s:HandleRangerOutput() abort " {{{
  let l:names = s:ReadRangerOutput()
  unlet g:ranger_tempfile

  if empty(l:names)
    if !(has('nvim')) && (g:ranger_layout == "edit")
      execute "normal \<C-O>"
    endif
    return
  endif

  if exists("g:ranger_command")
    call s:RunCommand(l:names)
  else
    call s:OpenFile(l:names)
  endif
endfunction

function! s:RunCommand(names) abort
  if g:ranger_cd_mode
    exec g:ranger_command . ' ' . a:names[0]
    let g:ranger_cd_mode = 0
  elseif g:ranger_command == "action"
    " Return a path relative to pwd, otherwise home dir, otherwise root.
    let filenames = map(a:names, {key, val -> fnamemodify(val, ":~:.")})
    let str = join(filenames, "\r")
    exec "normal " . g:ranger_action . str
  endif
  unlet g:ranger_command
endfunction

function! s:OpenFile(names) abort
  " Otherwise open returned filenames in the chosen layout
  for name in a:names
    try
      exec "silent " . g:ranger_layout . ' ' . fnameescape(name)
      doau BufRead
    catch
    endtry
  endfor
endfunction

function! s:ReadRangerOutput() abort
  if filereadable(g:ranger_tempfile)
    return readfile(g:ranger_tempfile)
  endif
endfunction

"----------------------------------------------}}}
function! s:Ranger(path) abort " {{{
  " Open a new layout at a path to start ranger
  exec g:ranger_layout . '! ' . a:path
endfunction

"----------------------------------------------}}}
function! RangerEdit(layout, ...) abort " {{{
  let g:ranger_layout = a:layout
  if a:0 > 0
    let l:path = a:1
  else
    let l:path = expand("%:p:h")
  endif
  call s:Ranger(l:path)
endfunction

"----------------------------------------------}}}
function! RangerCD(cd_command) abort " {{{
  let g:ranger_command = a:cd_command
  let g:ranger_cd_mode = 1
  let g:ranger_layout = 'split'
  let l:path = fnameescape(expand("%:p:h"))
  call s:Ranger(l:path)
endfunction

"----------------------------------------------}}}
function! RangerPaste(action) abort " {{{
  " Insert or append filenames
  let g:ranger_command = "action"
  let g:ranger_action = a:action
  let g:ranger_layout = 'split'
  let l:path = fnameescape(expand("%:p:h"))
  call s:Ranger(l:path)
endfunction

"----------------------------------------------}}}
function! RangerChangeOperator(type) abort " {{{
  " Change filename selected by operator using ranger
  let g:ranger_command = "action"
  let g:ranger_action =  "`<v`>xi"
  let g:ranger_layout = 'split'
  let l:path = s:GetSelectedPath(a:type)
  call s:Ranger(l:path)
endfunction

"----------------------------------------------}}}
function! s:GetSelectedPath(type) abort " {{{
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
command! RangerLCD call RangerCD('lcd')
command! RangerCD call RangerCD('cd')

"----------------------------------------------}}}
" {{{  Plugin initialization
" Swap vims native file browser for ranger.
let g:loaded_netrwPlugin = 'disable'
augroup ranger
  autocmd!
  autocmd BufEnter * silent call s:RangerMagic(expand("<amatch>"))
augroup END
let g:ranger_cd_mode = 0

