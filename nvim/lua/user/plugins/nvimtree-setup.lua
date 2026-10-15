---@diagnostic disable: redefined-local
local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
  return
end

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local status_ok, api = pcall(require, "nvim-tree.api")
if not status_ok then
  print("nvim-tree api not found")
end

local git_add = function()
  local node = api.tree.get_node_under_cursor()
  print(node)
  local gs = node.git_status.file

  -- If the current node is a directory get children status
  if gs == nil then
    if node.git_status.dir ~= nil then
      gs = (node.git_status.dir.direct ~= nil and node.git_status.dir.direct[1])
          or (node.git_status.dir.indirect ~= nil and node.git_status.dir.indirect[1])
    end
  end

  -- If the file is untracked, unstaged or partially staged, we stage it
  if gs == "??" or gs == "MM" or gs == "AM" or gs == " M" then
    vim.cmd("silent !git add " .. node.absolute_path)

    -- If the file is staged, we unstage
  elseif gs == "M " or gs == "A " then
    vim.cmd("silent !git restore --staged " .. node.absolute_path)
  end

  api.tree.reload()
end

vim.keymap.set('n', 'ga', git_add)

nvim_tree.setup {
  update_focused_file = {
    enable = true,
    update_cwd = true,
  },
  renderer = {
    root_folder_modifier = ":t",
    -- These icons are visible when you install web-devicons
    icons = {
      glyphs = {
        default = "",
        symlink = "",
        folder = {
          arrow_open = "",
          arrow_closed = "",
          default = "",
          open = "",
          empty = "",
          empty_open = "",
          symlink = "",
          symlink_open = "",
        },
        git = {
          unstaged = "",
          staged = "S",
          unmerged = "",
          renamed = "➜",
          untracked = "U",
          deleted = "",
          ignored = "◌",
        },
      },
    },
  },
  diagnostics = {
    enable = true,
    show_on_dirs = true,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    },
  },
  filters = {
    dotfiles = false,
  },
  view = {
    width = 30,
    side = "left",
    -- tree_cb (nvim-tree.config) does not exist, so these mappings dont work
    --    mappings = {
    --      list = {
    --        { key = { "l", "<CR>", "o" }, cb = tree_cb "edit" },
    --        { key = "h",                  cb = tree_cb "close_node" },
    --        { key = "v",                  cb = tree_cb "vsplit" },
    --      },
    --    },
  },
}
