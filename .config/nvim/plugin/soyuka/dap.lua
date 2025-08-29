-- local dap = require("dap")
local dap , dapui = require("dap"), require("dapui")
local set = vim.keymap.set

dap.listeners.after.event_initialized.dapui_config = function()
  vim.keymap.set('n', '<Down>', dap.step_over, { noremap = true, silent = true })
  vim.keymap.set('n', '<Right>', dap.step_into, { noremap = true, silent = true })
  vim.keymap.set('n', '<Left>', dap.step_out, { noremap = true, silent = true })
  vim.keymap.set('n', '<Up>', dap.continue, { noremap = true, silent = true })
end

dap.listeners.before.attach.dapui_config = function()
  dapui.open({})
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  vim.keymap.del('n', '<Down>')
  vim.keymap.del('n', '<Right>')
  vim.keymap.del('n', '<Left>')
  vim.keymap.del('n', '<Up>')
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  vim.keymap.del('n', '<Down>')
  vim.keymap.del('n', '<Right>')
  vim.keymap.del('n', '<Left>')
  vim.keymap.del('n', '<Up>')
  dapui.close()
end
dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end

set('n', '<Down>', dap.step_over, { noremap = true, silent = true, buffer = true })
set('n', '<Right>', dap.step_into, { noremap = true, silent = true, buffer = true })
set('n', '<Left>', dap.step_out, { noremap = true, silent = true, buffer = true })
set('n', '<Up>', dap.continue, { noremap = true, silent = true, buffer = true })

dap.adapters.php = {
  type = 'executable',
  command = 'node',
  args = { '/home/soyuka/forks/vscode-php-debug/out/phpDebug.js' }
}

dap.listeners.after.event_initialized.dap_repl = function()
  require('dap.ext.autocompl').attach()
end

dap.configurations.php = {
  {
    type = 'php',
    request = 'launch',
    name = 'Listen for Xdebug',
    port = 9003
  }
}

vim.keymap.set('n', '<Leader>s', ':DapNew<CR>', { desc = "Start a new DAP session" })
vim.keymap.set('n', '<Leader>st', ':DapTerminate<CR>', { desc = "Start a new DAP session" })
vim.keymap.set('n', '<Leader>S', function()
    dapui.toggle({reset = true})
end, { desc = "Toggle DAP UI" })
vim.keymap.set('n', '<Leader>b', function() require('dap').toggle_breakpoint() end)
vim.keymap.set('n', '<Leader>B', function() require('dap').set_breakpoint() end)
vim.keymap.set('n', '<Leader>lp', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
-- vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end)
vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end)
-- vim.keymap.set({'n', 'v'}, '<Leader>dh', function()
--   require('dap.ui.widgets').hover()
-- end)
-- vim.keymap.set({'n', 'v'}, '<Leader>dp', function()
--   require('dap.ui.widgets').preview()
-- end)
-- vim.keymap.set('n', '<Leader>df', function()
--   local widgets = require('dap.ui.widgets')
--   widgets.centered_float(widgets.frames)
-- end)
-- vim.keymap.set('n', '<Leader>ds', function()
--   local widgets = require('dap.ui.widgets')
--   widgets.centered_float(widgets.scopes)
-- end)

vim.keymap.set('n', '<Leader>bc', function()
  vim.ui.input({
    prompt = "Breakpoint condition: ",
    default = ""
  }, function(input)
    if input ~= nil and input ~= "" then
      dap.toggle_breakpoint(input)
    else
      dap.toggle_breakpoint()
    end
  end)
end, { noremap = true, silent = true, desc = "Toggle conditional breakpoint" })
