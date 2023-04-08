local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
  return
end

local status_ok, installer = pcall(require, "nvim-treesitter.install")
if not status_ok then
  return
end

installer.prefer_git = false
installer.compilers = { "clang" }

configs.setup {
  ensure_installed = "all",
  sync_install = false,
  ignore_install = { "phpdoc" }, -- List of parsers to ignore installing
  highlight = {
    enable = true, -- false will disable the whole extension
    disable = { "" }, -- list of language that will be disabled
    additional_vim_regex_highlighting = true,

  },
  autopairs = {
    enable = true,
  },
  indent = { enable = true, disable = { "yaml" } },
}
