local M = {}

M.setup = function(on_attach, capabilities, server_name)
  local lspconfig = require("lspconfig")
  lspconfig[server_name].setup({
    on_attach = on_attach,
    capabilities = capabilities,
  })
end

return M
