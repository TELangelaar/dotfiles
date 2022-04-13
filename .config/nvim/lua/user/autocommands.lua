vim.cmd [[
    augroup numbertoggle
        autocmd!
        autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
        autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
    augroup END

    " InsertEnter * norm zz --> Vim makes line that you edit middle of the screen
    autocmd InsertEnter * norm zz
    " BufwritePre* %s/\s\+$//e --> any trailing whitespaces on any line are removed
    autocmd BufWritePre * %s/\s\+$//e

    " skeleton stuff
    augroup templates
        autocmd BufNewFile *.sh    0r ~/.config/nvim/templates/skeleton.sh
        autocmd BufNewFile *.py    0r ~/.config/nvim/templates/skeleton.py
        autocmd BufNewFile *.c     0r ~/.config/nvim/templates/skeleton.c
        autocmd BufNewFile *.html  0r ~/.config/nvim/templates/skeleton.html
    augroup END
    augroup vimrc_autocmds
        autocmd BufEnter * highlight OverLength ctermbg=darkgrey guibg=#592929
        autocmd BufEnter * match OverLength /\%80v.*/
    augroup END
]]
