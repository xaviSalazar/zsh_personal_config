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
})
vim.cmd.colorscheme('vague')
-- =========================================
-- OSC52 Clipboard
-- =========================================
keymap("n", "<leader>c", "<Plug>OSCYankOperator")
keymap("n", "<leader>cc", "<leader>c_", { remap = true })
keymap("v", "<leader>c", "<Plug>OSCYankVisual")

-- =========================================
-- Treesitter (SAFE LOAD)
-- =========================================
vim.api.nvim_create_autocmd("User", {
  pattern = "PackLoaded",
  callback = function()
    local ok, ts = pcall(require, "nvim-treesitter.configs")
    if not ok then return end

    ts.setup({
      ensure_installed = {
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
      },
      highlight = { enable = true },
      indent = { enable = true },
    })
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
  jump = { float = true },
})

-- =========================================
-- UI Message
-- =========================================
print("Neovim Ready 🚀")

