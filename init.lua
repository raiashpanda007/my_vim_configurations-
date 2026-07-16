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

function ColorMyPencils(color)
  color = color or "rose-pine"
  vim.cmd.colorscheme(color)

  -- Force Transparency
  local hl_groups = { "Normal", "NormalFloat", "NormalNC", "Pmenu", "SignColumn", "TelescopeNormal", "TelescopeBorder" }
  for _, group in ipairs(hl_groups) do
    vim.api.nvim_set_hl(0, group, { bg = "none" })
  end

  -- Muted & Italic Comments
  vim.api.nvim_set_hl(0, "Comment", { fg = "#6e6a86", italic = true })

  -- Muted & Italic Unused Variables (DiagnosticUnnecessary)
  vim.api.nvim_set_hl(0, "DiagnosticUnnecessary", { fg = "#6e6a86", italic = true })

  -- Subtle Line Numbers
  vim.api.nvim_set_hl(0, "LineNr", { fg = "#6e6a86" })
  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#e0def4", bold = true })
end

require("lazy").setup({
  {
    "folke/tokyonight.nvim",
    config = function()
      require("tokyonight").setup({
        style = "storm",
        transparent = true,
        terminal_colors = true,
        styles = {
          comments = { italic = false },
          keywords = { italic = false },
          sidebars = "dark",
          floats = "dark",
        },
      })
    end,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      require("rose-pine").setup({ disable_background = true })
      vim.cmd("colorscheme rose-pine")
      ColorMyPencils()
    end,
  },
  "nvim-tree/nvim-web-devicons",
  "nvim-lualine/lualine.nvim",
  "nvim-tree/nvim-tree.lua",

  -- LSP + Completion

  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",
  "neovim/nvim-lspconfig",
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "L3MON4D3/LuaSnip",
  "saadparwaiz1/cmp_luasnip",

  -- Syntax
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- Telescope
  { "nvim-telescope/telescope.nvim",   tag = "0.1.6",      dependencies = { "nvim-lua/plenary.nvim" } },

  -- Terminal
  { "akinsho/toggleterm.nvim",         version = "*",      config = true },

  -- GitHub Copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end,
  },

  -- QoL
  "windwp/nvim-autopairs",
  "tpope/vim-commentary",

  -- UI Enhancements
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
  -- TODO Comments: highlights and searches TODO/FIX/HACK across languages
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("todo-comments").setup({
        signs = true,
        keywords = {
          FIX = { icon = " ", color = "#ff6b6b" },
          TODO = { icon = " ", color = "#ff6b6b" },
          HACK = { icon = " ", color = "warning" },
          WARN = { icon = " ", color = "warning" },
          NOTE = { icon = " ", color = "hint" },
        },
        highlight = { multiline = false, before = "", after = "fg" },
      })

      vim.keymap.set("n", "<leader>tt", "<cmd>TodoTelescope<CR>", { silent = true, desc = "Todos (Telescope)" })
      vim.keymap.set("n", "<leader>tq", "<cmd>TodoQuickFix<CR>", { silent = true, desc = "Todos (QuickFix)" })
    end,
  },
  "nvim-treesitter/nvim-treesitter-context",

  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add    = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "▁" },
        },
      })
    end,
  },
  {
    "j-hui/fidget.nvim",
    tag = "legacy",
    config = function()
      require("fidget").setup({ text = { spinner = "dots" } })
    end,
  },
})

-- ===========================
-- ⚙️ Editor Settings
-- ===========================
vim.o.number = true
vim.o.relativenumber = true
vim.o.termguicolors = true
vim.o.cursorline = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.opt.splitright = true
vim.g.mapleader = " "



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
require("nvim-autopairs").setup({})
require("lualine").setup({
  options = {
    theme                = "rose-pine",
    component_separators = { left = "", right = "" },
    section_separators   = { left = "", right = "" },
    globalstatus         = true,
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = {
      { "branch", icon = "" },
      {
        "diff",
        symbols = { added = " ", modified = " ", removed = " " },
        source = function()
          local gs = vim.b.gitsigns_status_dict
          if gs then return { added = gs.added, modified = gs.changed, removed = gs.removed } end
        end,
      },
    },
    lualine_c = { { "filename", path = 1, symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" } } },
    lualine_x = {
      { "diagnostics", sources = { "nvim_lsp" }, symbols = { error = " ", warn = " ", hint = " ", info = " " } },
      "filetype",
    },
    lualine_y = {},
    lualine_z = { "location" },
  },
})

-- UI Configs
vim.opt.pumblend = 10 -- Popup transparency
vim.opt.winblend = 10 -- Floating window transparency

require("treesitter-context").setup({ mode = "cursor", max_lines = 3 })

require("ibl").setup({
  indent = { char = "│" },
  scope = { enabled = true, show_start = false, show_end = false },
})


-- ===========================
-- 📁 NvimTree
-- ===========================
require("nvim-tree").setup({
  view = { width = 35 },
  git = { enable = true, ignore = false },
  renderer = {
    highlight_git = true,
    icons = {
      show = { git = true, file = true, folder = true },
      glyphs = {
        git = {
          unstaged  = "✚",
          staged    = "✔",
          untracked = "★",
          deleted   = "✖",
          renamed   = "➜",
          ignored   = "◌",
        },
      },
    },
  },
  actions = { open_file = { quit_on_open = false } },
})
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")

-- ===========================
-- 🔍 Telescope
-- ===========================

-- Close NvimTree when opening a file (not a folder). If a directory
-- is opened on startup, open the tree instead.
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  callback = function(data)
    local fname = data.file
    if not fname or fname == "" then
      -- no argument: do nothing
      return
    end
    if vim.fn.isdirectory(fname) == 1 then
      pcall(function()
        require("nvim-tree.api").tree.open()
      end)
    else
      -- ensure tree is closed when starting with a file
      pcall(function()
        require("nvim-tree.api").tree.close()
      end)
    end
  end,
})

