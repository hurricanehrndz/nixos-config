local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
  return
end

-- Set git editor in toggleterm
vim.env.GIT_EDITOR = "nvr --remote-tab-wait +'set bufhidden=wipe'"

toggleterm.setup({
  open_mapping = nil,
  hide_numbers = true,
  direction = "float",
  close_on_exit = true,
  start_in_insert = true,
  -- can not persist, if I want to always start in insert
  persist_mode = false,
})

local Terminal = require("toggleterm.terminal").Terminal
local lazygit = Terminal:new({
  cmd = "lazygit",
  count = 99,
  hidden = true,
  direction = "float",
  insert_mappings = false,
  close_on_exit = true,
  persist_mode = false,
  start_in_insert = true,
  on_open = function(term)
    local map_opts = { buffer = term.bufnr, noremap = true, silent = true }
    vim.keymap.set("n", "q", "<cmd>close<CR>", map_opts)
  end,
})

function _LAZYGIT_TOGGLE()
  lazygit:toggle()
end

local opts = { noremap = true, silent = true }
local lg_toggle = [[<Cmd>lua _LAZYGIT_TOGGLE()<CR>]]
local lg_term_toggle = [[q]]
vim.keymap.set("n", "<C-g>", lg_toggle, opts)
vim.keymap.set("t", "<C-g>", lg_term_toggle, opts)

local term_open_group = vim.api.nvim_create_augroup("HrndzTermOpen", { clear = true })
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = { "term://*" },
  callback = function()
    local bufopts = { buffer = 0, noremap = true, silent = true }
    vim.keymap.set("t", "<M-/>", [[<cmd>lua vim.cmd('stopinsert')<CR>]], bufopts)
    vim.keymap.set("t", "<M-h>", [[<cmd>wincmd h<CR>]], bufopts)
    vim.keymap.set("t", "<M-j>", [[<cmd>wincmd j<CR>]], bufopts)
    vim.keymap.set("t", "<M-k>", [[<cmd>wincmd k<CR>]], bufopts)
    vim.keymap.set("t", "<M-l>", [[<cmd>wincmd l<CR>]], bufopts)
    vim.opt_local.relativenumber = false
    vim.opt_local.number = false
  end,
  group = term_open_group,
})

for i = 1, 3 do
  local keymap = string.format("<M-%s>", i)
  local normal_action = string.format([[<cmd>lua require('toggleterm').toggle(%s)<CR>]], i)
  local term_action = [[<Cmd>lua vim.cmd('stopinsert')<CR>]] .. normal_action
  vim.keymap.set("n", keymap, normal_action, opts)
  vim.keymap.set("t", keymap, term_action, opts)
end

