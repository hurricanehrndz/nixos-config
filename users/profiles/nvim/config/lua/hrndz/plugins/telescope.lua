local telescope = require("telescope")
telescope.load_extension("fzf")
-- search for current word under cursor
vim.keymap.set("n", "<space>fw", function()
  return require("telescope.builtin").grep_string({ search = vim.fn.expand("<cword>") })
end)
vim.keymap.set("n", "<space>fs", require("telescope.builtin").grep_string)
vim.keymap.set("n", "<space>fg", require("telescope.builtin").live_grep)
vim.keymap.set("n", "<C-p>", require("telescope.builtin").git_files)
vim.keymap.set("n", "<space>ff", require("telescope.builtin").find_files)
-- buffer finder
vim.keymap.set("n", "<space>fb", require("telescope.builtin").buffers)
-- help finder
vim.keymap.set("n", "<space>fh", require("telescope.builtin").help_tags)
