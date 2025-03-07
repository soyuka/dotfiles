local set = vim.keymap.set
local telescope = require('telescope.builtin')
local lsp = vim.lsp
local diagnostic = vim.diagnostic

set('n', ';', ':')
set('n', ',', ';')
set('n', 'Y', 'yy')
set('n', '<Leader>p', ':set paste!<CR>')
set('x', '<Leader>y', 'y:call system("wl-copy", @")<CR>')
set({ 'n', 'v' }, '<S-J>', '}')
set({ 'n', 'v' }, '<S-K>', '{')
set('n', '<Leader>t', ':0,$s/\t/  /g<CR>')
set('n', '<S-L>', ':bnext<CR>')
set('n', '<S-H>', ':bprev<CR>')
set('n', '<Leader>q', ':Bdelete<CR>')

set('n', '<Leader>n', ':NvimTreeToggle<CR>')
set('n', '<Leader>c', ':NvimTreeFindFile<CR>')

set({ 'n', 'v'}, '<Leader>g', ':\'<,\'>GpCodeWithContext<CR>')

set('n', '<C-p>', telescope.find_files, {})
set('n', '<C-o>', function()
  telescope.find_files({ no_ignore = true, hidden = true })
end, {})
set('n', '<C-g>', telescope.live_grep, {})
set('n', '<C-b>', telescope.buffers, {})

set('n', '[d', diagnostic.goto_prev)
set('n', ']d', diagnostic.goto_next)
set('n', '<Leader>d', diagnostic.setloclist)

-- 'omnifunc' is set to vim.lsp.omnifunc(), use i_CTRL-X_CTRL-O to trigger completion.
-- 'tagfunc' is set to vim.lsp.tagfunc(). This enables features like go-to-definition, :tjump, and keymaps like CTRL-], CTRL-W_], CTRL-W_} to utilize the language server.
-- 'formatexpr' is set to vim.lsp.formatexpr(), so you can format lines via gq if the language server supports it.
-- To opt out of this use gw instead of gq, or clear 'formatexpr' on LspAttach.

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- conform fallsback on lsp.buf.format
    set('n', '<Leader>f', function()
      require("conform").format()
      -- lsp.buf.format { async = true }
      -- if nil ~= string.find(vim.bo.filetype, "typescript") then
      --   vim.cmd('EslintFixAll')
      -- end
    end, opts)

    set('n', '<Leader>o', lsp.buf.type_definition)
    set('n', 'gD', lsp.buf.declaration, opts)
    set('n', 'gd', lsp.buf.definition, opts)

    -- "grn" is mapped in Normal mode to vim.lsp.buf.rename()
    set('n', 'grr', lsp.buf.references, opts)
    set('n', 'gri', lsp.buf.implementation, opts)
    set('n', 'gO', lsp.buf.document_symbol, opts)
    set('i', '<C-S>', lsp.buf.signature_help, opts)

    -- set('n', '<Leader>r', function ()
    --     local vectorcode_cacher = require("vectorcode.config").get_cacher_backend()
    --   vectorcode_cacher.register_buffer(opts.buffer)
    -- end, opts)
    -- "grr" is mapped in Normal mode to vim.lsp.buf.references()
    -- "gri" is mapped in Normal mode to vim.lsp.buf.implementation()
    -- "gO" is mapped in Normal mode to vim.lsp.buf.document_symbol()
    -- CTRL-S is mapped in Insert mode to vim.lsp.buf.signature_help()

    -- K is mapped to vim.lsp.buf.hover() unless 'keywordprg' is customized or a custom keymap for K exists.
    -- K is already mapped, we use leader+h
    set('n', '<Leader>h', lsp.buf.hover, opts)

    -- "gra" is mapped in Normal and Visual mode to vim.lsp.buf.code_action(), we map this to leader+a
    -- vim.keymap.del('n', 'gra', opts)
    set({ 'n', 'v' }, '<Leader>a', lsp.buf.code_action)

    -- set('n', '<C-k>', lsp.buf.signature_help, opts)
  end
})
