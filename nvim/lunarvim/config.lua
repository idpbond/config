if vim.g.neovide then
  vim.opt.guifont = { "FiraCode Nerd Font Mono", "h12" } -- text below applies for VimScript
  vim.g.neovide_scale_factor = 1.2
  vim.g.neovide_cursor_vfx_mode = "ripple"
  vim.o.relativenumber = true
end


-- general
lvim.log.level = "warn"
lvim.format_on_save.enabled = true
lvim.colorscheme = "jellybeans-nvim"
-- to disable icons and use a minimalist setup, uncomment the following
-- lvim.use_icons = false
local tscope = require('telescope.builtin')
-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
-- add your own keymapping
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
lvim.keys.normal_mode["<C-p>"] = "<cmd>Telescope find_files<cr>"
-- lvim.keys.normal_mode["<C-b>"] = "<cmd>Telescope buffers<cr>"
lvim.keys.normal_mode["<C-b>"] = function()
  tscope.buffers({ sort_lastused = true, ignore_current_buffer = true, show_all_buffers = false, initial_mode = 'insert' })
end

lvim.keys.normal_mode["<C-j>"] = "<cmd>bn<cr>"
lvim.keys.normal_mode["<C-k>"] = "<cmd>bp<cr>"

local _, actions = pcall(require, "telescope.actions")
lvim.builtin.telescope.defaults.mappings = {
  -- for input mode
  i = {
    ["<C-j>"] = actions.move_selection_next,
    ["<C-k>"] = actions.move_selection_previous,
    ["<C-n>"] = actions.cycle_history_next,
    ["<C-p>"] = actions.cycle_history_prev,
  },
  -- for normal mode
  n = {
    ["<C-j>"] = actions.move_selection_next,
    ["<C-k>"] = actions.move_selection_previous,
  },
}

lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "elixir",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "tsx",
  "css",
  "rust",
  "java",
  "yaml",
}

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enable = true

-- generic LSP settings

-- make sure server will always be installed even if the server is in skipped_servers list
-- lvim.lsp.installer.setup.ensure_installed = {
--     "prisma-language-server",
--     "yaml-language-server",
--     "typescript-language-server",
--     "lua-language-server",
--     "codespell",
--     "bash-language-server",
--     "css-lsp",
--     "elixir-ls",
--     "html-lsp",
--     "json-lsp",
--     "prettier",
--     "shellcheck",
--     "tailwindcss-language-server",
--     "vim-language-server",
-- }
-- require("lvim.lsp.manager").setup("tailwindcss")

local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { command = "black", filetypes = { "python" } },
  { command = "isort", filetypes = { "python" } },
  {
    command = "prettier",
    filetypes = { "typescript", "typescriptreact", "javascript" },
  },
}

local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  { command = "flake8", filetypes = { "python" } },
  {
    command = "shellcheck",
    extra_args = { "--severity", "warning" },
  },
  {
    command = "codespell",
    filetypes = { "javascript", "python" },
  },
  {
    command = "eslint",
    filetypes = { "javascript", "typescript", "typescriptreact" },
  }
}

local code_actions = require "lvim.lsp.null-ls.code_actions"
code_actions.setup({
  {
    exe = "eslint",
    filetypes = {
      "javascriptreact",
      "javascript",
      "typescriptreact",
      "typescript",
      "vue",
    },
  }
})

-- Additional Plugins
lvim.plugins = {
  -- {
  --     "folke/trouble.nvim",
  --     cmd = "TroubleToggle",
  -- },
  { "rktjmp/lush.nvim" },
  { "metalelf0/jellybeans-nvim" },
}
