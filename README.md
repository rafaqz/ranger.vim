ranger.vim
==========

(https://github.com/rafaqz/ranger.vim)


## Ranger for vim!

Ranger is a scriptable terminal file manager with vim like commands that
displays files as you browse (even images).

http://ranger.nongnu.org/

This plugin draws on the examples included with ranger and
airodactyl/neovim-ranger to embed ranger as vims file manager, as a better
alternative to the built in file manager or nerd-tree.

I maintain this version because it does a lot more than the other ranger
plugins, and I need the things.

- It's vim and neovim compatible.
- It can open files in the current tab, new tabs, splits or vertical splits. 
- It can insert/append filenames into the current buffer.
- It works as an operator to replace a file path selected with any vim movement.
- It works as an operator to browse and open files from a selected file path.
- It now completely replaces vims internal file browser with ranger by default (thanks airodactyl)


# gvim
Ranger needs to run in an external terminal in gvim, so specify your terminal with
the program flag:

```vimscript
let g:ranger_terminal = 'urxvt -e'
let g:ranger_terminal = 'xterm -e'
```


## Suggested Mappings 

The rest of the readme assumes these mappings:

    map <leader>rr :RangerEdit<cr>
    map <leader>rv :RangerVSplit<cr>
    map <leader>rs :RangerSplit<cr>
    map <leader>rt :RangerTab<cr>
    map <leader>ri :RangerInsert<cr>
    map <leader>ra :RangerAppend<cr>
    map <leader>rc :set operatorfunc=RangerChangeOperator<cr>g@
    map <leader>rR :set operatorfunc=RangerBrowseEdit<cr>g@
    map <leader>rT :set operatorfunc=RangerBrowseTab<cr>g@
    map <leader>rS :set operatorfunc=RangerBrowseSplit<cr>g@
    map <leader>rV :set operatorfunc=RangerBrowseVSplit<cr>g@

## To browse and open file(s) with ranger:

    <leader>rr

Open files(s) with ranger in tabs, splits and vertical splits.
Each file selected gets a new tab/split.

    <leader>rt
    <leader>rs
    <leader>rv

## To insert or append a filepath

    <leader>ri
    <leader>ra

## To use ranger as an operator and change a file path under the cursor:

    <leader>rc[movement]

This example will replace the text inside () with whatever file path you select in ranger. If
it's already a valid path ranger will open there:

    <leader>rci( 

## To use ranger as an operator and browse a file path under the cursor:
    <leader>rR[movement]
    <leader>rT[movement]
    <leader>rS[movement]
    <leader>rV[movement]
