local M = {}

M.setup = function(on_attach, capabilities)
  local lspconfig = require("lspconfig")
  lspconfig.rnix.setup({
    settings = {},
    on_attach = on_attach,
    capabilities = capabilities,
  })
end

return M
