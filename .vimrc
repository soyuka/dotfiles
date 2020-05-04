let $PATH .= ':/home/soyuka/.nvm/versions/node/v12.16.1/bin'
filetype off
call plug#begin()
Plug 'christoomey/vim-tmux-navigator'
Plug 'ap/vim-css-color'
" Colorscheme
Plug 'joshdick/onedark.vim'
Plug 'scrooloose/nerdtree'
" Lightline FTW
Plug 'itchyny/lightline.vim'
" Plug 'maximbaz/lightline-ale'
" buffer manager <3
Plug 'fholgado/minibufexpl.vim'
" Replaces :MBEbd from minibufexpl cause it is bugged
Plug 'qpkorr/vim-bufkill'

" Asynchronous Lint Engine
Plug 'w0rp/ale'

" Signature when <C-Y>
Plug 'Shougo/echodoc.vim'

" Syntax
Plug 'sheerun/vim-polyglot'

" Html close tags
Plug 'docunext/closetag.vim'
" Auto close )'"`
Plug 'jiangmiao/auto-pairs'

" gcc comment
Plug 'tomtom/tcomment_vim'

" Language server support
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'ryanolsonx/vim-lsp-typescript'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'

" Typescript plugin for auto imports
Plug 'Quramy/tsuquyomi'
Plug 'Quramy/vim-js-pretty-template'
" Phpactor for namespace import
Plug 'phpactor/phpactor', {'for': 'php', 'do': 'composer install'}

" SQL plug
Plug 'shmup/vim-sql-syntax', {'for': 'sql'}

" fzf
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all'  }
Plug 'junegunn/fzf.vim'

" git gutter
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'felixfbecker/php-language-server', {'do': 'composer install && composer run-script parse-stubs'}

" Plug 'fatih/vim-go'
call plug#end()

" My config

set tags+=tags,tags.vendor

" OS determination
let g:OS = 'linux'

let os = substitute(system('uname'), '\n', '', '')
if os == 'Darwin' || os == 'Mac'
  let g:OS = 'osx'
endif

" Colors

" Disable Background Color Erase when within tmux - https://stackoverflow.com/q/6427650/102704
if &term =~ '256color'
    set t_ut=
endif

" set Vim-specific sequences for RGB colors
" see https://github.com/vim/vim/issues/993#issuecomment-255651605
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
" italic fix
let &t_ZH="\e[3m"
let &t_ZR="\e[23m"

if has("termguicolors")
  set termguicolors
endif

set background=dark
" set background=light

let g:onedark_terminal_italics = 1
colorscheme onedark
syntax on

" Settings
set nocompatible
set number " enable line numbers
set showcmd
set scrolloff=5               " keep at least 5 lines above/below
set sidescrolloff=5          " keep at least 5 lines left/right
set showmatch
" set colorcolumn=81

set hidden " allow the use of unsaved buffer
set prompt " prompt on saving
set backspace=indent,eol,start " Better handling of backspace key
set nostartofline              " Emulate typical editor navigation behaviour
set diffopt=vertical,context:4

if OS == 'osx'
  set dir=/private/tmp
else
  set dir=/tmp
endif

set nobackup
set backupcopy=yes " When watching things with webpack etc
set autoindent

" Spaces are better than a tab character
set expandtab
" global tab config
set ts=2 sw=2
set smarttab
set shiftround

set ignorecase
set incsearch
set smartcase
set spelllang=en
" set nospell
set spellsuggest=5
set showmode
set laststatus=2

" split more naturally
set splitright
set splitbelow

set cul " highlight current line

" Configure invisible characters
set nolist
" set listchars=trail:·,eol:¬,tab:┊\

set noautochdir "cd to file cwd

" wrap to previous line when cursor reach eol/beginning
set whichwrap+=<,>,h,l,[,]

" Key mapping

noremap ; :

" F/T forward backward
noremap , ;
" noremap <lt> ,

" Mapping space to leader key
map <Space> <Leader>

"semicolons helper
nnoremap <Leader>; A;<esc>

"paste helper
nnoremap <Leader>p :set paste!<CR>

" Replaces tabs with spaces
nnoremap <Leader>t :0,$s/\t/  /g<CR>

xmap <Leader>y y:call system("wl-copy", @")<CR>

nnoremap <S-L> :MBEbn<CR>
nnoremap <S-H> :MBEbp<CR>

" Delete buffer but leave window open
nnoremap <Leader>q :BD<CR>

" Navigate between splits more naturally
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

nnoremap <S-J> }
nnoremap <S-K> {

vnoremap <S-J> }
vnoremap <S-K> {

" Key mapping to expand foldings
nnoremap <C-o> za
nnoremap <C-S-O> zR
nnoremap <C-c> zM

autocmd FileType crontab setlocal nobackup nowritebackup
autocmd BufRead,BufNewFile *.md set filetype=markdown
autocmd BufRead,BufNewFile *.scss set filetype=scss.css " ultisnips css for scss
autocmd BufRead,BufNewFile *.css  source ~/.vim/ftplugin/css.vim
autocmd BufRead,BufNewFile *.php  source ~/.vim/ftplugin/php.vim
autocmd BufRead,BufNewFile *.yaml,*.yml  source ~/.vim/ftplugin/php.vim
autocmd BufRead,BufNewFile *.js source ~/.vim/ftplugin/javascript.vim
autocmd BufRead,BufNewFile *.json source ~/.vim/ftplugin/javascript.vim
autocmd BufRead,BufNewFile *.ts set filetype=typescript
autocmd BufRead,BufNewFile *.html source ~/.vim/ftplugin/html.vim
autocmd BufRead,BufNewFile *.feature set ts=2 sw=2
autocmd BufRead,BufNewFile *.rs set ts=4 sw=4

" auto remove/hi trailing space
" autocmd BufWritePre * :%s/\s\+$//e

" Echo doc
let g:echodoc#enable_at_startup = 1
let g:echodoc#type = "popup"

" NERDTree options
" Chdir to current file
let g:NERDTreeChDirMode=1
let g:NERDTreeShowBookmarks=1
" NERDTree window size
let g:NERDTreeWinSize=35
let g:NERDTreeBookmarksFile = $HOME ."/.vim/bookmarks"
let g:NERDTreeShowHidden=1
let g:NERDTreeAutoDeleteBuffer=1
let g:NERDTreeMinimalUI=1
" close vim if the only window left open is a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
" map NERDTree to ' n'
map <Leader>n :NERDTreeToggle<CR>

" MinBufExpl options
let g:miniBufExplBRSplit=0
let g:miniBufExplCycleArround=1

" Comment block
vmap gb :TCommentBlock<CR>

let g:lock = "🔒""
let g:lightline = {
      \ 'colorscheme': 'onedark',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'fugitive', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component': {
      \   'readonly': '%{&filetype=="help"?"":&readonly?"'.g:lock.'":""}',
      \   'modified': '%{&filetype=="help"?"":&modified?"+":&modifiable?"":"-"}',
      \   'fugitive': '%{exists("*fugitive#head")?fugitive#head():""}'
      \ },
      \ 'component_visible_condition': {
      \   'readonly': '(&filetype!="help"&& &readonly)',
      \   'modified': '(&filetype!="help"&&(&modified||!&modifiable))',
      \   'fugitive': '(exists("*fugitive#head") && ""!=fugitive#head())'
      \ },
\ }

nnoremap <C-p> :FZF<CR>

" LSP (language server) Plugin
let g:lsp_diagnostics_enabled = 0
setlocal omnifunc=lsp#complete
nmap <Leader>o <plug>(lsp-definition)
nmap <Leader>K <plug>(lsp-hover)
"nmap <f2> <plug>(lsp-rename)

let g:ale_linters = {
\   'typescript': ['tslint', 'tsserver', 'typecheck'],
\   'javascript': ['standard'],
\}

let g:ale_lint_on_text_changed = 'never'

" Remove highlight color from ale
highlight clear ALEError
highlight clear ALEWarning

map <Leader>g :GitGutterToggle<CR>

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>\<cr>" : "\<cr>"

source ~/.vim/no_distraction_mode
nnoremap <F12> :call ToggleNoDistractionMode()<CR>

" cnoremap - tells Vim that the following mappings that is used when in command-line mode
" w!! - the mapping (shortcut) itself.
" execute '<command>' - executes a command between the quotes
" silent! - run it silently
" write !sudo tee % >/dev/null - the magic trick which would take another email to explain
" <bar> edit! - this calls the edit command to reload the buffer and then avoid messages such as "the buffer has changed".
cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

" Command that searches the word under the cursor
" vnoremap <C-n>  y:%s/<C-R>=escape(@",'/\')<CR>/
" vim:ft=vim:tabstop=2:shiftwidth=2:softtabstop=2:smarttab:shiftround:expandtab

let g:lsp_log_verbose = 1
let g:lsp_log_file = expand('~/vim-lsp.log')
" au User lsp_setup call lsp#register_server({
"      \ 'name': 'php-language-server',
"      \ 'cmd': {server_info->['php', expand('~/.vim/plugged/php-language-server/bin/php-language-server.php')]},
"      \ 'whitelist': ['php'],
"      \ })
