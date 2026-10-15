local status_ok, lspconfig = pcall(require, "lspconfig")
if not status_ok then
  print("lspconfig does not exist")
  return
end


local status_ok, mason = pcall(require, 'mason')
if not status_ok then
  print("mason does not exist")
  return
end
mason.setup({})


local default_setup = function(server)
  lspconfig[server].setup({})
end

local status_ok, mason_lspconfig = pcall(require, 'mason-lspconfig')
if not status_ok then
  print("mason-lspconfig does not exist")
  return
end

mason_lspconfig.setup({
  ensure_installed = {},
  handlers = { default_setup },
})
