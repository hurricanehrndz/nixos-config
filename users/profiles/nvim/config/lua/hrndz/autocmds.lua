---@diagnostic disable: assign-type-mismatch
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local help_files = augroup("HelpFiles", { clear = true })
autocmd("Filetype", {
  pattern = { "help" },
  callback = function()
    local bufopts = { buffer = 0, noremap = true, silent = true }
    local nvo = { "n", "v", "o" }
    vim.keymap.set(nvo, "<C-c>", [[<cmd>q<CR>]], bufopts)
    vim.keymap.set(nvo, "q", [[<cmd>q<CR>]], bufopts)
  end,
  group = help_files,
})

local spell_enabled_files = augroup("SpellingEnabledFiles", { clear = true })
autocmd("Filetype", {
  pattern = { "markdown", "gitcommit" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en"
  end,
  group = spell_enabled_files,
})

local yank_group = augroup("HighlightYank", {})
autocmd("TextYankPost", {
  group = yank_group,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 40,
    })
  end,
})
