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
vim.o.winborder = "rounded"

-- Leader key (must be set before lazy.nvim)
vim.g.mapleader = " "
vim.g.netrw_sort_options = "i"

-- Copilot inline suggestions (conflict-safe with nvim-cmp <Tab>)
-- These vim.g vars must be set before copilot loads
vim.g.copilot_no_tab_map = true
vim.g.copilot_filetypes = {
  ["copilot-chat"] = false,
  ["TelescopePrompt"] = false,
}
vim.keymap.set("i", "<C-j>", 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false,
  silent = true,
  desc = "Copilot accept suggestion",
})
vim.keymap.set("i", "<C-l>", "<Plug>(copilot-accept-word)", { silent = true, desc = "Copilot accept word" })
vim.keymap.set("i", "<C-]>", "<Plug>(copilot-dismiss)", { silent = true, desc = "Copilot dismiss suggestion" })
vim.keymap.set("i", "<C-e>", "<End>", { silent = true, desc = "Move cursor to end of line" })
vim.keymap.set("i", "<C-a>", "<Home>", { silent = true, desc = "Move cursor to start of line" })

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

-- JavaScript specific settings (4-space indentation)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "javascriptreact" },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.expandtab = true
    vim.opt_local.softtabstop = 4
  end,
})

-- Ruby specific settings (2-space indentation convention)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "ruby", "eruby" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.expandtab = true
    vim.opt_local.softtabstop = 2
  end,
})

-- YAML settings (Rails config files use 2-space indentation)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "yaml" },
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
nnoremap("n", "nzz")
vnoremap("N", "Nzz")
nnoremap("N", "Nzz")

-- Clipboard and paste operations
xnoremap("p", "\"_dP")
nnoremap("y", "\"+y")
vnoremap("y", "\"+y")

-- ============================================================================
-- Per-buffer floating scratch window
-- ============================================================================
-- State table: source_buf -> { scratch_buf, float_win, start_line, end_line }
local _float_scratch = {}

local function float_scratch_cleanup(source_buf)
  local state = _float_scratch[source_buf]
  if not state then return end
  if state.scratch_buf and vim.api.nvim_buf_is_valid(state.scratch_buf) then
    vim.api.nvim_buf_delete(state.scratch_buf, { force = true })
  end
  _float_scratch[source_buf] = nil
end

local function float_scratch_close_win(source_buf)
  local state = _float_scratch[source_buf]
  if not state then return end
  if state.float_win and vim.api.nvim_win_is_valid(state.float_win) then
    vim.api.nvim_win_close(state.float_win, false) -- false = respect modified warning
  end
  state.float_win = nil
end

local function float_scratch_open_win(source_buf)
  local state = _float_scratch[source_buf]
  if not state or not state.scratch_buf or not vim.api.nvim_buf_is_valid(state.scratch_buf) then
    return
  end
  -- Consistent padding: 2 on each side, stick to top, leave space at bottom for statusline
  local pad = 2
  local width = vim.o.columns - (pad * 2)
  local height = vim.o.lines - pad - 5  -- leave ~5 rows at bottom for filename/statusline
  if width < 10 then width = 10 end
  if height < 5 then height = 5 end

  local win = vim.api.nvim_open_win(state.scratch_buf, true, {
    relative = "editor",
    row = pad,
    col = pad,
    width = width,
    height = height,
    border = "rounded",
    zindex = 10,
  })
  state.float_win = win

  -- Show original line numbers via statuscolumn
  local offset = state.start_line - 1
  vim.wo[win].number = true
  vim.wo[win].relativenumber = false
  vim.wo[win].statuscolumn = '%=' .. (offset > 0
    and ('%{v:lnum + ' .. offset .. '}')
    or '%l') .. ' '
  vim.wo[win].signcolumn = "no"
  vim.wo[win].cursorline = true
end

