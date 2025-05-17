local opts = { noremap=true, silent=true }
vim.opt.relativenumber = true
vim.api.nvim_set_keymap('n', '<C-l>', ':normal zz<CR>', { noremap = true, silent = true })
vim.o.guifont = "JetBrainsMono Nerd Font:h14"
vim.opt.cursorline = true
vim.opt.nu = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab=true
vim.opt.smartindent = false
vim.opt.shiftwidth = 4
vim.g.mapleader = " "
vim.g.netrw_sort_options = "i"
vim.opt.listchars ="tab:>-"
vim.opt.shortmess:remove("S")
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

local filepath = vim.fn.stdpath('config') .. '/lua/personal/servers.lua'
dofile(filepath)

-- keep page centered all the time 
nnoremap("<C-d>", "<C-d>zz")
nnoremap("<C-u>", "<C-u>zz")
nnoremap("<C-k>", "<C-u>zz")
nnoremap("<C-j>", "<C-d>zz")
vnoremap("<C-k>", "<C-u>zz")
vnoremap("<C-j>", "<C-d>zz")
--vnoremap("dj", "djzz")
--nnoremap("dk", "dkzz")
vnoremap("}", "}zz")
nnoremap("}", "}zz")
vnoremap("{", "{zz")
nnoremap("{", "{zz")
nnoremap("n", "nzz")
nnoremap("n", "nzz")
vnoremap("N", "Nzz")
nnoremap("N", "Nzz")
vnoremap("k", "kzz")
nnoremap("k", "kzz")
nnoremap("j", "jzz")
vnoremap("j", "jzz")
xnoremap("p", "\"_dP")
nnoremap("y", "\"+y")
vnoremap("y", "\"+y")
nnoremap("<leader>c",[[<cmd>let @/='' | echo<cr>]])
nnoremap("<leader>d",[[<cmd>bd<CR>]])
vim.api.nvim_set_keymap('n', '<leader>fb', [[<cmd>lua require('telescope.builtin').buffers()<CR>]], { noremap = true, silent = true })

-- Highlight the cursor line
vim.api.nvim_exec([[
  hi CursorLine cterm=NONE ctermbg=235 guibg=#3E4452
  hi CursorLineNr cterm=NONE ctermbg=235 guibg=#3E4452
]], false)

--Highlight yanked lines 
-- Define the highlight group
vim.api.nvim_set_hl(0, "YankHighlight", { bg = "Yellow" })
-- Set up autocmd with new Lua API
vim.api.nvim_create_augroup("HighlightYank", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  group = "HighlightYank",
  callback = function()
    vim.highlight.on_yank({ higroup = "YankHighlight", timeout = 100 })
  end,
})


-- PLUGGINS
vim.cmd [[
    set packpath+=~/.config/nvim/plugged
]]
local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.config/nvim/plugged')

    Plug('lukas-reineke/indent-blankline.nvim', { ['tag'] = 'v3.0.0' })
    Plug 'glepnir/lspsaga.nvim'
    Plug 'windwp/nvim-ts-autotag'
    Plug 'ray-x/lsp_signature.nvim' -- display function arg info while in insert mode
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
    Plug 'vim-airline/vim-airline'  --for top bar and bottom bar 
    Plug 'vim-airline/vim-airline-themes' --themes for airline plugin
    --Plug 'mfussenegger/nvim-jdtls' -- java lsp
    Plug 'nvim-treesitter/nvim-treesitter'

vim.call('plug#end')

-- power line fonts 
vim.cmd('let g:airline_powerline_fonts = 1')

-- tabline 
vim.cmd("let g:airline#extensions#ale#enabled = 1")
vim.cmd("let g:airline_powerline_fonts = 1")
vim.cmd("let g:airline_theme='papercolor'")
-- disable top bar, disable tabline
vim.cmd("let g:airline#extensions#tabline#enabled = 0")


-- github theme 
vim.cmd('colorscheme github_dark_default')

--treesitter
local treesitter_config = require('nvim-treesitter.configs')
treesitter_config.setup {
  ensure_installed = { "xml", "vim", "html", "vimdoc", "query", "robot", "cpp", "javascript", "python", "c", "lua", "rust", "java"},
  ignore_install = {},
  sync_install = false,
  auto_install = true,
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump to next match
      keymaps = {
        ["ib"] = "@block.inner",   -- Select inside a tag's content
        ["ab"] = "@block.outer",   -- Select the entire tag block
        ["it"] = "@tag.inner",     -- Select inside tag name
        ["at"] = "@tag.outer",     -- Select the full tag
      },
    },
  },
  highlight = {
    enable = true,
    disable = function(_, buf)
      local max_lines = 1000  -- Adjust this number based on performance
      local line_count = vim.api.nvim_buf_line_count(buf)
      if line_count > max_lines then
        return true
      end
    end,
  },
}

--lspsaga 
require('lspsaga').setup({})

--auto complete tags 
require('nvim-ts-autotag').setup()

-- indentation lines
require("ibl").setup {
  indent = {
    char = "▏", -- Thin vertical line
    highlight = { "IndentBlanklineChar" }, -- Force default color
  },
  scope = {
    enabled = true, -- Highlights the current indentation scope
    show_start = true,
    show_end = false,
    highlight = { "IndentBlanklineScope" },
  },
}
-- colors for indent blocks
vim.api.nvim_set_hl(0, "IndentBlanklineChar", { fg = "#4C6080", nocombine = true }) -- default color 
vim.api.nvim_set_hl(0, "IndentBlanklineScope", { fg = "#EFF2F6", bold = true }) -- block highlight color 

