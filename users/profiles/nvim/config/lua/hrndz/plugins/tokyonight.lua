vim.o.termguicolors = true
vim.o.background = "dark"
vim.cmd("syntax on")

local has_tokyonight, tokyonight = pcall(require, "tokyonight")
if has_tokyonight then
  tokyonight.setup({
    style = "night",
    sidebars = { "qf", "vista_kind", "terminal", "packer" },
  })

  -- Load the colorscheme
  vim.cmd([[colorscheme tokyonight]])
end
