local g = vim.g

-- Disable python plugin support
local vim_bin_path = vim.env.HOME .. "/.local/share/envs/nvim/bin"
if vim.fn.isdirectory(vim_bin_path) then
  vim.env.PATH = vim_bin_path .. ":" .. vim.env.PATH
end
g.loaded_python_provider = 0
g.loaded_python3_provider = 0
g.loaded_node_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0
g.filetype_pp = "puppet"
g.hrnd_theme = "tokyonight"

-- disable editorconfig autolaoding
g.loaded_editorconfig = 1

local options = {
  -- >> window-scoped options <<--
  -- show line numbers
  number = true,
  -- show relative numbers
  relativenumber = true,
  -- always have sign column
  signcolumn = "yes",
  -- disable line wrap
  wrap = false,
  -- enable color column
  colorcolumn = "+1",

  -- >> edior options <<--
  -- cursor
  guicursor = "",
  -- abandon buffer when unloading
  hidden = true,
  -- refresh rate of diagnostic msg, completion
  updatetime = 100,
  -- split new window below current
  splitbelow = true,
  -- split new window right of current
  splitright = true,
  -- case insensitive search
  ignorecase = true,
  -- highlight searches
  hlsearch = true,
  -- copy-paste with system clipboard, no copy to unnamed on put (*)
  clipboard = "",
  -- some language servers don't like backup files
  backup = false,
  writebackup = false,
  -- scrolling "bounding"
  scrolloff = 5,
  sidescrolloff = 10,
  -- strings to use in list command for punctuation
  listchars = [[tab:→ ,eol:↲,space:␣,trail:•,extends:⟩,precedes:⟨]],
  smartcase = true,
  -- enable undofile - persistent undo
  undofile = true,
  -- round indent
  shiftround = true,

  -- >> buffer-scoped options <<--
  shiftwidth = 2, -- smarttab enable by default, ts sts ignored,
  expandtab = true,
  smartindent = true,
}

for k, v in pairs(options) do
  vim.opt[k] = v
end
