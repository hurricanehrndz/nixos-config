local telescope = require("telescope")
telescope.load_extension("fzf")
telescope.load_extension("file_browser")

-- override built-in filetypes
local plenary_ft = require("plenary.filetype")
plenary_ft.add_file("defs")

local ts_builtin = require("telescope.builtin")
telescope.setup({
  extensions = {
    file_browser = {
      initial_mode = "normal",
      layout_strategy = "horizontal",
      sorting_strategy = "ascending",
      layout_config = {
        mirror = false,
        height = 0.9,
        prompt_position = "top",
        preview_cutoff = 120,
        width = 0.9,
        preview_width = 0.55,
      },
    },
  },
  defaults = {
    prompt_prefix = "  ",
    selection_caret = " ",
    layout_config = {
      preview_cutoff = 40,
      width = 0.95,
      height = 0.95,
      preview_width = 0.6,
      prompt_position = "top",
    },
    border = true,
    sorting_strategy = "ascending",
    path_display = {
      truncate = 3
    },
  },
})


local find_files = function()
  ts_builtin.find_files()
end

local find_buffers = function()
  ts_builtin.buffers()
end

local file_browser = function()
  ---@diagnostic disable-next-line: param-type-mismatch
  telescope.extensions.file_browser.file_browser({ path = vim.fn.expand("%:p:h", false, false) })
end

local map = require("hrndz.utils").map
map("n", "<space>fw", "<Cmd>Telescope grep_string<CR>", "Find word")
map("n", "<space>fg", "<Cmd>Telescope live_grep<CR>", "Live grep")
map("n", "<space>ff", find_files, "Find files")
map("n", "<space>fp", "<Cmd>Telescope git_files<CR>", "Git files")
map("n", "<space>fh", "<cmd>Telescope help_tags<CR>", "Help")
map("n", "<space>fn", "<cmd>Telescope notify<CR>", "Notifications")
map("n", "<space>fb", find_buffers, "Find buffers")
map("n", "<space>fr", "<cmd>Telescope oldfiles<cr>", "Recent files")
map("n", "<space>f'", "<cmd>Telescope registers<cr>", "Registers")
map("n", "<space>fe", file_browser, "Open explorer")
map("n", "<space>fc", "<cmd>Telescope commands<cr>", "Commands")
