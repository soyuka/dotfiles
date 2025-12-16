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
set.background = "dark"

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
  -- { 'ap/vim-buftabline' },
  {
    'akinsho/bufferline.nvim', version = "*", dependencies = 'echasnovski/mini.icons', config = function ()
        require('bufferline').setup({
            options = {
                auto_toggle_bufferline = true,
                always_show_bufferline = false,
                show_buffer_icons = false,
                show_close_icon = false,
                show_buffer_close_icons = false,
            }
        })
    end
  },
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
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', 'olimorris/codecompanion.nvim' },
    config = function()
      local system_status = { processing = false }

      -- Create an autocommand group to listen for CodeCompanion events
      local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})

      vim.api.nvim_create_autocmd({ "User" }, {
        pattern = "CodeCompanionRequest*",
        group = group,
        callback = function(request)
          if request.match == "CodeCompanionRequestStarted" then
            system_status.processing = true
          elseif request.match == "CodeCompanionRequestFinished" then
            system_status.processing = false
          end
          -- Force redraw of statusline to show the change immediately
          require("lualine").refresh()
        end,
      })

      -- The actual component function
      local function codecompanion_spinner()
        if not system_status.processing then return nil end
        local spinner_symbols = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
        local spinner_index = math.floor(vim.loop.now() / 100) % #spinner_symbols + 1
        return " " .. spinner_symbols[spinner_index] .. " Processing..."
      end

      -- Condition: Return false if the current buffer is a CodeCompanion chat
      local function not_in_chat()
        return vim.bo.filetype ~= "codecompanion"
      end

      require('lualine').setup({
        sections = {
          -- Standard Mode display (keep this)
          lualine_a = { 'mode' },

          -- Hide branch, diff, and diagnostics when in Chat
          lualine_b = {
            { 'branch', cond = not_in_chat },
            { 'diff', cond = not_in_chat },
            { 'diagnostics', cond = not_in_chat }
          },

          -- Keep filename in the middle
          lualine_c = { 'filename' },

          -- Show spinner always, but hide encoding/format in chat to save space
          lualine_x = {
            codecompanion_spinner,
            { 'encoding', cond = not_in_chat },
            { 'fileformat', cond = not_in_chat },
            'filetype'
          },
        }
      })
    end
  },
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
            vim.lsp.config(lsp, {
              flags = {
                debounce_text_changes = 150,
              }
            })
          end

          vim.lsp.config('ts_ls', {
            cmd = { "deno", "run", "--allow-all", "npm:typescript-language-server", "--", "--stdio" },
            filetypes = { 'ts' }
          })

          -- lspconfig.postgres_lsp.setup {
          --   cmd = { "postgres_lsp", "lsp-proxy", "--config-path=/home/soyuka/work/owen/owen-union-sociale-des-scop-et-scic" }
          -- }

          vim.lsp.config('intelephense', {
            cmd = { "deno", "run", "--allow-all", "npm:intelephense", "--", "--stdio" },
            filetypes = { 'php' }
          })

          vim.lsp.config('sqll', {
            cmd = { "deno", "run", "--allow-all", "npm:sql-language-server", "--", "--stdio" },
            filetypes = { 'sql' }
          })

          vim.lsp.config('jsonls', {
            cmd = { "deno", "run", "--allow-all", "npm:vscode-json-languageserver", "--", "--stdio" },
            filetypes = { 'json', 'jsonc', 'json5' }
          })

          vim.lsp.config('yamlls', {
            cmd = { "deno", "run", "--allow-all", "npm:yaml-language-server", "--", "--stdio" },
            filetypes = { 'yaml', 'yml' }
          })
          for _, lsp in ipairs(servers) do
            vim.lsp.enable(lsp)
          end

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
          vim.lsp.config('phpactor', {
            init_options = {
              ["language_server_phpstan.enabled"] = true,
              ["language_server_phpstan.bin"] = '/home/soyuka/.local/bin/phpstan',
              ["language_server_psalm.enabled"] = false,
              -- ["language_server_psalm.bin"] = '/home/soyuka/.local/bin/psalm',
              ["language_server_php_cs_fixer.enabled"] = true,
              ["language_server_php_cs_fixer.bin"] = '/home/soyuka/.local/bin/php-cs-fixer',
            },
            filetypes = { 'php' },
            flags = {
              debounce_text_changes = nil,
            }
          })

          vim.lsp.enable('phpactor')

        end
      },
    },
    config = function()
      vim.lsp.config('*', {
        capabilities = {
          require('cmp_nvim_lsp').default_capabilities()
        }
      })
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
  {
      "rachartier/tiny-inline-diagnostic.nvim",
      event = "VeryLazy",
      priority = 1000,
      config = function()
          require("tiny-inline-diagnostic").setup()
          vim.diagnostic.config({ virtual_text = false }) -- Disable Neovim's default virtual text diagnostics
      end,
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
    "ravitemer/mcphub.nvim",
    build = "npm install -g mcp-hub@latest",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("mcphub").setup()
    end
  },
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ibhagwan/fzf-lua",
      "Davidyz/VectorCode",
      "ravitemer/codecompanion-history.nvim",
      "ravitemer/mcphub.nvim",
    },
    config = true,
    opts = {
      display = {
        chat ={
          window = {
            layout = "buffer"
          },
        }
      },
      strategies = {
        chat = {
          adapter = "copilot",
          tools = {
            opts = {
              default_tools = {
                -- "vectorcode_toolbox",
                "mcp",
                "files",
                "github",
                "time",
                "neovim",
                "vectorcode",
                -- "cmd_runner",
              },
            },
          },
          slash_commands = {
            ["file"] = {
              opts = {
                provider = "fzf_lua",
                contains_code = true,
              },
              keymaps = {
                modes = {
                  n = "<C-p>",
                  i = "<C-p>",
                },
              },
            },
            ["buffer"] = {
              opts = {
                provider = "fzf_lua",
                contains_code = true,
              },
              keymaps = {
                modes = {
                  n = "<C-b>",
                  i = "<C-b>", 
                },
              },
            },
            ["symbols"] = {
              opts = {
                provider = "fzf_lua",
              },
            },
          },
        },
        inline = {
          adapter = "copilot",
        },
        agent = {
          adapter = "copilot",
        },
      },
      extensions = {
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            -- MCP Tools 
            make_tools = true,              -- Make individual tools (@server__tool) and server groups (@server) from MCP servers
            show_server_tools_in_chat = true, -- Show individual tools in chat completion (when make_tools=true)
            add_mcp_prefix_to_tool_names = false, -- Add mcp__ prefix (e.g `@mcp__github`, `@mcp__neovim__list_issues`)
            show_result_in_chat = true,      -- Show tool results directly in chat buffer
            format_tool = nil,               -- function(tool_name:string, tool: CodeCompanion.Agent.Tool) : string Function to format tool names to show in the chat buffer
              -- MCP Resources
              make_vars = true,                -- Convert MCP resources to #variables for prompts
              -- MCP Prompts 
              make_slash_commands = true,      -- Add MCP prompts as /slash commands
            }
          },
          history = {
          enabled = true,
          opts = {
            picker = "fzf-lua",
          }
        },
        vectorcode = {
          opts = {
            tool_group = {
              enabled = true,
              collapse = true,
            },
            tool_opts = {
              query = {
                max_num = { chunk = 10, document = 5 },
              },
            },
          },
        },
      },
      adapters = {
        http = {
          gemini = function()
            return require("codecompanion.adapters").extend("gemini", {
              env = {
                api_key = "GEMINI_API_KEY",
              },
              schema = {
                model = {
                  default = "gemini-2.5-flash",
                },
              },
            })
          end,
          mistral = function()
            return require("codecompanion.adapters").extend("mistral", {
              env = {
                api_key = "MISTRAL_API_KEY",
              },
              schema = {
                model = {
                  default = "codestral-latest",
                },
              },
            })
          end,
          anthropic = function()
            return require("codecompanion.adapters").extend("anthropic", {
              env = {
                api_key = "ANTHROPIC_API_KEY",
              },
            })
          end,
          copilot = function()
            return require("codecompanion.adapters").extend("copilot", {
              schema = {
                model = {
                  default = "claude-haiku-4.5",
                },
              },
            })
          end,
          openai = function()
            return require("codecompanion.adapters").extend("openai", {
              env = {
                api_key = "OPENAI_API_KEY",
              },
            })
          end,
        },
        acp = {
          gemini_cli = function()
            return require("codecompanion.adapters").extend("gemini_cli", {
              defaults = {
                auth_method = "oauth-personal",
              },
            })
          end,
        },
      },
    },
  },	
  {
    "mfussenegger/nvim-dap",
  },
  {
    "echasnovski/mini.diff",
    config = function()
      local diff = require("mini.diff")
      diff.setup({
        -- Disabled by default
        source = diff.gen_source.none(),
      })
    end,
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
  },
  {
    "github/copilot.vim",
    config = function ()
      vim.g.copilot_enabled = false
    end
  }
})
