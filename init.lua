-- ===========================
-- 🧩 Plugin Manager Bootstrap
-- ===========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Theme + UI
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  "nvim-lualine/lualine.nvim",
  "nvim-tree/nvim-tree.lua",

  -- Core LSP + IntelliSense
  "neovim/nvim-lspconfig",
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "L3MON4D3/LuaSnip",
  "saadparwaiz1/cmp_luasnip",

  -- Syntax highlighting
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- Fuzzy finder
  { "nvim-telescope/telescope.nvim", tag = "0.1.6", dependencies = { "nvim-lua/plenary.nvim" } },

  -- Terminal
  { "akinsho/toggleterm.nvim", version = "*", config = true },

  -- QoL
  "windwp/nvim-autopairs",
  "tpope/vim-commentary",
})

-- ===========================
-- ⚙️ Basic Editor Settings
-- ===========================
vim.o.number = true
vim.o.relativenumber = true
vim.o.termguicolors = true
vim.o.cursorline = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.g.mapleader = " "
vim.cmd.colorscheme "catppuccin"

-- Strong black background
vim.cmd("highlight Normal guibg=#000000")
vim.cmd("highlight NormalNC guibg=#000000")
vim.cmd("highlight SignColumn guibg=#000000")
vim.cmd("highlight LineNr guibg=#000000")
vim.cmd("highlight EndOfBuffer guibg=#000000")

-- ===========================
-- 🌈 Treesitter
-- ===========================
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "lua", "go", "javascript", "typescript", "tsx",
    "html", "css", "yaml"
  },
  highlight = { enable = true },
})

-- ===========================
-- 🔗 Utilities
-- ===========================
require("nvim-autopairs").setup {}
require("lualine").setup({ options = { theme = "catppuccin" } })

-- ===========================
-- 📁 File Explorer
-- ===========================
require("nvim-tree").setup({
  view = { width = 35 },
  renderer = { highlight_git = true, icons = { show = { file = true, folder = true } } },
  actions = { open_file = { quit_on_open = false } },
})
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")

-- ===========================
-- 🔍 Telescope
-- ===========================
require("telescope").setup({
  defaults = {
    layout_strategy = "vertical",
    sorting_strategy = "ascending",
    layout_config = { prompt_position = "top" },
  },
})
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", builtin.find_files)
vim.keymap.set("n", "<leader>fg", builtin.live_grep)
vim.keymap.set("n", "<leader>fb", builtin.buffers)
vim.keymap.set("n", "<leader>fh", builtin.help_tags)

-- ===========================
-- 🤖 Modern LSP (0.11+)
-- ===========================
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local function start_lsp(name, cmd, root_files)
  vim.lsp.start({
    name = name,
    cmd = cmd,
    root_dir = vim.fs.root(0, root_files),
    capabilities = capabilities,
  })
end

-- Go
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    start_lsp("gopls", { "gopls" }, { "go.mod", ".git" })
  end,
})

-- JS / TS / React / Next.js
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "typescriptreact", "javascriptreact" },
  callback = function()
    start_lsp("tsserver", { "typescript-language-server", "--stdio" },
      { "package.json", "tsconfig.json", ".git" })
  end,
})

-- YAML
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "yaml", "yml" },
  callback = function()
    start_lsp("yamlls", { "yaml-language-server", "--stdio" }, { ".git" })
  end,
})

-- ===========================
-- 💡 Completion (nvim-cmp)
-- ===========================
local cmp = require("cmp")

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },

  mapping = {
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),

    -- FIXED ENTER (VS CODE style)
    ["<CR>"] = function(fallback)
      if cmp.visible() then
        cmp.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        })
      else
        fallback()
      end
    end,
  },

  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
  },
})

-- autopairs integration
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

-- ===========================
-- 🧹 Format on Save
-- ===========================
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.go", "*.js", "*.ts", "*.tsx", "*.jsx", "*.yaml", "*.yml" },
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- ===========================
-- 🚦 Diagnostics + LSP Navigation
-- ===========================
vim.diagnostic.config({
  virtual_text = true,
  float = { border = "rounded" },
  severity_sort = true,
})

vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)

-- ===========================
-- 🎹 VS Code–Style Keybindings
-- ===========================

-- Ctrl + A → Select all
vim.keymap.set("n", "<C-a>", "ggVG")
vim.keymap.set("i", "<C-a>", "<Esc>ggVG")

-- Clipboard copy/paste
vim.keymap.set({ "n", "v" }, "<C-c>", '"+y')
vim.keymap.set({ "n", "v" }, "<C-S-c>", '"+y')
vim.keymap.set("n", "<C-v>", '"+p')
vim.keymap.set("v", "<C-v>", '"+p')
vim.keymap.set("i", "<C-v>", '<C-r>+')

-- Ctrl + Shift + Arrow word selection
vim.keymap.set("n", "<C-S-Right>", "ve")
vim.keymap.set("n", "<C-S-Left>", "vb")
vim.keymap.set("v", "<C-S-Right>", "e")
vim.keymap.set("v", "<C-S-Left>", "b")

-- ===========================
-- 🖥️ ToggleTerm
-- ===========================
require("toggleterm").setup({
  open_mapping = [[<C-\>]],
  direction = "float",
  shade_terminals = false,
  start_in_insert = true,
  float_opts = { border = "curved" },
})

vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])

vim.keymap.set("n", "<leader>th", function()
  require("toggleterm.terminal").Terminal:new({ direction = "horizontal" }):toggle()
end)

vim.keymap.set("n", "<leader>tv", function()
  require("toggleterm.terminal").Terminal:new({ direction = "vertical" }):toggle()
end)