vim.keymap.set("v", "<leader>sw", function()
  -- Exit visual mode to update '< and '> marks
  vim.cmd('noautocmd normal! \27')
  local source_buf = vim.api.nvim_get_current_buf()
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")

  -- Get selected lines directly from buffer (no register gymnastics)
  local lines = vim.api.nvim_buf_get_lines(source_buf, start_line - 1, end_line, false)
  if #lines == 0 then return end

  -- Clean up any existing float for this buffer
  float_scratch_cleanup(source_buf)

  local ft = vim.bo[source_buf].filetype

  -- Create scratch buffer
  local scratch_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(scratch_buf, 0, -1, false, lines)
  vim.bo[scratch_buf].filetype = ft
  vim.bo[scratch_buf].buftype = "acwrite" -- enables BufWriteCmd
  vim.bo[scratch_buf].bufhidden = "hide"
  vim.bo[scratch_buf].modified = false

  -- Store state
  _float_scratch[source_buf] = {
    scratch_buf = scratch_buf,
    float_win = nil,
    start_line = start_line,
    end_line = end_line,
  }

  -- Open the floating window
  float_scratch_open_win(source_buf)

  -- Write-back: :w in scratch writes to the source buffer's original selection
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = scratch_buf,
    callback = function()
      local st = _float_scratch[source_buf]
      if not st or not vim.api.nvim_buf_is_valid(source_buf) then
        vim.notify("Source buffer no longer exists", vim.log.levels.ERROR)
        return
      end
      local new_lines = vim.api.nvim_buf_get_lines(scratch_buf, 0, -1, false)
      vim.api.nvim_buf_set_lines(source_buf, st.start_line - 1, st.end_line, false, new_lines)
      -- Update end_line in case line count changed
      st.end_line = st.start_line + #new_lines - 1
      vim.bo[scratch_buf].modified = false
      -- Also write the source file to disk
      vim.api.nvim_buf_call(source_buf, function()
        vim.cmd("write")
      end)
      vim.notify("Written back to source (lines " .. st.start_line .. "-" .. st.end_line .. ")")
    end,
  })

  -- :q to close — works naturally; buftype=acwrite warns on unsaved changes
  -- Override QuitPre so :q cleans up state properly
  vim.api.nvim_create_autocmd("QuitPre", {
    buffer = scratch_buf,
    callback = function()
      vim.schedule(function()
        float_scratch_cleanup(source_buf)
      end)
    end,
  })

  -- Cleanup when source buffer is wiped
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = source_buf,
    once = true,
    callback = function()
      float_scratch_cleanup(source_buf)
    end,
  })
end, { desc = "Show selection in floating scratch window" })

-- Utility mappings
nnoremap("<leader>c", "<cmd>nohlsearch<CR>")
nnoremap("<leader>d",[[<cmd>bd<CR>]])
vim.api.nvim_set_keymap('n', '<C-l>', ':normal zz<CR>', opts)

-- Custom highlights applied via ColorScheme autocmd so they persist after theme loads
local function apply_custom_highlights()
  -- Cursor line
  vim.api.nvim_set_hl(0, "CursorLine", { ctermbg = 235, bg = "#3E4452" })
  vim.api.nvim_set_hl(0, "CursorLineNr", { ctermbg = 235, bg = "#3E4452" })

  -- Yanked lines
  vim.api.nvim_set_hl(0, "YankHighlight", { bg = "Yellow" })

  -- Floating window colors
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#3C4A5D", fg = "#e6edf3" })
  vim.api.nvim_set_hl(0, "FloatBorder", { bg = "#3C4A5D", fg = "#7a8a9e" })
  vim.api.nvim_set_hl(0, "Pmenu", { bg = "#3C4A5D", fg = "#e6edf3" })
  vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#5A6A80", fg = "#ffffff" })
  vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "#5A6A80" })
  vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "#2c333f" })
end

