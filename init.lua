-- ~/.config/nvim/init.lua

-- =========================================
-- Leader
-- =========================================
vim.g.mapleader = " "

-- =========================================
-- Basic Settings
-- =========================================
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true

vim.opt.termguicolors = true
vim.opt.mouse = ""

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false

-- vim.opt.clipboard = "unnamedplus"

-- Better splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Faster update time
vim.opt.updatetime = 250

-- =========================================
-- Keymaps
-- =========================================
local keymap = vim.keymap.set

keymap("n", "<leader>w", "<cmd>w<CR>", { silent = true })
keymap("n", "<leader>q", "<cmd>q<CR>", { silent = true })

-- Clear search highlights
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- =========================================
-- Built-in Package Manager (vim.pack)
-- =========================================
-- Built-in Package Manager
vim.pack.add({
  "https://github.com/ojroques/vim-oscyank",

  -- LSP (C++ intelligence)
  "https://github.com/neovim/nvim-lspconfig",

  -- Syntax highlighting
  "https://github.com/nvim-treesitter/nvim-treesitter",

  -- Fuzzy finder
  "https://github.com/nvim-telescope/telescope.nvim",

  -- Required dependency for telescope
  "https://github.com/nvim-lua/plenary.nvim",

  "https://github.com/hrsh7th/nvim-cmp",
  "https://github.com/hrsh7th/cmp-nvim-lsp",
  "https://github.com/hrsh7th/cmp-buffer",
  "https://github.com/L3MON4D3/LuaSnip",
  "https://github.com/saadparwaiz1/cmp_luasnip",
  "https://github.com/windwp/nvim-autopairs",
  "https://github.com/numToStr/comment.nvim",

  -- Git 
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/tpope/vim-fugitive",
  "https://github.com/sindrets/diffview.nvim",

  -- Icons
  "https://github.com/nvim-tree/nvim-web-devicons",

  -- Themes
  "https://github.com/vague-theme/vague.nvim",
  "https://github.com/folke/tokyonight.nvim",

  -- UI
  "https://github.com/akinsho/bufferline.nvim",
  "https://github.com/Isrothy/neominimap.nvim",
  "https://github.com/folke/snacks.nvim",
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/folke/which-key.nvim",

  -- Command-line completion for ':' and '/'
  "https://github.com/hrsh7th/cmp-cmdline",
})
if not pcall(vim.cmd.colorscheme, "vague") then
  pcall(vim.cmd.colorscheme, "tokyonight")
end

-- Make window borders as visible as herdr's pane outlines (from bull-toolchain
-- options.lua). Reapplied on every colorscheme change so a :colorscheme call
-- doesn't wipe it.
local function set_window_borders()
  vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#82AAFF", bg = "NONE" })
end

local borders_group = vim.api.nvim_create_augroup("window_borders", { clear = true })
vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
  group = borders_group,
  callback = function()
    vim.schedule(set_window_borders)
  end,
})
-- =========================================
-- OSC52 Clipboard
-- =========================================
keymap("n", "<leader>c", "<Plug>OSCYankOperator")
keymap("n", "<leader>cc", "<leader>c_", { remap = true })
keymap("v", "<leader>c", "<Plug>OSCYankVisual")

-- Auto-mirror real yanks (y, not d/c/x) into the system clipboard via OSC52.
-- Provider must exist before anything touches the + register.
local function osc52_copy(lines, _)
  local seq = "\27]52;c;" .. vim.base64.encode(table.concat(lines, "\n")) .. "\7"
  local tty = io.open("/dev/tty", "w")
  if tty then
    tty:write(seq)
    tty:close()
  else
    vim.api.nvim_chan_send(2, seq)
  end
end

local function paste_local()
  return vim.split(vim.fn.getreg('"'), "\n"), vim.fn.getregtype('"')
end

vim.g.clipboard = {
  name = "osc52-bel",
  copy = { ["+"] = osc52_copy, ["*"] = osc52_copy },
  paste = { ["+"] = paste_local, ["*"] = paste_local },
}

-- Don't route every register operation through the clipboard; deletes would
-- clobber it and emit an OSC 52 sequence on every dd.
vim.opt.clipboard = ""

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("yank_to_clipboard", { clear = true }),
  callback = function()
    local e = vim.v.event
    if e.operator == "y" then
      vim.fn.setreg("+", e.regcontents, e.regtype)
    end
  end,
})

-- =========================================
-- Treesitter (new main-branch API)
-- =========================================
local ts_parsers = {
  "lua",
  "javascript",
  "typescript",
  "tsx",
  "html",
  "css",
  "json",
  "c",
  "cpp",
  "bash",
}

require("nvim-treesitter").install(ts_parsers)

