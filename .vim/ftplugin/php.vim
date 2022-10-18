setlocal ts=4
setlocal sw=4
setlocal expandtab
setlocal autoindent
setlocal smarttab

autocmd FileType php set iskeyword+=$
nmap <Leader>u :PhpactorImportClass<CR>
nmap <Leader>e :PhpactorClassExpand<CR>
nmap <Leader>i :PhpactorTransform<CR>
nmap <Leader>f :CocCommand php-cs-fixer.fix<CR>

let g:php_namespace_sort_after_insert = 1

" For php get/set
let g:no_php_maps = 1
" nnmap <buffer> <Leader> <Plug>PhpgetsetInsertGetterSetter
" <Plug>PhpgetsetInsertGetterOnly
" <Plug>PhpgetsetInsertSetterOnly
" <Plug>PhpgetsetInsertBothGetterSetter
