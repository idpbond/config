if &compatible
  set nocompatible               " Be iMproved
endif
"set runtimepath+=~/.vim/bundle/neobundle.vim/
call plug#begin(expand('~/.vim/plugged'))
Plug 'airblade/vim-rooter'
Plug 'nanotech/jellybeans.vim'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'pangloss/vim-javascript'
Plug 'maksimr/vim-jsbeautify'
Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'Raimondi/delimitMate'
Plug 'gregsexton/MatchTag'
"Plug 'tmhedberg/matchit'
Plug 'ntpeters/vim-better-whitespace'
Plug 'tpope/vim-fugitive'
Plug 'cakebaker/scss-syntax.vim'
Plug 'Yggdroot/indentLine'
Plug 'mhinz/vim-startify'
"Plug 'easymotion/vim-easymotion'
Plug 'terryma/vim-multiple-cursors'
Plug 'junegunn/vim-easy-align'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
"Plug 'benjie/local-npm-bin.vim'
Plug 'gabesoft/vim-ags'
Plug 'sjl/gundo.vim'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-obsession'
"Plug 'tpope/vim-rvm'
Plug 'editorconfig/editorconfig-vim'
call plug#end()

"FIX SWAP FILE WARNING
set noswapfile
set shortmess+=A
set autoread
set scrolloff=100
set regexpengine=1
set updatetime=100
set tabstop=2

"autoformat js
autocmd BufWritePre * StripWhitespace
"autocmd BufEnter *.rb Rvm

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

let g:indent_guides_enable_on_vim_startup = 1
let g:indentLine_conceallevel = 0

"multi cursor
let g:multi_cursor_quit_key='<Esc>'

"FIXES FOR AIRLINE
set encoding=utf-8
let g:airline_powerline_fonts = 1
"set guifont=DejaVu\ Sans\ Mono\ for\ Powerline:h15
"set guifont=Menlo\ for\ Powerline:h18

let mapleader=","
set laststatus=2
set noshellslash
set autochdir
set showcmd
set ruler
set nu
set relativenumber
set incsearch
"something about buffers
set hidden
colorscheme jellybeans
map <C-l> :let @/ = ""<CR>
syntax on
set termguicolors
let g:airline#extensions#tabline#enabled = 1
let delimitMate_expand_cr = 1

"OSX only: open terminal in pwd
nmap <C-t> :silent execute '!open -a Terminal '.expand('%:p:h')<CR>

"buffer traversal
map <C-k> :bp<CR>
map <C-j> :bn<CR>
map <C-s> :w<CR>
map <c-f> :call Beautifier()<CR>

"CtrlP bindings and ignore
map <C-m> :CtrlPMRUFiles <CR>
map <C-P> :CtrlP <CR>
map <C-b> :CtrlPBuffer <CR>
let g:ctrlp_open_multiple_files = 'ij'
let g:ctrlp_custom_ignore = {
    \ 'dir' : '\v[\/](node_modules|dist|bower_components|\.git|\.hg|\.svn|public)$',
    \}
let g:ctrlp_prompt_mappings = {
      \ 'PrtDeleteEnt()':       ['<c-d>'],
      \ }

"Disable NERDTree hidden files"
let NERDTreeShowHidden=0
map <C-e> :NERDTreeToggle<CR>

"Disabling GUIs
set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove right-hand scroll bar
set guioptions-=e  "non-gui tabs

"Disable sound bells
set noerrorbells visualbell t_vb=
if has('autocmd')
  autocmd GUIEnter * set visualbell t_vb=
endif

"cursor settings
highlight Cursor guibg=orange
highlight Cursor guibg=orange
highlight Visual guibg=lightblue
highlight Visual guifg=black
let g:buffergator_viewport_split_policy = "T"
let g:buffergator_hsplit_size = 15
let g:buffergator_sort_regime = "mru"
highlight TabLineFill guifg=#121212
highlight TabLine guibg=#262626
highlight TabLineSel guibg=#3a3a3a
highlight LineNr guifg=DarkGrey guibg=#1c1c1c
highlight StatusLine guifg=#ffffff guibg=#555555

"vim-gitgutter colors
highlight GitGutterAdd    guifg=green guibg=0 ctermfg=green
highlight GitGutterChange guifg=yellow guibg=0 ctermfg=yellow
highlight GitGutterDelete guifg=red guibg=0 ctermfg=red


""" BEGIN COC
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
let g:coc_snippet_next = '<Tab>'
let g:coc_snippet_prev = '<S-Tab>'
imap <C-Enter>     <Plug>(neosnippet_expand_or_jump)
smap <C-Enter>     <Plug>(neosnippet_expand_or_jump)

" use <tab> for trigger completion and navigate to the next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction
inoremap <silent><expr> <Tab>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()

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

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

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
  else
    call CocAction('doHover')
  endif
endfunction

nmap <silent><Leader>hs :CocCommand git.chunkStage<CR>
nmap <silent><Leader>hu :CocCommand git.chunkUndo<CR>
""" END COC
