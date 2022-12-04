local M = {}

M.map = function (mode, l, r, desc, opts)
  opts = opts or {}
  opts.desc = desc
  vim.keymap.set(mode, l, r, opts)
end

return M
