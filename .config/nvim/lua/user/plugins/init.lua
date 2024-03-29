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
  print("Installing lazyvim. Close and reopen NeoVim ...")
end
vim.opt.rtp:prepend(lazypath)

-- Use a protected call so we dont error out on first use
local status_ok, lazy = pcall(require, "lazy")
if not status_ok then
  print("lazy does not exist")
  return
end

local plugins = {
  -- defaults
  "nvim-lua/plenary.nvim",                                                               -- useful functions written by TJDeVries, used in a lot of packages
  { "goolord/alpha-nvim",   lazy = true, dependencies = "nvim-tree/nvim-web-devicons" }, -- nice start screen
  { "folke/which-key.nvim", lazy = true },                                               -- shop keymaps

  -- handy utils
  "numToStr/Comment.nvim",                           -- better commenting
  "akinsho/toggleterm.nvim",                         -- open terminal
  "moll/vim-bbye",                                   -- better buffer deletion
  { "kylechui/nvim-surround",  event = "VeryLazy" }, -- surround with brackets/accolades etc etc
  "windwp/nvim-autopairs",                           -- autoclose pairs
  "norcalli/nvim-colorizer.lua",

  -- editor styling (tree, bufferline, lualine, etc etc)
  "nvim-tree/nvim-web-devicons",
  { "nvim-tree/nvim-tree.lua", dependencies = { 'nvim-tree/nvim-web-devicons' } },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = {
      "nvim-tree/nvim-web-devicons" }
  },
  { 'nvim-lualine/lualine.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' } },

  -- colorschemes
  "lunarvim/colorschemes",


  -- LSP
  "williamboman/mason.nvim",           -- mason for LSP, DAP, Formatters etc
  "williamboman/mason-lspconfig.nvim", -- bridges the gap between nvim-lspconfig and mason
  "neovim/nvim-lspconfig",             -- enable LSP

  -- Autocompletions
  "hrsh7th/nvim-cmp",    -- The completion plugin
  "hrsh7th/cmp-buffer",  -- buffer completions
  "hrsh7th/cmp-path",    -- path completions
  "hrsh7th/cmp-cmdline", -- cmdline completions
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-nvim-lua",

  -- snippets
  "L3MON4D3/LuaSnip",                            -- snippet engine
  { "saadparwaiz1/cmp_luasnip",  lazy = true, }, -- snippet completions
  "rafamadriz/friendly-snippets",                -- a bunch of snippets to use

  -- Treesitter
  "nvim-treesitter/nvim-treesitter",

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.4",
    dependencies = { "nvim-lua/plenary.nvim",
      "BurntSushi/ripgrep" }
  },
  { "BurntSushi/ripgrep",                       tag = "13.0.0" },
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', dependencies = "nvim-telescope/telescope.nvim" }
}

local opts = {}
lazy.setup(plugins, opts)

require("user.plugins.whichkey-setup")
require("user.plugins.nvimsurround-setup")
require("user.plugins.comment-setup")
require("user.plugins.toggleterm-setup")
require("user.plugins.autopairs-setup")
require("user.plugins.bufferline-setup")
require("user.plugins.lualine-setup")
require("user.plugins.nvimtree-setup")
require("user.plugins.alpha-setup")
require("user.plugins.telescope-setup")
require("user.plugins.treesitter-setup")
require("user.plugins.color-themes.darkplus.lua.darkplus")