vim.api.nvim_create_autocmd("FileType", {
  pattern = ts_parsers,
  callback = function(event)
    -- pcall: install() is async, so the parser may not be compiled yet
    pcall(vim.treesitter.start, event.buf)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

-- =========================================
-- Autopairs / Comments
-- =========================================
pcall(function()
  require("nvim-autopairs").setup({})
end)

pcall(function()
  require("Comment").setup()
end)

pcall(function()
  require("gitsigns").setup()
end)

-- =========================================
-- Bufferline
-- =========================================
require("bufferline").setup({})

-- buffer navigation
keymap("n", "<leader>bh", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
keymap("n", "<leader>bl", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
keymap("n", "<leader>b<Left>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
keymap("n", "<leader>b<Right>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })

-- delete buffers in that direction
keymap("n", "<leader>bH", "<cmd>BufferLineCloseLeft<CR>", { desc = "Delete buffers left" })
keymap("n", "<leader>bL", "<cmd>BufferLineCloseRight<CR>", { desc = "Delete buffers right" })
keymap("n", "<leader>b<S-Left>", "<cmd>BufferLineCloseLeft<CR>", { desc = "Delete buffers left" })
keymap("n", "<leader>b<S-Right>", "<cmd>BufferLineCloseRight<CR>", { desc = "Delete buffers right" })

-- =========================================
-- Neominimap
-- =========================================
vim.opt.wrap = false
vim.opt.sidescrolloff = 16

vim.g.neominimap = {
  auto_enable = false,
  layout = "float",
  float = {
    minimap_width = 14,
    window_border = "none",
  },

  delay = 400,
  fold = { enabled = false },
  sync_cursor = true,
  click = { enabled = true, auto_switch_focus = false },
  search = { enabled = false },
  mark = { enabled = false },

  treesitter = { enabled = true },
  git = { enabled = true, mode = "sign" },
  diagnostic = {
    enabled = true,
    severity = vim.diagnostic.severity.WARN,
    mode = "sign",
  },

  -- Skip the minimap on buffers where building it is the expensive part.
  buf_filter = function(bufnr)
    if not vim.api.nvim_buf_is_loaded(bufnr) then
      return false
    end
    local name = vim.api.nvim_buf_get_name(bufnr)
    local stat = name ~= "" and (vim.uv or vim.loop).fs_stat(name) or nil
    if stat and stat.size > 512 * 1024 then
      return false
    end
    if vim.api.nvim_buf_line_count(bufnr) > 20000 then
      return false
    end
    return true
  end,

  exclude_filetypes = {
    "help",
    "man",
    "qf",
    "checkhealth",
    "gitcommit",
    "gitrebase",
    "bigfile",
    "neo-tree",
    "oil",
    "netrw",
    "toggleterm",
    "lazy",
    "mason",
    "lazyterm",
    "trouble",
    "aerial",
    "noice",
    "grug-far",
    "dbout",
    "snacks_dashboard",
    "snacks_terminal",
    "snacks_notif",
    "snacks_notif_history",
    "snacks_win_backdrop",
    "snacks_input",
    "snacks_picker_list",
    "snacks_picker_input",
    "snacks_picker_preview",
  },

  exclude_buftypes = {
    "nofile",
    "nowrite",
    "quickfix",
    "terminal",
    "prompt",
    "help",
    "acwrite",
  },
}

-- vim.pack adds with :packadd! during init.lua, so plugin/ scripts never
-- ran; source it explicitly now that vim.g.neominimap is set.
vim.cmd.packadd("neominimap.nvim")

keymap("n", "<leader>mm", "<cmd>Neominimap Toggle<CR>", { desc = "Toggle minimap (global)" })
keymap("n", "<leader>mr", "<cmd>Neominimap Refresh<CR>", { desc = "Refresh minimap" })
keymap("n", "<leader>mb", "<cmd>Neominimap BufToggle<CR>", { desc = "Toggle minimap (buffer)" })
keymap("n", "<leader>mw", "<cmd>Neominimap WinToggle<CR>", { desc = "Toggle minimap (window)" })
keymap("n", "<leader>mf", "<cmd>Neominimap ToggleFocus<CR>", { desc = "Toggle focus on minimap" })

-- =========================================
-- Snacks (explorer + picker)
-- =========================================
require("snacks").setup({
  explorer = { hidden = true, ignored = true },
  picker = {
    sources = {
      explorer = { hidden = true, ignored = true },
      files = { hidden = true, ignored = true },
    },
  },
})

keymap("n", "<leader>e", function() require("snacks").explorer() end, { desc = "File explorer" })
keymap("n", "<leader>f.", function() require("snacks").picker.files() end, { desc = "Files (snacks, incl. hidden)" })

-- =========================================
-- Lualine
-- =========================================
vim.opt.laststatus = 3
vim.opt.showmode = false

require("lualine").setup({
  options = {
    theme = "auto",
    icons_enabled = true,
    globalstatus = true,
    section_separators = { left = "", right = "" },
    component_separators = { left = "", right = "" },
  },
})

-- =========================================
-- Which-key
-- =========================================
require("which-key").setup({
  spec = {
    { "<leader>b", group = "buffers", icon = "󰈩" },
    { "<leader>c", group = "clipboard" },
    { "<leader>f", group = "find" },
    { "<leader>m", group = "minimap", icon = "󰍉" },
    { "<leader>e", group = "explorer" },
  },
})

-- =========================================
-- LSP (INCLUDING ESLINT)
-- =========================================
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- TypeScript / React
vim.lsp.config("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  capabilities = capabilities,
})

-- ESLINT (🔥 IMPORTANT)
vim.lsp.config("eslint", {
  cmd = { "vscode-eslint-language-server", "--stdio" },

  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },

  root_dir = vim.fs.root(0, {
    ".eslintrc",
    ".eslintrc.js",
    ".eslintrc.json",
    "eslint.config.js",
    "package.json",
  }),

  settings = {
    workingDirectory = { mode = "auto" },
    format = true,
  },

  capabilities = capabilities,
})

-- HTML
vim.lsp.config("html", {
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html" },
  capabilities = capabilities,
})

-- CSS
vim.lsp.config("cssls", {
  cmd = { "vscode-css-language-server", "--stdio" },
  filetypes = { "css", "scss", "less" },
  capabilities = capabilities,
})

-- Lua
vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  capabilities = capabilities,
})

-- C / C++
vim.lsp.config("clangd", {
  cmd = {
    "clangd-22",
    "--background-index",
    "--clang-tidy",
    "--completion-style=detailed",

  },
  filetypes = { "c", "cpp" },
  capabilities = capabilities,
})

vim.lsp.config("bashls", {
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh", "bash" },
  capabilities = capabilities,
})

vim.lsp.enable({
  "ts_ls",
  "eslint", -- 🔥 ENABLED
  "html",
  "cssls",
  "lua_ls",
  "clangd",
  "bashls",
})

-- =========================================
-- nvim-cmp
-- =========================================
local cmp = require("cmp")

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },

  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
  }),

  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
  },
})

