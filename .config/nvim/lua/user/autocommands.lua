vim.cmd [[
    augroup numbertoggle
        autocmd!
        autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
        autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
    augroup END

    augroup LspFormatting
        autocmd BufWritePre * lua vim.lsp.buf.format()
    augroup END

    " InsertEnter * norm zz --> Vim makes line that you edit middle of the screen
    autocmd InsertEnter * norm zz
    " BufwritePre* %s/\s\+$//e --> any trailing whitespaces on any line are removed
    autocmd BufWritePre * %s/\s\+$//e

    " Programming languages specific stuff
    augroup language_specifics
        " Rust
        " autocmd BufWritePost *.rs !rustfmt %
        " autocmd CursorMoved,InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost *.rs lua require'lsp_extensions'.inlay_hints{ prefix = '', highlight = "Comment", enabled = {"TypeHint", "ChainingHint", "ParameterHint"} }
    augroup END

    " skeleton stuff
    augroup templates
        autocmd BufNewFile *.sh    0r ~/.config/nvim/templates/skeleton.sh
        autocmd BufNewFile *.py    0r ~/.config/nvim/templates/skeleton.py
        autocmd BufNewFile *.c     0r ~/.config/nvim/templates/skeleton.c
        autocmd BufNewFile *.html  0r ~/.config/nvim/templates/skeleton.html
    augroup END

    augroup vimrc_autocmds
        autocmd BufEnter * highlight OverLength ctermbg=darkgrey guibg=#592929
        autocmd BufEnter * match OverLength /\%160v.*/
    augroup END
]]