-- Sync tmux status bar colors with Neovim's colorscheme
local function sync_tmux_statusbar()
  if vim.env.TMUX == nil then return end
  vim.schedule(function()
    local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
    if not normal_hl.bg then return end

    local bg = string.format("#%06x", normal_hl.bg)
    local fg = normal_hl.fg and string.format("#%06x", normal_hl.fg) or "white"

    -- Read muted fg from Comment highlight for inactive window tabs
    local comment_hl = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
    local muted = comment_hl.fg and string.format("#%06x", comment_hl.fg) or "gray"

    -- Read accent color from Function highlight for active elements
    local func_hl = vim.api.nvim_get_hl(0, { name = "Function", link = false })
    local accent = func_hl.fg and string.format("#%06x", func_hl.fg) or "green"

    vim.fn.system('tmux set-option -g status-style "bg=' .. bg .. ',fg=' .. fg .. '"')
    vim.fn.system('tmux set-option -g message-style "bg=' .. bg .. ',fg=' .. accent .. ',bold"')
    vim.fn.system('tmux set-option -g status-left "#[fg=' .. accent .. ',bold] #S "')
    vim.fn.system('tmux setw -g window-status-style "fg=' .. muted .. '"')
    vim.fn.system('tmux setw -g window-status-current-style "fg=' .. accent .. ',bold"')
    vim.fn.system('tmux set-option -g pane-active-border-style "fg=' .. accent .. '"')
  end)
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    apply_custom_highlights()
    sync_tmux_statusbar()
  end,
})
-- Apply highlights immediately for the initial load (sync deferred to ColorScheme autocmd)
apply_custom_highlights()

-- Reset tmux status bar to default when leaving Neovim or switching panes
local function reset_tmux_statusbar()
  if vim.env.TMUX == nil then return end
  vim.fn.system('tmux set-option -g status-style "bg=default,fg=white"')
  vim.fn.system('tmux set-option -g message-style "bg=default,fg=green,bold"')
  vim.fn.system('tmux set-option -g status-left "#[fg=green,bold] #S "')
  vim.fn.system('tmux setw -g window-status-style "fg=gray"')
  vim.fn.system('tmux setw -g window-status-current-style "fg=green,bold"')
  vim.fn.system('tmux set-option -g pane-active-border-style "fg=green"')
end

vim.api.nvim_create_autocmd("VimLeave", { callback = reset_tmux_statusbar })
vim.api.nvim_create_autocmd("FocusLost", { callback = reset_tmux_statusbar })
vim.api.nvim_create_autocmd("FocusGained", { callback = sync_tmux_statusbar })

-- Highlight yanked lines
vim.api.nvim_create_augroup("HighlightYank", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  group = "HighlightYank",
  callback = function()
    vim.highlight.on_yank({ higroup = "YankHighlight", timeout = 100 })
  end,
})

-- Navigation
vim.api.nvim_set_keymap('n', '<leader>b', [[<cmd>b#<CR>]], opts)

-- LSP Diagnostics
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, {desc='go to prev diagnostic'})
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, {desc='go to next diagnostic'})

-- Undo tree
vim.api.nvim_set_keymap('n', '<leader>ut', ':UndotreeToggle<CR>', opts)

-- Persistent undo
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand('~/.config/nvim/undo')

-- Phase 5: Treesitter large_buf cache invalidation autocmd
-- Invalidates the cached large_buf flag when buffer content changes significantly
vim.api.nvim_create_autocmd({ "BufWritePost", "TextChanged" }, {
  callback = function(args)
    local buf = args.buf
    local max_lines = 2000
    local max_bytes = 1024 * 1024 -- 1MB
    local ok, cached = pcall(vim.api.nvim_buf_get_var, buf, 'large_buf')
    if not ok then return end -- no cache yet, nothing to invalidate
    local line_count = vim.api.nvim_buf_line_count(buf)
    local byte_size = vim.api.nvim_buf_get_offset(buf, line_count)
    local is_large = line_count > max_lines or byte_size > max_bytes
    if is_large ~= cached then
      vim.api.nvim_buf_set_var(buf, 'large_buf', is_large)
    end
  end,
})

-------------------------------------------------------------------------------
-- PLUGINS (Phase 2: lazy.nvim with lazy-loading)
-------------------------------------------------------------------------------

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- LSP keymaps via LspAttach autocmd (replaces on_attach for Nvim 0.11+)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local bufnr = args.buf

    -- Prevent duplicate hover/diagnostic/completion popups from multiple ruby_lsp
    -- clients attaching to the same buffer.
    if client and client.name == "ruby_lsp" then
      -- ruby_lsp wins: stop any solargraph clients on this buffer
      local solargraph_clients = vim.lsp.get_clients({ bufnr = bufnr, name = "solargraph" })
      for _, c in ipairs(solargraph_clients) do
        c:stop()
      end

      local ruby_clients = vim.lsp.get_clients({ bufnr = bufnr, name = "ruby_lsp" })
      if #ruby_clients > 1 then
        table.sort(ruby_clients, function(a, b) return a.id < b.id end)
        local primary_id = ruby_clients[1].id
        for _, c in ipairs(ruby_clients) do
          if c.id ~= primary_id then
            c:stop()
          end
        end
        if client.id ~= primary_id then
          return
        end
      end
    end

    -- If solargraph attaches but ruby_lsp is already active, stop solargraph
    if client and client.name == "solargraph" then
      local ruby_lsp_clients = vim.lsp.get_clients({ bufnr = bufnr, name = "ruby_lsp" })
      if #ruby_lsp_clients > 0 then
        client:stop()
        return
      end
    end

    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, noremap = true, silent = true, desc = "LSP go to definition" })
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, noremap = true, silent = true })
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
  end,
})

