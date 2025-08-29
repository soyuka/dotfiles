local set = vim.opt
local global_set = vim.g

-- disable netrw at the very start of your init.lua (strongly advised)
-- from https://github.com/nvim-tree/nvim-tree.lua
global_set.loaded_netrw = 1
global_set.loaded_netrwPlugin = 1
global_set.mapleader = ' '

-- https://github.com/ap/vim-buftabline
set.hidden = true
set.termguicolors = true
set.number = true
set.scrolloff = 5
set.sidescrolloff = 5
set.showmatch = true
set.tabstop = 2
set.relativenumber = true
set.shiftwidth = 2
set.softtabstop = 2
set.expandtab = true
set.ignorecase = true
set.smartcase = true
set.hlsearch = false

set.splitright = true
set.splitbelow = true
set.cul = true
set.completeopt = { 'menu', 'menuone', 'noselect' }
set.background = "light"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
set.rtp:prepend(lazypath)

require("lazy").setup({
  { 'tpope/vim-markdown' },
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('nvim-tree').setup()
      -- Autoclose https://github.com/nvim-tree/nvim-tree.lua/issues/1368
      vim.api.nvim_create_autocmd("QuitPre", {
        callback = function()
          local invalid_win = {}
          local wins = vim.api.nvim_list_wins()
          for _, w in ipairs(wins) do
            local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
            if bufname:match("NvimTree_") ~= nil then
              table.insert(invalid_win, w)
            end
          end
          if #invalid_win == #wins - 1 then
            -- Should quit, so we close all invalid windows.
            for _, w in ipairs(invalid_win) do vim.api.nvim_win_close(w, true) end
          end
        end
      })
    end
  },
  {
    'olimorris/onedarkpro.nvim',
    -- 'lourenci/github-colors',
    lazy = false,  -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      -- load the colorscheme here
      if vim.o.background == "light" then
        vim.cmd("colorscheme onelight")
      else
        vim.cmd("colorscheme onedark")
      end
    end,
  },
  { "FooSoft/vim-argwrap",
    config = function()
      vim.g.argwrap_tail_comma = 1
    end,
    cmd = "ArgWrap",
    keys = {
      { "<leader>j", "<CMD>ArgWrap<CR>" },
    },
  },
  { 'isobit/vim-caddyfile' },
  { 'christoomey/vim-tmux-navigator', lazy = false },
  { 'ap/vim-css-color' },
  { 'ap/vim-buftabline' },
  { 'famiu/bufdelete.nvim' },
  { 'windwp/nvim-autopairs',          config = function() require('nvim-autopairs').setup() end },
  {
    'nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-treesitter.configs').setup({
        highlight = {
          enable = true,
        }
      })
    end,
    build = function()
      vim.cmd('TSUpdate')
    end
  },
  { 'numToStr/Comment.nvim',     config = function() require('Comment').setup() end },
  { 'nvim-lualine/lualine.nvim', config = function() require('lualine').setup() end },
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    -- Optional dependencies
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
    config = function ()
      local oil = require('oil')
      oil.setup({
        keymaps = {
          ["<C-h>"] = false,
          ["<C-l>"] = false,
        },
      })
    end
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      {
        'neovim/nvim-lspconfig',
        config = function()
          local lspconfig = require('lspconfig')
          local servers = {
            "lua_ls",
            "intelephense", -- waiting for https://github.com/phpspec/prophecy-phpunit/pull/56 lol
            "ts_ls",
            "html",
            "cssls",
            "jsonls",
            "yamlls",
            "marksman",
            "efm",
            -- "tailwindcss",
            "ccls",
            "eslint",
          }

          for _, lsp in ipairs(servers) do
            lspconfig[lsp].setup {
              flags = {
                debounce_text_changes = 150,
              }
            }
          end

          lspconfig.ts_ls.setup {
            cmd = { "deno", "run", "--allow-all", "npm:typescript-language-server", "--stdio" }
          }

          -- lspconfig.postgres_lsp.setup {
          --   cmd = { "postgres_lsp", "lsp-proxy", "--config-path=/home/soyuka/work/owen/owen-union-sociale-des-scop-et-scic" }
          -- }

          lspconfig.intelephense.setup {
            cmd = { "deno", "run", "--allow-all", "npm:intelephense", "--", "--stdio" }
          }

          lspconfig.sqlls.setup {
            cmd = { "deno", "run", "--allow-all", "npm:sql-language-server", "--", "--stdio" }
          }

          lspconfig.jsonls.setup {
            cmd = { "deno", "run", "--allow-all", "npm:vscode-json-languageserver", "--", "--stdio" }
          }

          lspconfig.yamlls.setup {
            cmd = { "deno", "run", "--allow-all", "npm:yaml-language-server", "--", "--stdio" }
          }
        end
      },
      'sindrets/diffview.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      { 'petertriho/cmp-git', dependencies = { 'nvim-lua/plenary.nvim' } },
      {
        'L3MON4D3/LuaSnip',
        dependencies = { 'rafamadriz/friendly-snippets' },
        build = 'make install_jsregexp',
        config = function()
          require('luasnip.loaders.from_vscode').lazy_load()
        end
      },
      {
        'phpactor/phpactor',
        build = 'composer install --no-dev -o',
        config = function()
          local lspconfig = require('lspconfig')
          lspconfig.phpactor.setup {
            init_options = {
              ["language_server_phpstan.enabled"] = true,
              ["language_server_phpstan.bin"] = '/home/soyuka/.local/bin/phpstan',
              ["language_server_psalm.enabled"] = false,
              -- ["language_server_psalm.bin"] = '/home/soyuka/.local/bin/psalm',
              ["language_server_php_cs_fixer.enabled"] = true,
              ["language_server_php_cs_fixer.bin"] = '/home/soyuka/.local/bin/php-cs-fixer',
            },
            flags = {
              debounce_text_changes = nil,
            }
          }
        end
      },
    },
    config = function()
      local lspconfig = require('lspconfig')
      local lsp_defaults = lspconfig.util.default_config

      lsp_defaults.capabilities = vim.tbl_deep_extend(
        'force',
        lsp_defaults.capabilities,
        require('cmp_nvim_lsp').default_capabilities()
      )
    end
  },
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    config = function() 
      require("fzf-lua").setup({
        "hide",
      })
    end
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-fzf-native.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
      'nvim-telescope/telescope-dap.nvim',
    },
    config = function()
      local telescope = require('telescope')
      telescope.setup({
        defaults = {
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "-l",
          }
        }
      })

      telescope.load_extension("ui-select")
      telescope.load_extension("dap")
    end
  },
  'nelsyeung/twig.vim',
  'sindrets/diffview.nvim',
  {
    "ray-x/lsp_signature.nvim",
    event = "InsertEnter",
  },
  {
    'stevearc/conform.nvim',
    opts = {},
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          php = { lsp_format = "first" },
          -- lua = { "stylua" },
          -- Conform will run multiple formatters sequentially
          -- python = { "isort", "black" },
          -- You can customize some of the format options for the filetype (:help conform.format)
          -- rust = { "gomft", lsp_format = "fallback" },
          sql = { "pg_format" },
          markdown = { "deno_fmt" },
          -- Conform will run the first available formatter
          -- javascript = { "prettierd", "prettier", stop_after_first = true },
        },
      })
    end
  },
  {
    "robitx/gp.nvim",
    config = function()
      require("gp").setup(require('./prompt-config'))
    end,
  },
  {
    "mfussenegger/nvim-dap",
  },
  { 
    "rcarriga/nvim-dap-ui", dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"},
    config = function()
      require('dapui').setup()
      -- require('dapui').setup({
      --   layouts = {
      --     {
      --       elements = {
      --         { id = "scopes", size = 0.25 },
      --         { id = "breakpoints", size = 0.25 },
      --         { id = "watches", size = 0.25 },
      --       },
      --       position = "left",
      --       size = 40
      --     },
      --     {
      --       elements = {
      --         { id = "repl", size = 0.5 },
      --         { id = "stacks", size = 0.5 },
      --       },
      --       position = "bottom",
      --       size = 10
      --     }
      --   }
      -- })
    end
  }

  -- {
  --   "Davidyz/VectorCode",
  --   version = "*",
  --   build = "pipx upgrade vectorcode", -- optional but recommended if you set `version = "*"`
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   cmd = "VectorCode",
  --   config = function()
  --     require("vectorcode").setup({
  --        async_backend = "lsp", -- or "lsp"
  --       -- number of retrieved documents
  --       -- n_query = 1,
  --     })
  --     local vectorcode_cacher = require("vectorcode.config").get_cacher_backend()
  --     vim.api.nvim_create_autocmd({ 'BufReadPre' }, {
  --       pattern = { "*.php", "*.sql", "*.js", "*.ts", "*.md" },
  --       callback = function(args)
  --         if not vectorcode_cacher.buf_is_registered(args.buf) then
  --           vectorcode_cacher.register_buffer(
  --             args.buf,
  --             {
  --               n_query = 1,
  --               exclude_this = false,
  --
  --             }
  --           )
  --         end
  --       end
  --     })
  --
  --     vim.api.nvim_create_autocmd({ 'BufDelete' }, {
  --       pattern = { "*.php", "*.sql", "*.js", "*.ts", "*.md" },
  --       callback = function(args)
  --         if vectorcode_cacher.buf_is_registered(args.buf) then
  --           vectorcode_cacher.deregister_buffer(
  --             args.buf
  --           )
  --         end
  --       end,
  --     })
  --   end
  -- },
  -- {
  --   "robitx/gp.nvim",
  --   config = function()
  --     require("gp").setup(require('./prompt-config'))
  --   end,
  -- },
  -- {
  --   'milanglacier/minuet-ai.nvim',
  --   config = function()
  --     local vectorcode_cacher = require("vectorcode.config").get_cacher_backend()
  --
  --     require('minuet').setup {
  --       -- after_cursor_filter_length = 30,
  --       -- n_completions = 1, -- recommend for local model for resource saving
  --       provider = 'gemini',
  --       -- after_cursor_filter_length = 30,
  --       notify = 'debug',
  --       provider_options = {
  --         gemini = {
  --           model = 'gemini-2.0-flash',
  --           api_key = 'GEMINI_API_KEY',
  --           system = {
  --             template = '{{{prompt}}}\n{{{guidelines}}}\n{{{n_completion_template}}}\n{{{repo_context}}}',
  --             -- repo_context = [[9. Additional context from other files in the repository will be enclosed in <repo_context> tags. Each file will be separated by <file_separator> tags, containing its relative path and content.]],
  --           },
  --           chat_input = {
  --             template = '{{{repo_context}}}\n{{{language}}}\n{{{tab}}}\n<contextBeforeCursor>\n{{{context_before_cursor}}}<cursorPosition>\n<contextAfterCursor>\n{{{context_after_cursor}}}',
  --             -- repo_context = function(_, _, _)
  --             --   local prompt_message = ''
  --             --   local cache_result = vectorcode_cacher.query_from_cache()
  --             --
  --             --   for _, file in ipairs(cache_result) do
  --             --     prompt_message = prompt_message
  --             --         .. '<file_separator>'
  --             --         .. file.path
  --             --         .. '\n'
  --             --         .. file.document
  --             --   end
  --             --   if prompt_message ~= '' then
  --             --     prompt_message = '<repo_context>\n' .. prompt_message .. '\n</repo_context>'
  --             --   end
  --             --   return prompt_message
  --             -- end,
  --           },
  --         },
  --         openai_fim_compatible = {
  --           model = 'qwen2.5-coder-7b-instruct',
  --           end_point = 'http://127.0.0.1:1234/v1/completions',
  --           api_key = function() return 'dummy' end,
  --           stream = true,
  --           template = {
  --             prompt = function(pref, suff)
  --               local prompt_message = ""
  --               local cache_result = vectorcode_cacher.query_from_cache(0)
  --               for _, file in ipairs(cache_result) do
  --                 prompt_message = prompt_message .. "<|file_sep|>" .. file.path .. "\n" .. file.document
  --               end
  --               return prompt_message
  --                   .. "<|fim_prefix|>"
  --                   .. pref
  --                   .. "<|fim_suffix|>"
  --                   .. suff
  --                   .. "<|fim_middle|>"
  --             end,
  --             suffix = false,
  --           },
  --         }
  --       }
  --     }
  --   end,
  --   dependencies = {
  --     'nvim-lua/plenary.nvim'
  --   }
  -- },
})
