local has_gitsigns, gitsigns = pcall(require, "gitsigns")

if has_gitsigns then
  gitsigns.setup({
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns
      local function bufmap(mode, l, r, desc, opts)
        opts = opts or {}
        opts.desc = desc
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Navigation
      bufmap("n", "]c", function()
        if vim.wo.diff then
          return "]c"
        end
        vim.schedule(function()
          gs.next_hunk()
        end)
        return "<Ignore>"
      end, "Next change", { expr = true })

      bufmap("n", "[c", function()
        if vim.wo.diff then
          return "[c"
        end
        vim.schedule(function()
          gs.prev_hunk()
        end)
        return "<Ignore>"
      end, "Next change", { expr = true })

      -- Actions
      bufmap({ "n", "v" }, "<space>hs", ":Gitsigns stage_hunk<CR>", "Stage hunk")
      bufmap({ "n", "v" }, "<space>hr", ":Gitsigns reset_hunk<CR>", "Reset hunk")
      bufmap("n", "<space>hS", gs.stage_buffer, "Stage buffer")
      bufmap("n", "<space>hu", gs.undo_stage_hunk, "Unstage hunk")
      bufmap("n", "<space>hR", gs.reset_buffer, "Reset buffer")
      bufmap("n", "<space>hp", gs.preview_hunk, "Preview hunk")
      bufmap("n", "<space>hb", function()
        gs.blame_line({ full = true })
      end, "Git blame")
      bufmap("n", "<space>hB", gs.toggle_current_line_blame, "Toggle line blame")
      bufmap("n", "<space>hd", gs.diffthis, "Diff HEAD")
      bufmap("n", "<space>hD", function()
        gs.diffthis("~")
      end, "Diff HEAD~1")
      bufmap("n", "<space>hg", gs.toggle_deleted, "Ghost deleted")

      -- Text object
      bufmap({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
    end,
  })
end
