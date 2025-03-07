setlocal ts=4
setlocal sw=4

autocmd FileType php set iskeyword+=$

let g:php_namespace_sort_after_insert = 1
nmap <Leader>u :PhpactorImportClass<CR>
nmap <Leader>e :PhpactorClassExpand<CR>