-- Node path for LSP servers
local node_bin_path = "/Users/nsindhe/.nvm/versions/node/v22.14.0/bin"
vim.env.PATH = node_bin_path .. ":" .. vim.env.PATH

-- rvm Ruby path: inherit PATH from shell (rvm sets it via .zshrc/.bashrc),
-- ensure ~/.rvm/bin is available as a fallback for rvm-auto-ruby etc.
local home = os.getenv("HOME") or "/Users/nsindhe"
vim.env.PATH = home .. "/.rvm/bin:" .. vim.env.PATH

-- LSP server configurations (Nvim 0.11+ vim.lsp.config API)
vim.lsp.config('clangd', {})

vim.lsp.config('vtsls', {})

vim.lsp.config('pyright', {
  settings = {
    python = {
      analysis = {
        extraPaths = {
          "/volume/regressions/toby/test-suites/MTS/resources",
          "/homes/nsindhe/automationScripts",
          "/homes/nsindhe/automationScripts/autoRunCiCd",
        },
      },
    },
  },
})

vim.lsp.config('ruby_lsp', {
  -- Use launcher to handle projects with missing/incompatible gems more gracefully
  cmd = { 'ruby-lsp', '--use-launcher' },
  init_options = {
    formatter = 'auto',
    linters = { 'rubocop' },
  },
})

vim.lsp.config('solargraph', {
  cmd = { 'solargraph', 'stdio' },
  settings = {
    solargraph = {
      diagnostics = true,
      completion = true,
      hover = true,
      formatting = true,
      references = true,
      rename = true,
      symbols = true,
    },
  },
})

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      diagnostics = { globals = { 'vim' } },
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
})

-- Enable all configured servers
vim.lsp.enable({ 'clangd', 'vtsls', 'pyright', 'lua_ls', 'ruby_lsp', 'solargraph' })

