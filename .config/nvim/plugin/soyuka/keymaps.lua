local set = vim.keymap.set

local lsp = vim.lsp
local diagnostic = vim.diagnostic

-- keep register when pasting (https://vi.stackexchange.com/a/39907)
set("x", "p", "P", { silent = true })
set('n', ';', ':')
set({ 'n', 'v' }, ',', ';')
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
set('n', '<Leader>v', ':BufferLineTogglePin<CR>')
-- set('n', '<Leader>c', function()
--   local current_buffer_dir = vim.fn.expand('%:p:h')
--   if current_buffer_dir == '' then
--     vim.cmd('Oil .')
--   else
--     vim.cmd('Oil ' .. vim.fn.escape(current_buffer_dir, ' '))
--   end
-- end, { noremap = true, silent = true, desc = 'Oil: Open current buffer directory' })

set({ 'n', 'v'}, '<Leader>g', ':\'<,\'>GpCodeWithContext<CR>')
set('n', '[d', diagnostic.goto_prev)
set('n', ']d', diagnostic.goto_next)
set('n', '<Leader>d', diagnostic.setloclist)

