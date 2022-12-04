local has_trouble, trouble = pcall(require, "trouble")
if not has_trouble then
  return
end

trouble.setup({
  auto_fold = true,
  icons = true,
  use_diagnostic_signs = true,
})

local map = require("hrndz.utils").map
map("n", "<space>lt", "<Cmd>TroubleToggle<CR>", "Diagnostics")
