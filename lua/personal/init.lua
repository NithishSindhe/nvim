-- run these commands in mac terminal to remap esc and caps lock systemwide 
-- hidutil property --set '{"UserKeyMapping":[
-- {"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029},
-- {"HIDKeyboardModifierMappingSrc":0x700000029,"HIDKeyboardModifierMappingDst":0x700000039}
-- ]}'
-- run these commands in mac terminal to remap esc and caps lock systemwide 
-- hidutil property --set '{"UserKeyMapping":[
-- {"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029},
-- {"HIDKeyboardModifierMappingSrc":0x700000029,"HIDKeyboardModifierMappingDst":0x700000039}
-- ]}'

local opts = { noremap=true, silent=true }

-- Basic settings
vim.o.mouse = "a"  -- Enable mouse support (change to "" if you really want it disabled)
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.nu = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true  -- Re-enabled for better indentation
vim.opt.shiftwidth = 4
vim.opt.listchars = "tab:>-"
vim.opt.shortmess:remove("S")
vim.o.guifont = "JetBrainsMono Nerd Font:h14"

-- Leader key
vim.g.mapleader = " "
vim.g.netrw_sort_options = "i"

-- TypeScript/React specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescriptreact", "typescript" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.expandtab = true
    vim.opt_local.softtabstop = 2
  end,
})

local nnoremap = require("personal.keymap").nnoremap
local vnoremap = require("personal.keymap").vnoremap
local xnoremap = require("personal.keymap").xnoremap
local inoremap = require("personal.keymap").inoremap

-- OPTIMIZED: Only center on larger jumps, not every movement
-- This dramatically improves performance
nnoremap("<C-d>", "<C-d>zz")
nnoremap("<C-u>", "<C-u>zz")
nnoremap("<C-k>", "<C-u>zz")
nnoremap("<C-j>", "<C-d>zz")
vnoremap("<C-k>", "<C-u>zz")
vnoremap("<C-j>", "<C-d>zz")

-- Center on paragraph jumps and search results only
vnoremap("}", "}zz")
nnoremap("}", "}zz")
vnoremap("{", "{zz")
nnoremap("{", "{zz")
nnoremap("n", "nzz")  -- FIXED: Removed duplicate
vnoremap("N", "Nzz")
nnoremap("N", "Nzz")

-- REMOVED: j/k centering - major performance bottleneck
-- If you really need centered navigation, use <C-j>/<C-k> instead

-- Clipboard and paste operations
xnoremap("p", "\"_dP")
nnoremap("y", "\"+y")
vnoremap("y", "\"+y")

-- Utility mappings
nnoremap("<leader>c",[[<cmd>let @/='' | echo<cr>]])
nnoremap("<leader>d",[[<cmd>bd<CR>]])
vim.api.nvim_set_keymap('n', '<leader>fb', [[<cmd>lua require('telescope.builtin').buffers()<CR>]], opts)
vim.api.nvim_set_keymap('n', '<C-l>', ':normal zz<CR>', opts)

-- Highlight the cursor line
vim.api.nvim_exec([[
  hi CursorLine cterm=NONE ctermbg=235 guibg=#3E4452
  hi CursorLineNr cterm=NONE ctermbg=235 guibg=#3E4452
]], false)

-- Highlight yanked lines 
vim.api.nvim_set_hl(0, "YankHighlight", { bg = "Yellow" })
vim.api.nvim_create_augroup("HighlightYank", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  group = "HighlightYank",
  callback = function()
    vim.highlight.on_yank({ higroup = "YankHighlight", timeout = 100 })
  end,
})

-- PLUGINS
vim.cmd [[set packpath+=~/.config/nvim/plugged]]
local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.config/nvim/plugged')
    Plug('lukas-reineke/indent-blankline.nvim', { ['tag'] = 'v3.0.0' })
    Plug 'stevearc/conform.nvim'
    Plug 'danymat/neogen'
    Plug 'glepnir/lspsaga.nvim'
    Plug 'windwp/nvim-ts-autotag'
    Plug 'ray-x/lsp_signature.nvim'
    Plug 'williamboman/mason.nvim'
    Plug 'neovim/nvim-lspconfig'
    Plug 'L3MON4D3/LuaSnip'
    Plug 'VonHeikemen/lsp-zero.nvim'
    Plug 'hrsh7th/nvim-cmp'
    Plug 'hrsh7th/vim-vsnip'
    Plug 'hrsh7th/vim-vsnip-integ'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'saadparwaiz1/cmp_luasnip'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'ThePrimeagen/harpoon'
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'projekt0n/github-nvim-theme'
    Plug 'https://github.com/vim-scripts/netrw.vim'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'nvim-treesitter/nvim-treesitter'
vim.call('plug#end')

-- Airline config
vim.cmd('let g:airline_powerline_fonts = 1')
vim.cmd("let g:airline#extensions#ale#enabled = 1")
vim.cmd("let g:airline_theme='papercolor'")
vim.cmd("let g:airline#extensions#tabline#enabled = 0")

