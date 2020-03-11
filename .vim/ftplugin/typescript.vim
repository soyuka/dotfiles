setlocal ts=2
setlocal sw=2
setlocal expandtab

let g:tsuquyomi_disable_quickfix = 1
let g:tsuquyomi_shortest_import_path = 1
let g:tsuquyomi_single_quote_import = 1

nmap <Leader>u <Plug>(TsuquyomiImport)
