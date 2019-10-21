if &compatible
  set nocompatible               " Be iMproved
endif
"set runtimepath+=~/.vim/bundle/neobundle.vim/
call plug#begin(expand('~/.vim/plugged'))
Plug 'airblade/vim-rooter'
Plug 'nanotech/jellybeans.vim'
Plug 'tomasr/molokai'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
"Plug 'jeetsukumaran/vim-buffergator'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'fatih/vim-go'
Plug 'pangloss/vim-javascript'
Plug 'maksimr/vim-jsbeautify'
"Plug 'mileszs/ack.vim'
"Plug 'beautify-web/js-beautify'
"Plug 'ervandew/supertab'
Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'
Plug 'ctrlpvim/ctrlp.vim'
"Plug 'honza/vim-snippets'
Plug 'Raimondi/delimitMate'
Plug 'tpope/vim-fugitive'
Plug 'altercation/vim-colors-solarized'
Plug 'MPiccinato/wombat256'
Plug 'kchmck/vim-coffee-script'
Plug 'chriskempson/base16-vim'
Plug 'dracula/vim'
Plug 'evidens/vim-twig'
Plug 'gregsexton/MatchTag'
Plug 'tmhedberg/matchit'
Plug 'ntpeters/vim-better-whitespace'
Plug 'tpope/vim-fugitive'
Plug 'cakebaker/scss-syntax.vim'
Plug 'StanAngeloff/php.vim'
"Plug 'nathanaelkane/vim-indent-guides'
Plug 'Yggdroot/indentLine'
Plug 'mhinz/vim-startify'
Plug 'easymotion/vim-easymotion'
Plug 'jimmyhchan/dustjs.vim'
Plug 'terryma/vim-multiple-cursors'
Plug 'rizzatti/dash.vim'
"Plug 'bling/vim-bufferline'
Plug 'junegunn/vim-easy-align'
Plug 'neomake/neomake'
Plug 'benjie/local-npm-bin.vim'
"Plug 'mtscout6/syntastic-local-eslint.vim'
Plug 'gabesoft/vim-ags'
Plug 'sjl/gundo.vim'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-sleuth'
Plug 'cespare/vim-toml'
Plug 'farazdagi/vim-go-ide'
Plug 'sbdchd/neoformat'
Plug 'airblade/vim-gitgutter'
Plug 'prettier/vim-prettier'
Plug 'martinda/Jenkinsfile-vim-syntax'
Plug 'leafgarland/typescript-vim'
Plug 'posva/vim-vue'
call plug#end()

"FIX SWAP FILE WARNING
set noswapfile
set shortmess+=A
set autoread
set scrolloff=100
set regexpengine=1
set updatetime=100

"" indenting
""set cindent
"set expandtab
set tabstop=2
"set shiftwidth=2
""set softtabstop=2
"set autoindent

"autoformat js
autocmd BufWritePre *.js,*scss,*.ts PrettierAsync
let g:prettier#quickfix_enabled = 0
autocmd BufWritePre * StripWhitespace
"autocmd BufWritePre *.html set shiftwidth=2
"autocmd BufWritePre *.html set tabstop=2
"autocmd BufWritePre *.html set noexpandtab

"let localPrettier = {
      "\ 'exe': '/Users/ilia/riot/lol-bilgewater-hub-2018/node_modules/.bin/prettier',
      "\ 'args': ['--stdin', '--stdin-filepath', '%:p'],
      "\ 'stdin': 1
      "\ }
"let g:neoformat_scss_prettier = localPrettier
"let g:neoformat_json_prettier = localPrettier
"let g:neoformat_javascript_prettier = localPrettier
"let g:neoformat_html_prettier = {}

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)


let g:indent_guides_enable_on_vim_startup = 1

"Neosnippet tab completion
imap <expr><tab> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<c-j>" : "\<tab>"

"ACK.vim
"let g:ack_qhandler = "topleft copen 30"

"ag.vim
"let g:ag_working_path_mode='r'

"multi cursor
let g:multi_cursor_quit_key='<Esc>'

"Git (fugitive)
map <leader><leader>g :Gcommit %:p<CR>

"Dash keybinding
nmap <silent> <leader><leader>d <Plug>DashSearch

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
map <leader>d :bd<CR>
map <C-s> :w<CR>
map <c-f> :call Beautifier()<CR>


"let b:neomake_javascript_eslint_exe = $PWD . '/node_modules/.bin/eslint'
let g:neomake_javascript_enabled_makers = ['eslint']
let g:neomake_html_enabled_makers = []
call neomake#configure#automake('nrwi', 500)

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