-- Formatter config 
require("conform").setup({
    formatters_by_ft = {
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
    },
})

vim.keymap.set("v", "<leader>fp", function()
  local start_pos = vim.api.nvim_buf_get_mark(0, "<")
  local end_pos = vim.api.nvim_buf_get_mark(0, ">")
  require("conform").format({
    lsp_fallback = true,
    range = {
      start = { start_pos[1], start_pos[2] },
      ["end"] = { end_pos[1], end_pos[2] },
    },
  })
end, { desc = "Format selection with Prettier" })

-- Neogen auto doc typescript 
require('neogen').setup({ enabled = true })
vim.keymap.set("n", "<leader>cd", function()
  require("neogen").generate()
end, { desc = "Generate doc comment", noremap = true, silent = true })

-- Theme
vim.cmd('colorscheme github_dark_default')

-- OPTIMIZED: Treesitter with cached line count check
local treesitter_config = require('nvim-treesitter.configs')
treesitter_config.setup {
  ensure_installed = { "xml", "vim", "html", "vimdoc", "query", "robot", "cpp", "javascript", "python", "c", "lua", "rust", "java"},
  ignore_install = {},
  sync_install = false,
  auto_install = true,
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["ib"] = "@block.inner",
        ["ab"] = "@block.outer",
        ["it"] = "@tag.inner",
        ["at"] = "@tag.outer",
      },
    },
  },
  highlight = {
    enable = true,
    -- OPTIMIZED: Cache large buffer detection
    disable = function(lang, buf)
      local max_lines = 2000  -- Increased threshold
      local ok, stats = pcall(vim.api.nvim_buf_get_var, buf, 'large_buf')
      if ok then return stats end

      local line_count = vim.api.nvim_buf_line_count(buf)
      local is_large = line_count > max_lines
      pcall(vim.api.nvim_buf_set_var, buf, 'large_buf', is_large)
      return is_large
    end,
  },
}

-- LSPSaga config
require('lspsaga').setup({
  lightbulb = { enable = false },
})

-- Auto complete tags 
require('nvim-ts-autotag').setup()

-- Indentation lines
require("ibl").setup {
  indent = {
    char = "│",
    highlight = { "IndentBlanklineChar" },
  },
  scope = {
    enabled = true,
    show_start = true,
    show_end = false,
    highlight = { "IndentBlanklineScope" },
  },
}

vim.api.nvim_set_hl(0, "IndentBlanklineChar", { fg = "#4C6080", nocombine = true })
vim.api.nvim_set_hl(0, "IndentBlanklineScope", { fg = "#EFF2F6", bold = true })

-- Harpoon
vim.api.nvim_set_keymap('n', '<leader>ha', [[<cmd>lua require("harpoon.mark").add_file()<CR>]], opts)
vim.api.nvim_set_keymap('n', '<leader>hs', [[<cmd>lua require("harpoon.ui").toggle_quick_menu()<CR>]], opts)
for i = 1, 9 do
    vim.api.nvim_set_keymap('n', string.format('<leader>%d', i),
        [[<cmd>lua require("harpoon.ui").nav_file(]] .. i .. [[)<CR>]], opts)
end

require("harpoon").setup({
    menu = {
        width = vim.api.nvim_win_get_width(0) - 4,
    }
})

-- Telescope
local actions = require('telescope.actions')
local telescope = require('telescope')
telescope.load_extension('harpoon')
telescope.setup {
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
    },
    defaults = {
        layout_strategy = 'vertical',
        layout_config = {
            vertical = { width = 0.90 }
        },
        file_sorter = require('telescope.sorters').get_fzy_sorter,
        file_ignore_patterns = {"node_modules"},
        generic_sorter = require('telescope.sorters').get_generic_fuzzy_sorter,
        mappings = {
            i = {
                ["<esc>"] = actions.close,
            },
        },
    },
}

vim.api.nvim_set_keymap('n', '<leader>ff', [[<cmd>lua require('telescope.builtin').find_files()<CR>]], opts)
vim.api.nvim_set_keymap('n', '<leader>fg', [[<cmd>lua require('telescope.builtin').live_grep()<CR>]], opts)
vim.api.nvim_set_keymap('n', '<leader>fb', [[<cmd>lua require('telescope.builtin').buffers()<CR>]], opts)
vim.api.nvim_set_keymap('n', '<leader>fh', [[<cmd>Telescope harpoon marks<CR>]], opts)

vim.keymap.set("n", "<leader>go", function()
  require("telescope.builtin").live_grep({ grep_open_files = true })
end, opts)

