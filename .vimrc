let $PATH .= ':/home/soyuka/.nvm/versions/node/v12.16.1/bin'
filetype off
call plug#begin()
Plug 'christoomey/vim-tmux-navigator'
Plug 'ap/vim-css-color'
" Colorscheme
Plug 'joshdick/onedark.vim'
Plug 'scrooloose/nerdtree'
Plug 'ryanoasis/vim-devicons'
" Lightline FTW
Plug 'itchyny/lightline.vim'
" Plug 'maximbaz/lightline-ale'
" buffer manager <3, replaced by buftabline 05/11/2020 oO
" Plug 'fholgado/minibufexpl.vim'
Plug 'ap/vim-buftabline' 
" Replaces :MBEbd from minibufexpl cause it is bugged
Plug 'qpkorr/vim-bufkill'

" Asynchronous Lint Engine
" Plug 'w0rp/ale'

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
Plug 'ak5/vim-lsp-typescript'

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neoclide/coc-tsserver', {'do': 'yarn install --frozen-lockfile'}
" Plug 'prabirshrestha/asyncomplete.vim'
" Plug 'prabirshrestha/asyncomplete-lsp.vim'

" Plug 'felixfbecker/php-language-server', {'do': 'composer install && composer run-script parse-stubs'}

" Typescript plugin for auto imports
" Plug 'Quramy/tsuquyomi'
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

Plug 'dpelle/vim-Grammalecte'

" Plug 'fatih/vim-go'
call plug#end()

" My config

" Start COC config
set encoding=utf-8
" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

nmap <Leader>a <Plug>(coc-codeaction)

" highlight CocErrorHighlight ctermfg=Red guifg=#be5046
" hightlight CocErrorHighlight* for error code range.
" hightlight CocWarningHighlight* for warning code range.
" hightlight CocInfoHighlight* for information code range.
" hightlight CocHintHighlight* for hint code range.
" hightlight CocDeprecatedHighlight* for deprecated code range, links to


" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
" command! -nargs=0 Prettier :CocCommand prettier.formatFile
" GoTo code navigation.
" nmap <silent> gd <Plug>(coc-definition)
" nmap <silent> gy <Plug>(coc-type-definition)
" nmap <silent> gi <Plug>(coc-implementation)
" nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
" nnoremap <silent> K :call <SID>show_documentation()<CR>
"
" function! s:show_documentation()
"   if (index(['vim','help'], &filetype) >= 0)
"     execute 'h '.expand('<cword>')
"   elseif (coc#rpc#ready())
"     call CocActionAsync('doHover')
"   else
"     execute '!' . &keywordprg . " " . expand('<cword>')
"   endif
" endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
" nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
" xmap <leader>f  <Plug>(coc-format-selected)
" nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
" xmap <leader>a  <Plug>(coc-codeaction-selected)
" nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
" nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
" nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
" xmap if <Plug>(coc-funcobj-i)
" omap if <Plug>(coc-funcobj-i)
" xmap af <Plug>(coc-funcobj-a)
" omap af <Plug>(coc-funcobj-a)
" xmap ic <Plug>(coc-classobj-i)
" omap ic <Plug>(coc-classobj-i)
" xmap ac <Plug>(coc-classobj-a)
" omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
" if has('nvim-0.4.0') || has('patch-8.2.0750')
"   nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
"   nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
"   inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
"   inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
"   vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
"   vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
" endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
" nmap <silent> <C-s> <Plug>(coc-range-select)
" xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
" command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
" set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
" nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
" nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
" nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
" nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
" nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
" nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
" nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
" nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

" End COC config

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

source ~/.vim/color.white

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
set nowritebackup
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

set noautochdir 
" basically :lcd %:p:h in every buffer (https://vim.fandom.com/wiki/Set_working_directory_to_the_current_file)
" autocmd BufEnter * silent! lcd %:p:h

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

"paste helper
nnoremap <Leader>s :sort /^\s*\(' \)\?/<CR>

" Replaces tabs with spaces
nnoremap <Leader>t :0,$s/\t/  /g<CR>

xmap <Leader>y y:call system("wl-copy", @")<CR>

nnoremap <S-L> :bnext<CR>
nnoremap <S-H> :bprev<CR>

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

" Coc for lightline
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()
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

let g:DevIconsEnableFolderPatternMatching = 0
let g:WebDevIconsNerdTreeAfterGlyphPadding = ' '
let g:WebDevIconsUnicodeDecorateFolderNodes = 1
let g:WebDevIconsNerdTreeBeforeGlyphPadding = ''
let g:WebDevIconsNerdTreeGitPluginForceVAlign = 0
let g:WebDevIconsUnicodeDecorateFolderNodesDefaultSymbol = ''

" close vim if the only window left open is a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
" map NERDTree to ' n'
map <Leader>n :NERDTreeToggle<CR>
map <Leader>c :NERDTreeFind<CR>

" MinBufExpl options
" let g:miniBufExplBRSplit=0
" let g:miniBufExplCycleArround=1

" Comment block
vmap gb :TCommentBlock<CR>

      " \ 'colorscheme': 'onedark',
let g:lock = "🔒""
let g:lightline = {
      \ 'colorscheme': 'one',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [  'cocstatus', 'fugitive', 'readonly', 'filename', 'modified' ] ]
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
      \ 'component_function': {
      \   'cocstatus': 'coc#status',
      \ }
\ }

nnoremap <C-p> :FZF<CR>
nnoremap <C-b> :Buffers<CR>

" LSP (language server) Plugin
let g:lsp_diagnostics_enabled = 0
setlocal omnifunc=lsp#complete
nmap <Leader>o <plug>(lsp-definition)
nmap <Leader>K <plug>(lsp-hover)
"nmap <f2> <plug>(lsp-rename)

" let g:ale_linters = {
" \   'typescript': ['tslint', 'tsserver', 'typecheck'],
" \   'javascript': ['standard'],
" \}

" let g:ale_lint_on_text_changed = 'never'

" Remove highlight color from ale
" highlight clear ALEError
" highlight clear ALEWarning

map <Leader>g :GitGutterToggle<CR>

" inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
" inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" inoremap <expr> <cr> pumvisible() ? "\<C-y>\<cr>" : "\<cr>"

" todo: from @greg0ire vnoremap <leader>l :<c-u>exe '!git log -L' line("'<").','.line("'>").':'.expand('%')<CR>"'")"'")
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
