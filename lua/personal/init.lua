local opts = { noremap=true, silent=true }
vim.opt.relativenumber = true
vim.api.nvim_set_keymap('n', '<C-l>', ':normal zz<CR>', { noremap = true, silent = true })
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
vim.cmd([[highlight hl_yank guibg=yellow ctermbg=yellow]])
vim.api.nvim_exec([[
  augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank({ higroup = "hl_yank", timeout = 100 })
  augroup END
]], false)

-- PLUGGINS
vim.cmd [[
    set packpath+=~/.config/nvim/plugged
]]
local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.config/nvim/plugged')

    Plug 'mbbill/undotree'
    Plug 'williamboman/mason.nvim'
    Plug 'glepnir/lspsaga.nvim'
    Plug 'neovim/nvim-lspconfig'
    Plug 'L3MON4D3/LuaSnip'
    Plug "VonHeikemen/lsp-zero.nvim"
    Plug 'hrsh7th/nvim-cmp'
    Plug 'wfxr/minimap.vim'
    Plug 'hrsh7th/vim-vsnip'
    Plug 'hrsh7th/vim-vsnip-integ'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'saadparwaiz1/cmp_luasnip'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'ThePrimeagen/harpoon'
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'nvim-treesitter/nvim-treesitter'
    Plug 'projekt0n/github-nvim-theme'
    Plug 'https://github.com/vim-scripts/netrw.vim'
    Plug 'vim-airline/vim-airline'  --for top bar and bottom bar 
    Plug 'vim-airline/vim-airline-themes' --themes for airline plugin
    Plug 'mfussenegger/nvim-jdtls' -- java lsp
    Plug 'elixir-editors/vim-elixir' -- elixir lsp

vim.call('plug#end')

-- power line fonts 
vim.cmd('let g:airline_powerline_fonts = 1')

-- tabline 
vim.cmd('let g:airline#extensions#tabline#enabled = 1')
vim.cmd("let g:airline#extensions#ale#enabled = 1")
vim.cmd("let g:airline_powerline_fonts = 1")
vim.cmd("let g:airline_theme='papercolor'")
vim.cmd("let g:airline#extensions#tabline#show_tab_nr = 1")
vim.cmd("let g:airline#extensions#tabline#tab_nr_type = 1")
vim.cmd("let g:airline#extensions#tabline#tabs_label = 't'")

-- github theme 
vim.cmd('colorscheme github_dark_default')

--treesitter
require('nvim-treesitter.configs').setup {
    ensure_installed = { "typescript", "xml", "vim", "vimdoc", "query", "robot", "cpp", "elixir", "javascript", "python", "c", "lua", "rust", "java" },
    ignore_install = {},
    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true,
        --additional_vim_regex_highlighting = false,
        disable = function(_ , buf)
          local max_lines = 1000  -- Adjust this number based on performance
          local line_count = vim.api.nvim_buf_line_count(buf)
          if line_count > max_lines then
            return true
          end
        end,
    },
    indent = {
        enable = true, -- Enable indentation based on Treesitter
    },
}

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

--undo tree 
vim.api.nvim_set_keymap('n', '<leader>ut', ':UndotreeToggle<CR>', { noremap = true, silent = true })
-- Enable persistent undo
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand('~/.config/nvim/undo') -- Change the path as needed

-- navigation
vim.api.nvim_set_keymap('n', '<leader>b', [[<cmd>b#<CR>]], { noremap = true, silent = true })

--minimap 
--vim.defer_fn(function()
--    vim.cmd('Minimap')
--    vim.api.nvim_exec([[
--        augroup MinimapHighlight
--            autocmd!
--            autocmd BufEnter * if vim.bo.filetype == 'minimap' then vim.wo.cursorline = false vim.wo.cursorcolumn = false end
--        augroup END
--    ]], false)
--    vim.cmd('let g:minimap_highlight_search=1')
--end, 100)

--lsp 
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev,{desc='go to prev diagnostic("error,warning") message'})
vim.keymap.set('n', ']d', vim.diagnostic.goto_next,{desc='go to next diagnostic("error,warning") message'})
require('lspconfig.ui.windows').default_options.border = 'single'
-- below 3 lines are for border in normal mode 
vim.cmd("set winhighlight=NormalFloat:Normal,FloatBorder:Normal")
vim.cmd("hi NormalFloat guibg=#000000")
vim.cmd("hi FloatBorder guibg=#000000 guifg=#FFFFFF gui=nocombine")


local lspconfig = require('lspconfig')
local handlers = {
	["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded"}),
	["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded"}),
}
local servers = { "pyright", "clangd", "tsserver"}

local on_attach = function(_ , bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    vim.api.nvim_set_keymap('i', '<c-s>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
end

for _, lsp in pairs(servers)
do
    lspconfig[lsp].setup {
        on_attach = on_attach,
        handlers = handlers,
        flags = {
            debounce_text_changes = 150,
        },
    }
end

-- elixir lsp config 
lspconfig.elixirls.setup{
  cmd = {"/Users/nsindhe/.config/nvim/plugged/elixir-ls/scripts/language_server.sh"},
  on_attach = function(_, bufnr)
    print("LSP attached to buffer", bufnr)
  end,
  settings = {
    elixirLS = {
      dialyzerEnabled = false,
      fetchDeps = false
    }
  }
}

-- lua lsp is defined seperate for global variable 
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
                disable = { 'missing-fields' },
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
              border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
              winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
            },
            documentation = {
              border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
              winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
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

--mason config
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