-- =========================================
-- Cmdline completion (':' and '/')
-- =========================================
local cmdline_mapping = cmp.mapping.preset.cmdline({
  -- Only confirm when an entry is actually selected. Otherwise <CR>
  -- falls through and runs what you typed, rather than silently
  -- accepting a suggestion you never looked at.
  ["<CR>"] = cmp.mapping(function(fallback)
    if cmp.visible() and cmp.get_active_entry() then
      cmp.confirm({ select = true })
    else
      fallback()
    end
  end, { "c" }),
  ["<Tab>"] = cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_next_item()
    else
      fallback()
    end
  end, { "c" }),
  ["<S-Tab>"] = cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_prev_item()
    else
      fallback()
    end
  end, { "c" }),
})

-- ':' completes paths first, then commands.
cmp.setup.cmdline(":", {
  mapping = cmdline_mapping,
  sources = cmp.config.sources({
    { name = "path" },
  }, {
    { name = "cmdline" },
  }),
  completion = {
    completeopt = "menu,menuone,noselect",
  },
  preselect = cmp.PreselectMode.Item,
})

-- '/' and '?' complete from the current buffer.
cmp.setup.cmdline({ "/", "?" }, {
  mapping = cmdline_mapping,
  sources = {
    { name = "buffer" },
  },
  preselect = cmp.PreselectMode.Item,
})

-- =========================================
-- Telescope
-- =========================================
require("telescope").setup({
  defaults = {
    file_ignore_patterns = {
      "node_modules",
      ".git/",
      "dist",
    },
  },
})

local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", builtin.find_files)
vim.keymap.set("n", "<leader>fg", builtin.live_grep)
vim.keymap.set("n", "<leader>fb", builtin.buffers)
vim.keymap.set("n", "<leader>fh", builtin.help_tags)

-- =========================================
-- LSP Keymaps
-- =========================================
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local opts = { buffer = ev.buf }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  end,
})

-- =========================================
-- ESLINT AUTO FIX ON SAVE
-- =========================================
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" },
--   callback = function()
--     vim.cmd("EslintFixAll")
--   end,
-- })

-- =========================================
-- Diagnostics
-- =========================================
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  jump = {
    on_jump = function()
      vim.diagnostic.open_float()
    end,
  },
})

-- =========================================
-- UI Message
-- =========================================
print("Neovim Ready 🚀")

