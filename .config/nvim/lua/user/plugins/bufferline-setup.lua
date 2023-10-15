local status_ok, bufferline = pcall(require, "bufferline")
if not status_ok then
  return
end

bufferline.setup {
  options = {
    close_command = "Bdelete! %d",
    hover = {
      enabled = true,
      delay = 150,
      reveal = { 'close' }
    },
    max_name_length = 30,
    diagnostics = "nvim_lsp",
    separator_style = "thick",
  }
}
