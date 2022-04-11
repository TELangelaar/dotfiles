" runtime! debian.vim

" call plug#begin('~/.vim/plugged')
call plug#begin('~/.local/share/nvim/plugged')
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'morhetz/gruvbox'
call plug#end()

syntax enable
colorscheme gruvbox

"CoC things ===== begin
set cmdheight=2
set updatetime=300
set nobackup                            " This is recommended by coc
set nowritebackup

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

"CoC things ===== end

" set listchars=space:_,tab:>~ list " this shows spaces as an underscore, and
" tabs as > followed by ~. Since i have expandtab on, this isnt really
" helpful!

set tabstop=8 " \t are 8 spaces (default)
set softtabstop=4 " tab and backspace are 4 spaces
set shiftwidth=4 " levels of indentations are 4 spaces
set expandtab " tabs are converted to spaces

" if you change tw, also change the number in OverLength down below
set tw=80 fo=cq wm=0
nnoremap ,tw :g/./normal gqq<CR>

set foldmethod=indent " folds code to reduce clutter

set hlsearch
nnoremap ,<space> :nohlsearch<CR>
" Ctrl+C now works for copying to clipboard
vnoremap <C-c> "+y
" Ctrl+j/k/h/l lets you switch between files open in :split / :vsplit
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

set number " show line numberv
"set number relativenumber

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END

set showcmd
set cursorline
set showmatch " show matching open or closing bracket
set splitbelow splitright " Opening a split window
set mouse=a " mouse can do stuff
set termguicolors
" InsertEnter * norm zz --> Vim makes line that you edit middle of the screen
autocmd InsertEnter * norm zz
" BufwritePre* %s/\s\+$//e --> any trailing whitespaces on any line are removed
autocmd BufWritePre * %s/\s\+$//e

" skeletons
if has("autocmd")
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
endif

" abbreviations! but i use it mostly for misspelling
iabbrev teh the
iabbrev hte the
