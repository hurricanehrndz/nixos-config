local has_nwin, nwin = pcall(require, "nvim-window")
if not has_nwin then
  return
end

local map = vim.keymap.set
nwin.setup({})
map("n", ",W", function()
  return nwin.pick()
end, { noremap = true, desc = "Pick window" })
