local lspconfig = require('lspconfig')
local lsp_defaults = lspconfig.util.default_config

lsp_defaults.capabilities = vim.tbl_deep_extend(
  'force',
  lsp_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)


vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = { buffer = event.buf }

    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
    vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
    vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
    vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
    vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)

    vim.keymap.set('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
    vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<cr>', opts)
    vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<cr>', opts)
  end
})

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    -- For Testing
    --vim.api.nvim_set_hl(0, '@lsp.type.parameter', { fg = "Purple" })
    vim.api.nvim_set_hl(0, '@lsp.mod.readonly', { italic = true })

    -- c# / dotnet
    vim.api.nvim_set_hl(0, '@lsp.type.interface.cs', { fg = "#B5CEA8", })
    vim.api.nvim_set_hl(0, '@lsp.type.class.cs', { fg = "#4EC9B0", })
    vim.api.nvim_set_hl(0, '@lsp.type.fieldName.cs', { fg = "#D8DEE9" })
    vim.api.nvim_set_hl(0, '@lsp.type.method.cs', { fg = "#DCDCAA" })
  end
})

require("user.lsp.mason-handler")
require("user.lsp.cmp-handler")
