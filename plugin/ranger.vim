. " ranger.vim
"
" Repo: rafaqz/ranger.vim
"
" Thanks airodactyl for code from neovim-ranger

"----------------------------------------------
function! s:RangerMagic(path) " {{{
	if !(isdirectory(a:path))
    return
	endif

  " Open in the current window if opened from vim netrw.
  if !(exists("g:ranger_layout"))
    let g:ranger_layout = "edit"
  endif

  if !(exists("g:additional_opts"))
    let g:additional_opts = ""
  endif

  " Create a new temporary file name
  let g:ranger_tempfile = tempname()
  let opts = ' --choosefiles=' . shellescape(g:ranger_tempfile) . ' ' . shellescape(a:path) . ' ' . g:additional_opts

  if has('nvim')
    call s:RangerNVim(opts)
  else
    call s:RangerVim(opts)
  endif

endfunction

function! s:RangerNVim(opts)
  let rangerCallback = { 'name': 'ranger' }
  function! rangerCallback.on_exit(id, code, _event)
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

  call termopen("ranger " . a:opts, rangerCallback)
  startinsert
endfunction

function! s:RangerVim(opts)
  let cmd = 'silent !ranger' . a:opts
  " TODO: Gvim will now need a callback to work
  if has("gui_running") && (has("gui_gtk") || has("gui_motif"))
    let cmd = '!' . g:ranger_terminal . ' ranger' . a:opts
  endif
  exec cmd
  if !(g:ranger_layout ==# "edit")
    exec 'close'
  endif

  call s:HandleRangerOutput()
  redraw!
endfunction

" Swap vims native file browser for ranger.
au BufEnter * silent call s:RangerMagic(expand("<amatch>"))
let g:loaded_netrwPlugin = 'disable'


"---------------------------------------}}}
function! s:HandleRangerOutput() " {{{
  let names = s:ReadRangerOutput()
  unlet g:ranger_tempfile

  if empty(names)
    if !(has('nvim')) && (g:ranger_layout == "edit")
      execute "normal \<C-O>"
    endif
    return
  endif

  if exists("g:ranger_command")
    call s:RunCommand(names)
  else
    call s:OpenFile(names)
  endif
endfunction

function! s:RunCommand(names)
  if g:ranger_command == "lcd" || g:ranger_command == "lcd"
    let parent_dir = fnamemodify(a:names[0], ':h')
    exec g:ranger_command . ' ' . parent_dir
  elseif g:ranger_command == "action"
    " Return a path relative to pwd, otherwise home dir, otherwise root.
    let filenames = map(a:names, {key, val -> fnamemodify(val, ":~:.")})
    let str = join(filenames, "\r")
    exec "normal " . g:ranger_action . str
  endif
  unlet g:ranger_command
endfunction

function! s:OpenFile(names)
  " Otherwise open returned filenames in the chosen layout
  for name in a:names
    try
      exec "silent " . g:ranger_layout . ' ' . fnameescape(name)
      doau BufRead
    catch
    endtry
  endfor
endfunction

function! s:ReadRangerOutput()
  if filereadable(g:ranger_tempfile)
    return readfile(g:ranger_tempfile)
  endif
endfunction

"----------------------------------------------}}}
function! s:Ranger(path) " {{{
  " Open a new layout at a path to start ranger
  exec g:ranger_layout . '! ' . a:path
endfunction

"----------------------------------------------}}}
function! RangerEdit(layout, ...) " {{{
  let g:ranger_layout = a:layout
  let l:path = exists('a:1') && a:1 ? a:1 : expand("%:p:h")
  let g:additional_opts = exists('a:2') ? a:2 : ""
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

