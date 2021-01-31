if &compatible
  set nocompatible               " Be iMproved
endif
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
Plug 'ntpeters/vim-better-whitespace'
Plug 'tpope/vim-fugitive'
Plug 'cakebaker/scss-syntax.vim'
Plug 'Yggdroot/indentLine'
Plug 'mhinz/vim-startify'
Plug 'terryma/vim-multiple-cursors'
Plug 'junegunn/vim-easy-align'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'mileszs/ack.vim'
Plug 'sjl/gundo.vim'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-obsession'
Plug 'editorconfig/editorconfig-vim'
Plug 'vim-test/vim-test'
Plug 'valloric/matchtagalways'
Plug 'leafgarland/typescript-vim'
Plug 'jiangmiao/auto-pairs'
call plug#end()

"FIX SWAP FILE WARNING
set noswapfile
set shortmess+=A
set autoread
set scrolloff=100
set regexpengine=1
set updatetime=100
set tabstop=2
set encoding=utf-8
set laststatus=2
set noshellslash
set autochdir
set showcmd
set ruler
set nu
set relativenumber
set incsearch
set hidden
set termguicolors
set noerrorbells visualbell t_vb=
set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove right-hand scroll bar
set guioptions-=e  "non-gui tabs
colorscheme jellybeans
syntax on

let mapleader=","
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
nmap <C-t> :silent execute '!open -a Terminal '.expand('%:p:h')<CR>
map <C-e> :NERDTreeToggle<CR>
map <C-l> :let @/ = ""<CR>
map <C-k> :bp<CR>
map <C-j> :bn<CR>
map <C-s> :w<CR>
map <c-f> :call Beautifier()<CR>
map <C-m> :CtrlPMRUFiles <CR>
map <C-P> :CtrlP <CR>
map <C-b> :CtrlPBuffer <CR>
noremap <Leader>a :Ack! <cword><CR>
map <Leader>d :bd<CR>

let g:ctrlp_open_multiple_files = 'ij'
let g:ctrlp_custom_ignore = {'dir' : '\v[\/](node_modules|dist|bower_components|\.git|\.hg|\.svn|public)$'}
let g:ctrlp_prompt_mappings = {'PrtDeleteEnt()': ['<c-d>']}
let g:indent_guides_enable_on_vim_startup = 1
let g:indentLine_conceallevel = 0
let g:multi_cursor_quit_key='<Esc>'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let delimitMate_expand_cr = 1
let g:ackprg = 'ag --vimgrep'
let NERDTreeShowHidden=0

autocmd BufWritePre * StripWhitespace

"Disable sound bells
if has('autocmd')
  autocmd GUIEnter * set visualbell t_vb=
endif

""" BEGIN Colors
"cursor settings
highlight Cursor guibg=orange
highlight Cursor guibg=orange
highlight Visual guibg=lightblue
highlight Visual guifg=black
highlight TabLineFill guifg=#121212
highlight TabLine guibg=#262626
highlight TabLineSel guibg=#3a3a3a
highlight LineNr guifg=DarkGrey guibg=#1c1c1c
highlight StatusLine guifg=#ffffff guibg=#555555
"vim-gitgutter colors
highlight GitGutterAdd    guifg=green guibg=0 ctermfg=green
highlight GitGutterChange guifg=yellow guibg=0 ctermfg=yellow
highlight GitGutterDelete guifg=red guibg=0 ctermfg=red
" Coc Colors Override
hi CocFloating guibg=#333333
hi CocInfoVirtualText ctermfg=103 guifg=#46465a
hi CocWarningVirtualText ctermfg=136 guifg=#af8700
hi CocErrorVirtualText ctermfg=124 guifg=red3
""" END Colors


""" BEGIN COC
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.

let g:coc_node_path = trim(system('which node'))
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
