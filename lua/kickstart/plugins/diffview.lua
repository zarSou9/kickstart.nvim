-- diffview.nvim: Single tabpage interface for cycling through diffs
-- See :h diffview for more info

return {
  'sindrets/diffview.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local actions = require 'diffview.actions'

    require('diffview').setup {
      enhanced_diff_hl = true, -- Better diff highlighting
      use_icons = vim.g.have_nerd_font,
      view = {
        default = {
          layout = 'diff2_horizontal',
        },
        merge_tool = {
          layout = 'diff3_horizontal',
        },
        file_history = {
          layout = 'diff2_horizontal',
        },
      },
      file_panel = {
        listing_style = 'tree',
        tree_options = {
          flatten_dirs = true,
        },
        win_config = {
          position = 'left',
          width = 35,
        },
      },
      keymaps = {
        view = {
          -- Add 'q' to close the diffview easily
          { 'n', 'q', '<Cmd>DiffviewClose<CR>', { desc = 'Close diffview' } },
        },
        file_panel = {
          -- Add 'q' to close the diffview from file panel too
          { 'n', 'q', '<Cmd>DiffviewClose<CR>', { desc = 'Close diffview' } },
        },
      },
    }

    -- Convenient keymaps for opening diffview
    vim.keymap.set('n', '<leader>gd', '<Cmd>DiffviewOpen<CR>', { desc = '[G]it [D]iff view' })
    vim.keymap.set('n', '<leader>gh', '<Cmd>DiffviewFileHistory %<CR>', { desc = '[G]it [H]istory (current file)' })
    vim.keymap.set('n', '<leader>gH', '<Cmd>DiffviewFileHistory<CR>', { desc = '[G]it [H]istory (all files)' })
  end,
}