require("lazy").setup({

  -- Theme (load immediately, needed before first paint)
  {
    "projekt0n/github-nvim-theme",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("github_dark_default")
    end,
  },

  -- Treesitter (load on first buffer read for syntax highlighting)
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
      -- Modern nvim-treesitter setup (configs module was removed)
      require('nvim-treesitter').setup({
        ensure_install = {"ruby", "embedded_template", "xml", "vim", "html", "vimdoc", "query", "robot", "cpp", "javascript", "python", "c", "lua", "rust", "java", "markdown", "markdown_inline" },
        auto_install = true,
      })

      -- Treesitter highlight is now enabled by default in Neovim.
      -- Disable for large buffers with byte-size check and invalidation support.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local buf = args.buf
          local max_lines = 2000
          local max_bytes = 1024 * 1024 -- 1MB
          local line_count = vim.api.nvim_buf_line_count(buf)
          local byte_size = vim.api.nvim_buf_get_offset(buf, line_count)
          local is_large = line_count > max_lines or byte_size > max_bytes
          pcall(vim.api.nvim_buf_set_var, buf, 'large_buf', is_large)
          if is_large then
            vim.treesitter.stop(buf)
          end
        end,
      })
    end,
  },

  -- nvim-lspconfig (provides server config definitions used by vim.lsp.config)
  {
    "neovim/nvim-lspconfig",
    lazy = false,
  },

  -- Plenary (dependency, loaded by dependents)
  { "nvim-lua/plenary.nvim", lazy = true },

  -- Phase 3: lualine replaces vim-airline (Lua-native, no VimScript bridge on every CursorMoved)
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          icons_enabled = true,
          section_separators = { left = '', right = '' },
          component_separators = { left = '', right = '' },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff" },
          lualine_c = { "filename" },
          lualine_x = {
            {
              function()
                local ok, chat = pcall(require, "CopilotChat")
                if ok then return "󰚩 " .. (chat.config.model or "unknown") end
                return ""
              end,
              cond = function()
                return pcall(require, "CopilotChat")
              end,
            },
            "diagnostics", "encoding", "filetype",
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- nvim-cmp (Phase 2: load on InsertEnter instead of vim.defer_fn 500ms timer)
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/vim-vsnip",
      "hrsh7th/vim-vsnip-integ",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        sources = {
          { name = 'nvim_lsp' },
          { name = 'buffer', keyword_length = 4 },  -- Phase 4: increased from 3 to 4
          { name = 'vsnip' },
          { name = 'path' },
        },
        window = {
          completion = {
            border = "rounded",
            winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
          },
          documentation = {
            border = "rounded",
            winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
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
        performance = {  -- Phase 4: increased debounce/throttle to reduce keystroke handler load
          debounce = 100,
          throttle = 50,
          fetching_timeout = 500,
        },
      })
    end,
  },

  -- Conform (lazy-load on keypress only)
  {
    "stevearc/conform.nvim",
    keys = {
      {
        "<leader>fp",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "n",
        desc = "Format file with Prettier",
      },
      {
        "<leader>fp",
        function()
          local start_pos = vim.api.nvim_buf_get_mark(0, "<")
          local end_pos = vim.api.nvim_buf_get_mark(0, ">")
          require("conform").format({
            lsp_fallback = true,
            range = {
              start = { start_pos[1], start_pos[2] },
              ["end"] = { end_pos[1], end_pos[2] },
            },
          })
        end,
        mode = "v",
        desc = "Format selection with Prettier",
      },
    },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          typescript = { "prettier" },
          typescriptreact = { "prettier" },
          javascript = { "prettier" },
          javascriptreact = { "prettier" },
          json = { "prettier" },
          css = { "prettier" },
          scss = { "prettier" },
          html = { "prettier" },
          yaml = { "prettier" },
          markdown = { "prettier" },
          graphql = { "prettier" },
          ruby = { "rubocop" },
          eruby = { "erb_format" },
        },
        formatters = {
          prettier = {
            prepend_args = { "--single-quote", "--trailing-comma", "all", "--tab-width", "4" },
          },
        },
      })
    end,
  },

  -- CopilotChat (lazy-load on command)
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    cmd = {
      "CopilotChat", "CopilotChatToggle", "CopilotChatOpen", "CopilotChatClose",
      "CopilotChatReset", "CopilotChatPrompts", "CopilotChatModels", "CopilotChatStop",
      "CopilotChatExplain", "CopilotChatFix", "CopilotChatTests", "CopilotChatOptimize",
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("CopilotChat").setup({
        model = "gpt-4.1",
        temperature = 0.1,
        auto_insert_mode = true,
        window = {
          layout = "vertical",
          width = 0.45,
        },
      })
    end,
    keys = {
      { "<leader>aa", "<cmd>CopilotChatToggle<CR>", mode = "n", desc = "Toggle Copilot Chat" },
      { "<leader>aa", "<cmd>CopilotChat<CR>", mode = "v", desc = "Copilot Chat selection" },
      { "<leader>ao", "<cmd>CopilotChatOpen<CR>", desc = "Open Copilot Chat" },
      { "<leader>ax", "<cmd>CopilotChatClose<CR>", desc = "Close Copilot Chat" },
      { "<leader>ar", "<cmd>CopilotChatReset<CR>", desc = "Reset Copilot Chat" },
      { "<leader>ap", "<cmd>CopilotChatPrompts<CR>", desc = "Copilot Chat prompts" },
      { "<leader>am", "<cmd>CopilotChatModels<CR>", desc = "Copilot Chat models" },
      { "<leader>a.", "<cmd>CopilotChatStop<CR>", desc = "Stop Copilot Chat response" },
      { "<leader>ae", "<cmd>CopilotChatExplain<CR>", mode = "v", desc = "Explain selection" },
      { "<leader>af", "<cmd>CopilotChatFix<CR>", mode = "v", desc = "Fix selection" },
      { "<leader>at", "<cmd>CopilotChatTests<CR>", mode = "v", desc = "Generate tests from selection" },
      { "<leader>au", "<cmd>CopilotChatOptimize<CR>", mode = "v", desc = "Optimize selection" },
      { "<leader>ai", "<cmd>Copilot enable<CR>", desc = "Enable Copilot inline" },
      { "<leader>aI", "<cmd>Copilot disable<CR>", desc = "Disable Copilot inline" },
      { "<leader>as", "<cmd>Copilot status<CR>", desc = "Copilot status" },
      { "<leader>aA", "<cmd>Copilot setup<CR>", desc = "Copilot setup/login" },
      { "<leader>aP", "<cmd>Copilot panel<CR>", desc = "Copilot panel" },
      { "<leader>aM", "<cmd>Copilot model<CR>", desc = "Copilot model picker" },
    },
  },

  -- render-markdown (pretty markdown rendering in CopilotChat)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "copilot-chat" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      file_types = { "copilot-chat" },
    },
  },

  -- Neogen (lazy-load on keypress)
  {
    "danymat/neogen",
    keys = {
      { "<leader>gc", function() require("neogen").generate() end, desc = "Generate doc comment" },
    },
    config = function()
      require('neogen').setup({ enabled = true })
    end,
  },

  -- LSPSaga (lazy-load on command)
  {
    "glepnir/lspsaga.nvim",
    cmd = "Lspsaga",
    config = function()
      require('lspsaga').setup({
        lightbulb = { enable = false },
      })
    end,
  },

  -- nvim-ts-autotag (lazy-load on InsertEnter for web filetypes)
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    ft = { "html", "typescriptreact", "javascriptreact", "xml" },
    config = function()
      require('nvim-ts-autotag').setup()
    end,
  },

  -- LSP Signature (Phase 4: lazy-load on LspAttach, floating window disabled by default)
  {
    "ray-x/lsp_signature.nvim",
    event = "LspAttach",
    config = function()
      require('lsp_signature').setup({
        bind = true,
        floating_window = false,  -- Phase 4: disabled to reduce CursorMovedI handler load
        hint_enable = false,
        toggle_key = '<C-s>',     -- press <C-s> to show signature when needed
        hi_parameter = "LspSignatureActiveParameter",
      })
    end,
  },

  -- Mason (lazy-load on command only)
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    config = function()
      require("mason").setup({
        ui = {
          border = "shadow",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })
    end,
  },

  -- Indent Blankline (lazy-load on first buffer read)
  {
    "lukas-reineke/indent-blankline.nvim",
    tag = "v3.0.0",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "IblIndent", { fg = "#4C6080", nocombine = true })
        vim.api.nvim_set_hl(0, "IblScope", { fg = "#EFF2F6", bold = true })
      end)
      require("ibl").setup({
        indent = {
          char = "│",
          highlight = "IblIndent",
        },
        scope = {
          enabled = false,      -- Phase 4: disabled to reduce CursorMoved handler load
          show_start = false,   -- (treesitter queries on every cursor move are expensive)
          show_end = false,
          highlight = "IblScope",
        },
      })
    end,
  },

  -- Harpoon (lazy-load on keypress)
  {
    "ThePrimeagen/harpoon",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ha", function() require("harpoon.mark").add_file() end, desc = "Harpoon add file" },
      -- Phase 5: dynamic width computed at toggle time, not startup
      { "<leader>hs", function()
          require("harpoon").setup({
            menu = { width = vim.api.nvim_win_get_width(0) - 4 },
          })
          require("harpoon.ui").toggle_quick_menu()
        end, desc = "Harpoon toggle menu" },
      { "<leader>1", function() require("harpoon.ui").nav_file(1) end, desc = "Harpoon file 1" },
      { "<leader>2", function() require("harpoon.ui").nav_file(2) end, desc = "Harpoon file 2" },
      { "<leader>3", function() require("harpoon.ui").nav_file(3) end, desc = "Harpoon file 3" },
      { "<leader>4", function() require("harpoon.ui").nav_file(4) end, desc = "Harpoon file 4" },
      { "<leader>5", function() require("harpoon.ui").nav_file(5) end, desc = "Harpoon file 5" },
      { "<leader>6", function() require("harpoon.ui").nav_file(6) end, desc = "Harpoon file 6" },
      { "<leader>7", function() require("harpoon.ui").nav_file(7) end, desc = "Harpoon file 7" },
      { "<leader>8", function() require("harpoon.ui").nav_file(8) end, desc = "Harpoon file 8" },
      { "<leader>9", function() require("harpoon.ui").nav_file(9) end, desc = "Harpoon file 9" },
    },
    config = function()
      require("harpoon").setup({})
    end,
  },

  -- Telescope (lazy-load on keypress/command)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "ThePrimeagen/harpoon" },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", function() require('telescope.builtin').find_files() end, desc = "Find files" },
      { "<leader>fg", function()
        require('telescope.builtin').live_grep({
          default_text = vim.g._telescope_last_grep or "",
          on_complete = {
            function(picker)
              local prompt_bufnr = picker.prompt_bufnr
              vim.api.nvim_create_autocmd("BufLeave", {
                buffer = prompt_bufnr,
                once = true,
                callback = function()
                  local prompt = require('telescope.actions.state').get_current_line()
                  if prompt and prompt ~= "" then
                    vim.g._telescope_last_grep = prompt
                  end
                end,
              })
            end,
          },
        })
      end, desc = "Live grep" },
      { "<leader>fb", function() require('telescope.builtin').buffers({ sort_mru = true, select_current = true }) end, desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope harpoon marks<CR>", desc = "Harpoon marks" },
      { "<leader>go", function() require("telescope.builtin").live_grep({ grep_open_files = true }) end, desc = "Grep open files" },
    },
    config = function()
      local actions = require('telescope.actions')
      local telescope = require('telescope')
      telescope.load_extension('harpoon')
      telescope.setup({
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
            vertical = { width = 0.90 },
          },
          file_sorter = require('telescope.sorters').get_fzy_sorter,
          file_ignore_patterns = { "node_modules" },
          generic_sorter = require('telescope.sorters').get_generic_fuzzy_sorter,
          mappings = {
            i = {
              ["<esc>"] = actions.close,
            },
          },
        },
      })
    end,
  },

  -- Rails navigation (:Emodel, :Econtroller, :Eview, :A, gf in partials)
  {
    "tpope/vim-rails",
    ft = { "ruby", "eruby" },
  },

  -- Auto-close Ruby blocks (def/do/if/class → end)
  {
    "tpope/vim-endwise",
    ft = { "ruby", "eruby" },
  },

  -- Netrw (keep for file browsing)
  { "vim-scripts/netrw.vim", lazy = true },

}, {
  -- lazy.nvim global options
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "zipPlugin",
        "tohtml",
        "tutor",
      },
    },
  },
})
