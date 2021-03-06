require("toggleterm").setup({
  open_mapping = [[<c-\>]],
  hide_numbers = true,
  direction = 'float',
})

vim.env.GIT_EDITOR = "nvr --remote-tab-wait +'set bufhidden=wipe'"
vim.env.VISUAL = "nvr --remote-tab-wait +'set bufhidden=wipe'"

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
local term_open_group = vim.api.nvim_create_augroup("HrndzTermOpen",
  { clear = true }
)
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = { "term://*" },
  callback = function()
    local opts = {noremap = true}
    vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[<C-\><C-n>]], opts)
    vim.api.nvim_buf_set_keymap(0, 't', '<M-h>', [[<C-\><C-n><C-W>h]], opts)
    vim.api.nvim_buf_set_keymap(0, 't', '<M-j>', [[<C-\><C-n><C-W>j]], opts)
    vim.api.nvim_buf_set_keymap(0, 't', '<M-k>', [[<C-\><C-n><C-W>k]], opts)
    vim.api.nvim_buf_set_keymap(0, 't', '<M-l>', [[<C-\><C-n><C-W>l]], opts)
  end,
  group = term_open_group,
})

local Terminal = require("toggleterm.terminal").Terminal
local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })

function _LAZYGIT_TOGGLE()
  lazygit:toggle()
end
