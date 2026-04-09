-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree toggle reveal<CR>', desc = 'NeoTree toggle', silent = true },
  },
  opts = {
    event_handlers = {
      {
        event = 'file_opened',
        handler = function()
          vim.cmd 'Neotree close'
        end,
      },
    },
    filesystem = {
      window = {
        mappings = {
          ['\\'] = 'close_window',
          ['Y'] = function(state)
            local node = state.tree:get_node()
            local relative_path = vim.fn.fnamemodify(node.path, ':.')
            vim.fn.setreg('+', relative_path)
            vim.notify('Copied: ' .. relative_path)
          end,
          ['gY'] = function(state)
            local node = state.tree:get_node()
            local filename = vim.fn.fnamemodify(node.path, ':t')
            vim.fn.setreg('+', filename)
            vim.notify('Copied: ' .. filename)
          end,
          ['O'] = function(state)
            local node = state.tree:get_node()
            if node.type ~= 'directory' then
              vim.fn.system({ 'open', node.path })
            end
          end,
        },
      },
    },
  },
}
