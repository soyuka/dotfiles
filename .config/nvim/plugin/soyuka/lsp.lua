local set = vim.keymap.set
local lsp = vim.lsp
local diagnostic = vim.diagnostic
local fzf_lua = require('fzf-lua')

set('n', '<C-p>', fzf_lua.files, {})
set('n', '<C-o>', function()
  fzf_lua.files({ no_ignore = true, hidden = true })
end, {})
set('n', '<C-g>', fzf_lua.live_grep, {})
set('n', '<C-b>', fzf_lua.buffers, {})

set('n', '<Leader>d', function()
  fzf_lua.diagnostics_workspace()
end, { desc = 'Show diagnostics' })

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
      if nil ~= string.find(vim.bo.filetype, "php") then
         lsp.buf.format { async = true }
      --   vim.cmd('EslintFixAll')
      else
        require("conform").format()
      end
    end, opts)

		set('n', '<Leader>o', function()
			fzf_lua.lsp_typedefs()
		end, { desc = 'Go to type definition' })

    set('n', 'gD', lsp.buf.declaration, opts)
    set('n', 'gd', function ()
        fzf_lua.lsp_definitions()
    end, opts)

    -- "grn" is mapped in Normal mode to vim.lsp.buf.rename()
    set('n', 'grr', function()
      fzf_lua.lsp_references()
    end, { desc = 'Go to references' })

    set('n', 'gri', function()
      fzf_lua.lsp_implementations()
    end, { desc = 'Go to implementation' })

    set('n', 'gO', function()
      fzf_lua.lsp_document_symbols()
    end, { desc = 'Go to document symbols' })

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
