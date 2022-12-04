local api = vim.api
local map = require("hrndz.utils").map

local opts = { noremap = true }
-- Ctrl+[hjkl] navigate cursor in insert or command mode
map("i", "<C-h>", "<Left>", "", opts)
map("i", "<C-j>", "<Down>", "", opts)
map("i", "<C-k>", "<Up>", "", opts)
map("i", "<C-l>", "<Right>", "", opts)
-- Command mode navigation
map("c", "<C-h>", "<Left>", "", opts)
map("c", "<C-j>", "<Down>", "", opts)
map("c", "<C-k>", "<Up>", "", opts)
map("c", "<C-l>", "<Right>", "", opts)

-- tmux navigator
vim.g.tmux_navigator_no_mappings = 1
-- Alt+[hjkl] navigate windows
map("n", "<A-h>", [[<cmd>TmuxNavigateLeft<CR>]], "", opts)
map("n", "<A-j>", [[<cmd>TmuxNavigateDown<CR>]], "", opts)
map("n", "<A-k>", [[<cmd>TmuxNavigateUp<CR>]], "", opts)
map("n", "<A-l>", [[<cmd>TmuxNavigateRight<CR>]], "", opts)
-- Alt+[hjkl] navigate windows from terminal
map("t", "<A-h>", [[<cmd>TmuxNavigateLeft<CR>]], "", opts)
map("t", "<A-j>", [[<cmd>TmuxNavigateDown<CR>]], "", opts)
map("t", "<A-k>", [[<cmd>TmuxNavigateUp<CR>]], "", opts)
map("t", "<A-l>", [[<cmd>TmuxNavigateRight<CR>]], "", opts)

-- helper functions
local qf_list_toggle = function()
  local qf_exists = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win["quickfix"] == 1 then
      qf_exists = true
    end
  end
  if qf_exists == true then
    vim.cmd("cclose")
    return
  end
  if not vim.tbl_isempty(vim.fn.getqflist()) then
    vim.cmd("copen")
  end
end

local qf_list_clear = function()
  vim.fn.setqflist({})
end

local trim_whitespace = function()
  require("mini.trailspace").trim()
end

-- osc52 copy
local has_osc52, osc52 = pcall(require, "osc52")
if has_osc52 then
  local function copy(lines, _)
    osc52.copy(table.concat(lines, "\n"))
  end

  local function paste()
    return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
  end

  vim.g.clipboard = {
    name = "osc52",
    copy = { ["+"] = copy, ["*"] = copy },
    paste = { ["+"] = paste, ["*"] = paste },
  }
end

map("n", ",q", qf_list_toggle, "Quickfix toggle")
map("n", ",Q", qf_list_clear, "Quickfix clear")
map("n", ",s", "<Cmd>update<CR>", "Save changes")
map("n", ",l", "<Cmd>nohlsearch<CR>", "No search hl")
map("n", ",u", "<Cmd>UndotreeToggle<CR>", "Undotree")
map("n", ",w", trim_whitespace, "Trim whitespace")
map({"n", "v"}, ",y", [["+y]], "Copy to clipboard")
map("n", ",Y", [["+Y]], "Copy line to clipboard")
map("n", ",fl", "<cmd>NvimTreeFindFileToggle<CR>", "Nvim Tree")
map("n", ",dt", "<cmd>DiffviewToggleFiles<CR>", "Toggle file tree")
map("n", ",do", "<cmd>DiffviewOpen<CR>", "Open")
map("n", ",dx", "<cmd>DiffviewClose<CR>", "Close")
map("n", ",dr", "<cmd>DiffviewRefresh<CR>", "Refresh")

