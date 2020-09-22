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
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'fatih/vim-go'
Plug 'pangloss/vim-javascript'
Plug 'maksimr/vim-jsbeautify'
Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'
"if has('nvim')
  "Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
"else
  "Plug 'Shougo/deoplete.nvim'
  "Plug 'roxma/nvim-yarp'
  "Plug 'roxma/vim-hug-neovim-rpc'
"endif
"Plug 'deoplete-plugins/deoplete-jedi'

Plug 'ctrlpvim/ctrlp.vim'
Plug 'Raimondi/delimitMate'
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
Plug 'Yggdroot/indentLine'
Plug 'mhinz/vim-startify'
Plug 'easymotion/vim-easymotion'
Plug 'jimmyhchan/dustjs.vim'
Plug 'terryma/vim-multiple-cursors'
Plug 'rizzatti/dash.vim'
Plug 'junegunn/vim-easy-align'
"Plug 'dense-analysis/ale'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'benjie/local-npm-bin.vim'
Plug 'gabesoft/vim-ags'
Plug 'sjl/gundo.vim'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-sleuth'
Plug 'cespare/vim-toml'
Plug 'farazdagi/vim-go-ide'
Plug 'sbdchd/neoformat'
"Plug 'airblade/vim-gitgutter'
"Plug 'prettier/vim-prettier'
Plug 'martinda/Jenkinsfile-vim-syntax'
Plug 'leafgarland/typescript-vim'
Plug 'posva/vim-vue'
Plug 'vim-scripts/DrawIt'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-rvm'
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'editorconfig/editorconfig-vim'
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
"autocmd BufWritePre *.js,*scss,*.ts PrettierAsync
"let g:prettier#quickfix_enabled = 0
autocmd BufWritePre * StripWhitespace
"autocmd BufWritePre *.html set shiftwidth=2
"autocmd BufWritePre *.html set tabstop=2
"autocmd BufWritePre *.html set noexpandtab
autocmd BufEnter *.rb Rvm

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

let g:indent_guides_enable_on_vim_startup = 1
let g:indentLine_conceallevel = 0

"let g:ale_completion_enabled = 0
"let g:deoplete#enable_at_startup = 1
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

"call deoplete#custom#option('sources', {
"\ '_': ['ale'],
"\})
"autocmd FileType * setlocal omnifunc=tern#Complete


"Neosnippet tab completion
imap <expr><tab> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<c-n>" : "\<tab>"

"ACK.vim
"let g:ack_qhandler = "topleft copen 30"

"ag.vim
"let g:ag_working_path_mode='r'

"multi cursor
let g:multi_cursor_quit_key='<Esc>'

"Git (fugitive)
"map <leader><leader>g :Gcommit %:p<CR>
map <leader><leader>g :Gstatus <CR>

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

"let g:ale_fix_on_save = 1
"let g:ale_ruby_rubocop_executable = 'bundle'
"let g:ale_python_pylint_auto_pipenv = 1
"let g:ale_python_pylint_use_global = 0
"let g:ale_python_pylint_options = '--extension-pkg-whitelist=cv2,torch'
"let g:ale_linters = {
      "\ 'ruby': ['rubocop'],
      "\ 'python': ['pylint'],
      "\ 'javascript': ['eslint'],
      "\ 'html': ['prettier'],
      "\}
"let g:ale_fixers = {
      "\ 'javascript': ['prettier'],
      "\ 'python': ['black'],
      "\}

"let g:ale_python_black_auto_pipenv = 1
"let g:ale_python_black_executable = 'black'

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

""" END COC
