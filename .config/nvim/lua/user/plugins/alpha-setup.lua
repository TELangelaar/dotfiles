local status_ok, alpha = pcall(require, "alpha")
if not status_ok then
  return
end

local config = require("user.plugins.alpha-themes.first-theme").config
alpha.setup(config)