-- Close NvimTree when entering a regular file buffer, but don't close
-- it when entering the NvimTree buffer itself. This lets you toggle the
-- tree manually after opening a file.
vim.api.nvim_create_autocmd({ "BufWinEnter", "BufReadPost" }, {
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")

    -- don't act on the tree buffer itself
    if ft == "NvimTree" or ft == "nvim-tree" then
      return
    end

    local name = vim.api.nvim_buf_get_name(bufnr)
    if name == "" then
      return
    end

    -- only close if the buffer is not a directory and the tree is visible
    if vim.fn.isdirectory(name) == 0 then
      pcall(function()
        local api = require("nvim-tree.api")
        if api and api.tree and api.tree.is_visible and api.tree.is_visible() then
          api.tree.close()
        end
      end)
    end
  end,
})
local actions = require("telescope.actions")
require("telescope").setup({
  defaults = {
    layout_strategy = "horizontal",
    sorting_strategy = "ascending",
    layout_config = {
      prompt_position = "top",
      horizontal = {
        preview_width = 0.55,
        results_width = 0.8,
      },
      width = 0.87,
      height = 0.40,
      preview_cutoff = 120,
    },
    mappings = {
      i = { ["<A-Enter>"] = actions.select_vertical },
      n = { ["<A-Enter>"] = actions.select_vertical },
    },
  },
})

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", builtin.find_files)
vim.keymap.set("n", "<leader>fg", builtin.live_grep)
vim.keymap.set("n", "<leader>fb", builtin.buffers)
vim.keymap.set("n", "<leader>fh", builtin.help_tags)

-- LSP capabilities for nvim-cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities(
  vim.lsp.protocol.make_client_capabilities()
)

-- ===========================
-- 🤖 LSP (Mason + lspconfig)
-- ===========================
-- Enable default servers
local servers = { "gopls", "ts_ls", "yamlls", "tailwindcss", "jsonls", "clangd", "html", "cssls", "sqls", "prismals" }

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = vim.list_extend({ "lua_ls" }, servers),
})

for _, server in ipairs(servers) do
  vim.lsp.config(server, { capabilities = capabilities })
  vim.lsp.enable(server)
end

-- Lua LS with specific settings
vim.lsp.config("lua_ls", {
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
    },
  },
})
vim.lsp.enable("lua_ls")

-- ===========================
-- 💡 Completion
-- ===========================
local cmp = require("cmp")

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = {
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace, -- ✅ FIX
      select = true,
    }),
  },
  sources = {
    { name = "copilot",  group_index = 2 },
    { name = "nvim_lsp", group_index = 2 },
    { name = "luasnip",  group_index = 2 },
    { name = "buffer",   group_index = 2 },
  },
})

local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())

-- ===========================
-- 🧹 Format on Save
-- ===========================
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- ===========================
-- 🚦 Diagnostics + Nav
-- ===========================
vim.diagnostic.config({
  virtual_text = true,
  float = { border = "rounded" },
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN]  = " ",
      [vim.diagnostic.severity.HINT]  = "󰌵 ",
      [vim.diagnostic.severity.INFO]  = " ",
    },
  },
})

vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)

-- ===========================
-- 🎹 VS Code–Style Keybindings (PRESERVED)
-- ===========================
vim.keymap.set("n", "<C-a>", "ggVG")
vim.keymap.set("i", "<C-a>", "<Esc>ggVG")

vim.keymap.set({ "n", "v" }, "<C-c>", '"+y')
vim.keymap.set({ "n", "v" }, "<C-S-c>", '"+y')
vim.keymap.set("n", "<C-v>", '"+p')
vim.keymap.set("v", "<C-v>", '"+p')
vim.keymap.set("i", "<C-v>", "<C-r>+")

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

-- ===========================
-- ⌨️ User Custom Keymaps
-- ===========================
-- Cycle through windows (screens) circularly (Left -> Right)
vim.keymap.set({ "n", "i", "v" }, "<A-w>", "<cmd>wincmd w<CR>")

-- Toggle Side Directory (NvimTree)
vim.keymap.set({ "n", "i", "v" }, "<C-b>", "<cmd>NvimTreeToggle<CR>")

-- Toggle Copilot
local copilot_enabled = true
vim.keymap.set("n", "<leader>cp", function()
  if copilot_enabled then
    vim.cmd("Copilot disable")
    copilot_enabled = false
    vim.notify("Copilot disabled", vim.log.levels.INFO)
  else
    vim.cmd("Copilot enable")
    copilot_enabled = true
    vim.notify("Copilot enabled", vim.log.levels.INFO)
  end
end, { desc = "Toggle Copilot" })
