local NoDistraction = { enabled = 0 }

NoDistraction.enable = function()
  NoDistraction.enabled = 1
  vim.cmd([[
    set noshowmode
    set noruler
    set laststatus=0
    set noshowcmd
    set nonumber
    set showtabline=0
  ]])
  vim.diagnostic.config({
    virtual_text = false,
    virtual_lines = false,
    signs = false,
    underline = false
  })
end

NoDistraction.disable = function()
  NoDistraction.enabled = 0
  vim.cmd([[
    set showmode
    set ruler
    set laststatus=2
    set showcmd
    set number
    set showtabline=2
  ]])
  vim.diagnostic.config({
    virtual_text = true,
    virtual_lines = true,
    signs = true,
    underline = true
  })
end

NoDistraction.toggle = function()
  if NoDistraction.enabled == 0 then
    NoDistraction.enable()
  else
    NoDistraction.disable()
  end
end

vim.keymap.set('n', '<Leader>F', function()
  NoDistraction.toggle()
end)
