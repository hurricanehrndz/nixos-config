vim.g.better_whitespace_enabled = 1
vim.g.strip_only_modified_lines = 1
vim.g.better_whitespace_filetypes_blacklist = {
  "diff",
  "git",
  "qf",
  "gitcommit",
  "unite",
  "help",
  "markdown",
  "fugitive",
  "toggleterm",
}
vim.cmd("autocmd BufWritePre * :StripWhitespace")