-- Navigation
vim.api.nvim_set_keymap('n', '<leader>b', [[<cmd>b#<CR>]], opts)

-- LSP Diagnostics
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, {desc='go to prev diagnostic'})
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, {desc='go to next diagnostic'})
require('lspconfig.ui.windows').default_options.border = 'single'

-- LSP Signature (optimized settings)
require'lsp_signature'.setup({
  bind = true,
  floating_window = {
    border = "rounded",
    focusable = false,
  },
  hint_enable = false,
  toggle_key = '<C-s>', -- Only show when needed
  hi_parameter = "LspSignatureActiveParameter",
})

-- LSP Configuration
local lspconfig = require('lspconfig')
local handlers = {
    ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded"}),
}

local servers = { "pyright", "clangd", "ts_ls"}
local node_bin_path = "/Users/nsindhe/.nvm/versions/node/v22.14.0/bin"
vim.env.PATH = node_bin_path .. ":" .. vim.env.PATH

local on_attach = function(client, bufnr)
    -- FIXED: Use modern API
    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Core LSP mappings
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)

    -- Additional mappings
    vim.keymap.set("n", "<leader>T", vim.lsp.buf.type_definition, { buffer = bufnr, noremap = true, silent = true })
    vim.keymap.set("n", "<leader>vi", vim.lsp.buf.hover, { buffer = bufnr, noremap = true, silent = true })
    vim.keymap.set("n", "<leader>vs", vim.lsp.buf.signature_help, { buffer = bufnr, noremap = true, silent = true })
    vim.keymap.set("n", "<leader>vd", function()
      require('telescope.builtin').lsp_definitions()
    end, { buffer = bufnr, noremap = true, silent = true })
    vim.keymap.set("n", "<leader>D", function()
      require('telescope.builtin').lsp_definitions()
    end, { buffer = bufnr, noremap = true, silent = true })
    vim.keymap.set("n", "<leader>vvd", vim.lsp.buf.definition, { buffer = bufnr, noremap = true, silent = true })
    vim.keymap.set("n", "<leader>p", "<cmd>Lspsaga peek_definition<CR>", { buffer = bufnr, silent = true })
end

-- Setup servers
for _, lsp in pairs(servers) do
    local config = {
        on_attach = on_attach,
        handlers = handlers,
        flags = {
          debounce_text_changes = 150,
        },
    }

    if lsp == "ts_ls" then
        config.settings = {
            typescript = {
                tsdk = "/Users/nsindhe/.nvm/versions/node/v22.14.0/lib/node_modules/typescript/lib",
            },
        }
    end
    lspconfig[lsp].setup(config)
end

-- Pyright with extra paths
require'lspconfig'.pyright.setup{
    on_attach = on_attach,
    handlers = handlers,
    settings = {
        python = {
            analysis = {
                extraPaths = {
                    "/volume/regressions/toby/test-suites/MTS/resources",
                    "/homes/nsindhe/automationScripts",
                    "/homes/nsindhe/automationScripts/autoRunCiCd"
                }
            }
        }
    }
}

-- Lua LSP
lspconfig.lua_ls.setup {
    on_attach = on_attach,
    handlers = handlers,
    flags = {
        debounce_text_changes = 150,
    },
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' },
            },
            runtime = {
                version = 'LuaJIT',
                path = vim.split(package.path, ';'),
            },
            workspace = {
                library = {
                    [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                    [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
                },
            },
        },
    },
}

-- Floating window colors
vim.cmd([[
  hi NormalFloat guibg=#3C4A5D guifg=#e6edf3
  hi FloatBorder guibg=#3C4A5D guifg=#494C50
  hi Pmenu guibg=#3C4A5D guifg=#e6edf3
  hi PmenuSel guibg=#5A6A80 guifg=#ffffff
  hi PmenuThumb guibg=#5A6A80
  hi PmenuSbar guibg=#2c333f
]])

-- OPTIMIZED: nvim-cmp setup (increased defer time)
vim.defer_fn(function()
    local cmp = require('cmp')
    cmp.setup({
        sources = {
            { name = 'nvim_lsp' },
            { name = 'buffer', keyword_length = 3 },  -- Added keyword_length for performance
            { name = 'vsnip' },
            { name = 'path' },
        },
        window = {
            completion = {
                winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None"
            },
            documentation = {
                winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None"
            },
        },
        completion = {
            completeopt = 'menu,menuone,noinsert,preview,noselect',
        },
        mapping = {
            ['<Tab>'] = cmp.mapping.select_next_item(),
            ['<S-Tab>'] = cmp.mapping.select_prev_item(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
        },
        performance = {  -- Added performance tuning
            debounce = 60,
            throttle = 30,
            fetching_timeout = 500,
        },
    })
end, 500)  -- Increased from 100ms to 500ms

-- Mason setup
require("mason").setup({
    ui = {
        border = "shadow",
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})

-- Undo tree
vim.api.nvim_set_keymap('n', '<leader>ut', ':UndotreeToggle<CR>', opts)

-- Persistent undo
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand('~/.config/nvim/undo')