-- harpoon
vim.api.nvim_set_keymap('n', '<leader>ha', [[<cmd>lua require("harpoon.mark").add_file()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>hs', [[<cmd>lua require("harpoon.ui").toggle_quick_menu()<CR>]], { noremap = true, silent = true })
for i = 1, 9 do
    vim.api.nvim_set_keymap('n', string.format('<leader>%d', i), [[<cmd>lua require("harpoon.ui").nav_file(]] .. i .. [[)<CR>]], { noremap = true, silent = true })
end

require("harpoon").setup({
    menu = {
        width = vim.api.nvim_win_get_width(0) - 4,
    }
})

-- telescope
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
            vertical = { width = 0.90  }
        },
        file_sorter = require('telescope.sorters').get_fzy_sorter,
        file_ignore_patterns = {"node_modules"},
        generic_sorter =  require('telescope.sorters').get_generic_fuzzy_sorter,
        mappings = {
            i = {
                ["<esc>"] = actions.close,
            },
        },
    },
}

vim.api.nvim_set_keymap('n', '<leader>ff', [[<cmd>lua require('telescope.builtin').find_files()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fg', [[<cmd>lua require('telescope.builtin').live_grep()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fb', [[<cmd>lua require('telescope.builtin').buffers()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fh', [[<cmd>Telescope harpoon marks<CR>]], { noremap = true, silent = true })
-- Add live grep in open buffers
vim.keymap.set("n", "<leader>go", function()
  require("telescope.builtin").live_grep({ grep_open_files = true })
end, { noremap = true, silent = true })


-- navigation
vim.api.nvim_set_keymap('n', '<leader>b', [[<cmd>b#<CR>]], { noremap = true, silent = true })



--lsp 
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev,{desc='go to prev diagnostic("error,warning") message'})
vim.keymap.set('n', ']d', vim.diagnostic.goto_next,{desc='go to next diagnostic("error,warning") message'})
require('lspconfig.ui.windows').default_options.border = 'single'

--show function information when typing a function
require'lsp_signature'.setup({
  bind = true,
  floating_window = {
    border = "rounded", -- Or any other border style you prefer
    focusable = false, -- Prevent the floating window from gaining focus
  },
  hint_enable = false,
})

local lspconfig = require('lspconfig')
local handlers = {
	--["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded"}),
	["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded"}),
}
--local servers = { "lua_ls", "pyright", "clangd", "tsserver"}
local servers = { "pyright", "clangd", "ts_ls"}
local node_bin_path = "/Users/nsindhe/.nvm/versions/node/v22.14.0/bin"
vim.env.PATH = node_bin_path .. ":" .. vim.env.PATH

local on_attach = function(_, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    vim.api.nvim_set_keymap('i', '<c-s>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    -- chat gpt
    vim.keymap.set("n", "<leader>T", vim.lsp.buf.type_definition, { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>vi", function()
      vim.lsp.buf.hover()
    end, { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>vs", vim.lsp.buf.signature_help, { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>vd", function()
      require('telescope.builtin').lsp_definitions()
    end, { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>D", function()
      require('telescope.builtin').lsp_definitions()
    end, { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>vvd", vim.lsp.buf.definition, { noremap = true, silent = true })
    --vim.keymap.set("n", "<leader>p", "<cmd>Lspsaga peek_definition<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>p", "<cmd>Lspsaga peek_definition<CR>", { silent = true })

end

for _, lsp in pairs(servers)
do
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

-- to avoid init_mts is not found error for import 
require'lspconfig'.pyright.setup{
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

-- lua lsp is defined seperate because of "vim" global variable 
lspconfig.lua_ls.setup {
    on_attach = on_attach,
    handlers = handlers,
    flags = {
            debounce_text_changes = 150,
    },
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' },  -- List of global variables to consider as defined
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

-- set colors for floating windows
vim.cmd([[
  hi NormalFloat guibg=#3C4A5D guifg=#e6edf3
  hi FloatBorder guibg=#3C4A5D guifg=#494C50
  hi Pmenu guibg=#3C4A5D guifg=#e6edf3
  hi PmenuSel guibg=#5A6A80 guifg=#ffffff
  hi PmenuThumb guibg=#5A6A80
  hi PmenuSbar guibg=#2c333f
]])

--nvim-cmp
vim.defer_fn(function()
    local cmp = require('cmp')
    cmp.setup({
        sources = {
            { name = 'buffer' },
            { name = 'nvim_lsp' },
            { name = 'vsnip' },
            { name = 'path' },
        },
        -- window variable is for border on floating window in insert mode 
        window = {
            completion = {
                --border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
                --winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
                winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None"
            },
            documentation = {
                --border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
                --winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
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
    })
end, 100)

require("mason").setup({
    ui = {
        -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
        border = "shadow",
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})

--undo tree
vim.api.nvim_set_keymap('n', '<leader>ut', ':UndotreeToggle<CR>', { noremap = true, silent = true })

-- Enable persistent undo
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand('~/.config/nvim/undo') -- Change the path as needed
