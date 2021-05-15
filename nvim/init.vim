if &compatible
  set nocompatible               " Be iMproved
endif
call plug#begin(expand('~/.vim/plugged'))
Plug 'airblade/vim-rooter'
Plug 'nanotech/jellybeans.vim'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
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
Plug 'itchyny/lightline.vim'
Plug 'josa42/vim-lightline-coc'

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
set list lcs=tab:\¦\ "preserve trailing whitespace
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
map <C-p> :CtrlP <CR>
map <C-b> :CtrlPBuffer <CR>
noremap <Leader>a :Ack! <cword><CR>
map <Leader>d :bd<CR>

let g:ctrlp_open_multiple_files = 'ij'
let g:ctrlp_custom_ignore = {'dir' : '\v[\/](node_modules|dist|bower_components|\.git|\.hg|\.svn|public)$'}
let g:ctrlp_prompt_mappings = {'PrtDeleteEnt()': ['<c-d>']}
let g:multi_cursor_quit_key='<Esc>'

"""" END LIGHTLINE """"
let g:lightline = {
      \ 'active': {
      \   'left': [
      \     [ 'mode', 'paste' ],
      \     [ 'fugitive', 'filename' ],
      \     ['ctrlpmark'],
      \     ['coc_info', 'coc_hints', 'coc_errors', 'coc_warnings', 'coc_ok'],
      \     ['coc_status']
      \   ],
      \   'right': [ [ 'syntastic', 'lineinfo' ], ['percent'], [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'component_function': {
      \   'fugitive': 'LightlineFugitive',
      \   'filename': 'LightlineFilename',
      \   'fileformat': 'LightlineFileformat',
      \   'filetype': 'LightlineFiletype',
      \   'fileencoding': 'LightlineFileencoding',
      \   'mode': 'LightlineMode',
      \   'ctrlpmark': 'CtrlPMark',
      \ },
      \ 'component_expand': {
      \   'syntastic': 'SyntasticStatuslineFlag',
      \ },
      \ 'component_type': {
      \   'syntastic': 'error',
      \ },
      \ 'subseparator': { 'left': '|', 'right': '|' }
      \ }
call lightline#coc#register()
let g:lightline.component_type = {
      \   'linter_warnings': 'warning',
      \   'linter_errors': 'error',
      \   'linter_info': 'info',
      \   'linter_hints': 'hints',
      \   'linter_ok': 'left',
      \ }
function! LightlineModified()
  return &ft ==# 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction
function! LightlineReadonly()
  return &ft !~? 'help' && &readonly ? 'RO' : ''
endfunction
function! LightlineFilename()
  let fname = expand('%:t')
  return fname ==# 'ControlP' && has_key(g:lightline, 'ctrlp_item') ? g:lightline.ctrlp_item :
        \ fname =~# '^__Tagbar__\|__Gundo\|NERD_tree' ? '' :
        \ &ft ==# 'vimfiler' ? vimfiler#get_status_string() :
        \ &ft ==# 'unite' ? unite#get_status_string() :
        \ &ft ==# 'vimshell' ? vimshell#get_status_string() :
        \ (LightlineReadonly() !=# '' ? LightlineReadonly() . ' ' : '') .
        \ (fname !=# '' ? fname : '[No Name]') .
        \ (LightlineModified() !=# '' ? ' ' . LightlineModified() : '')
endfunction
function! LightlineFugitive()
  try
    if expand('%:t') !~? 'Tagbar\|Gundo\|NERD' && &ft !~? 'vimfiler' && exists('*FugitiveHead')
      let mark = ''  " edit here for cool mark
      let branch = FugitiveHead()
      return branch !=# '' ? mark.branch : ''
    endif
  catch
  endtry
  return ''
endfunction
function! LightlineFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction
function! LightlineFiletype()
  return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype : 'no ft') : ''
endfunction
function! LightlineFileencoding()
  return winwidth(0) > 70 ? (&fenc !=# '' ? &fenc : &enc) : ''
endfunction
function! LightlineMode()
  let fname = expand('%:t')
  return fname =~# '^__Tagbar__' ? 'Tagbar' :
        \ fname ==# 'ControlP' ? 'CtrlP' :
        \ fname ==# '__Gundo__' ? 'Gundo' :
        \ fname ==# '__Gundo_Preview__' ? 'Gundo Preview' :
        \ fname =~# 'NERD_tree' ? 'NERDTree' :
        \ &ft ==# 'unite' ? 'Unite' :
        \ &ft ==# 'vimfiler' ? 'VimFiler' :
        \ &ft ==# 'vimshell' ? 'VimShell' :
        \ winwidth(0) > 60 ? lightline#mode() : ''
endfunction
function! CtrlPMark()
  if expand('%:t') ==# 'ControlP' && has_key(g:lightline, 'ctrlp_item')
    call lightline#link('iR'[g:lightline.ctrlp_regex])
    return lightline#concatenate([g:lightline.ctrlp_prev, g:lightline.ctrlp_item
          \ , g:lightline.ctrlp_next], 0)
  else
    return ''
  endif
endfunction
let g:ctrlp_status_func = {
      \ 'main': 'CtrlPStatusFunc_1',
      \ 'prog': 'CtrlPStatusFunc_2',
      \ }
function! CtrlPStatusFunc_1(focus, byfname, regex, prev, item, next, marked)
  let g:lightline.ctrlp_regex = a:regex
  let g:lightline.ctrlp_prev = a:prev
  let g:lightline.ctrlp_item = a:item
  let g:lightline.ctrlp_next = a:next
  return lightline#statusline(0)
endfunction
function! CtrlPStatusFunc_2(str)
  return lightline#statusline(0)
endfunction
let g:tagbar_status_func = 'TagbarStatusFunc'
function! TagbarStatusFunc(current, sort, fname, ...) abort
  return lightline#statusline(0)
endfunction
" Syntastic can call a post-check hook, let's update lightline there
" For more information: :help syntastic-loclist-callback
function! SyntasticCheckHook(errors)
  call lightline#update()
endfunction
let g:unite_force_overwrite_statusline = 0
let g:vimfiler_force_overwrite_statusline = 0
let g:vimshell_force_overwrite_statusline = 0
"""" END LIGHTLINE """"

let delimitMate_expand_cr = 1
"let g:ackprg = 'ag --%:e --ignore test --vimgrep'
let g:ackprg = 'ag --ignore test --vimgrep'
let NERDTreeShowHidden=0

autocmd BufWritePre * StripWhitespace

autocmd InsertEnter *.json setlocal concealcursor=
autocmd InsertLeave *.json setlocal concealcursor=inc

"Disable sound bells
if has('autocmd')
  autocmd GUIEnter * set visualbell t_vb=
endif

""" BEGIN Colors
"cursor settings
highlight Conceal ctermfg=235 guifg=#222222
highlight Whitespace ctermfg=235 guifg=#222222
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
