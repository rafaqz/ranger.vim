ranger.vim
==========

Ranger for vim!

Ranger is a scriptable terminal file manager with vim like commands that
displays files as you browse (even images).

http://ranger.nongnu.org/



To browse and open file(s) with ranger:

    <leader>rr

Open files(s) with ranger in tabs, splits and vertical splits.
Each file selected gets a new tab/split.

    <leader>rt
    <leader>rs
    <leader>rv

Use ranger as an operator, to add/edit a file path under the cursor:

    <leader>r[movement]

example: 

    <leader>ri( 

Will replace the text inside () with whatever file path you select in ranger. If
it's already a file-path ranger will open there.



ranger.vim wont work in gvim, but if you're using ranger, you probably don't use
gvim anyway...
