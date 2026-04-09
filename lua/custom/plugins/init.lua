-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  -- Search and replace across files
  {
    'nvim-pack/nvim-spectre',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>S', function() require('spectre').toggle() end, desc = '[S]pectre toggle' },
      { '<leader>Sw', function() require('spectre').open_visual { select_word = true } end, desc = '[S]pectre current [w]ord' },
      { '<leader>Sw', function() require('spectre').open_visual() end, mode = 'v', desc = '[S]pectre selection' },
      { '<leader>Sf', function() require('spectre').open_file_search { select_word = true } end, desc = '[S]pectre current [f]ile' },
    },
    opts = {},
  },

  -- Refactoring plugin
  {
    'ThePrimeagen/refactoring.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    lazy = false,
    config = function()
      require('refactoring').setup {}

      -- Refactoring keymaps using <leader>r prefix
      -- Extract operations (visual mode)
      vim.keymap.set('x', '<leader>re', ':Refactor extract ', { desc = '[R]efactor [E]xtract function' })
      vim.keymap.set('x', '<leader>rf', ':Refactor extract_to_file ', { desc = '[R]efactor extract to [F]ile' })
      vim.keymap.set('x', '<leader>rv', ':Refactor extract_var ', { desc = '[R]efactor extract [V]ariable' })

      -- Inline operations
      vim.keymap.set({ 'n', 'x' }, '<leader>ri', ':Refactor inline_var<CR>', { desc = '[R]efactor [I]nline variable' })
      vim.keymap.set('n', '<leader>rI', ':Refactor inline_func<CR>', { desc = '[R]efactor [I]nline function' })

      -- Block extraction (normal mode)
      vim.keymap.set('n', '<leader>rb', ':Refactor extract_block ', { desc = '[R]efactor extract [B]lock' })
      vim.keymap.set('n', '<leader>rB', ':Refactor extract_block_to_file ', { desc = '[R]efactor extract [B]lock to file' })

      -- Select refactor menu
      vim.keymap.set({ 'n', 'x' }, '<leader>rr', function()
        require('refactoring').select_refactor()
      end, { desc = '[R]efactor select [R]efactor' })

      -- Debug operations
      vim.keymap.set('n', '<leader>rp', function()
        require('refactoring').debug.printf { below = false }
      end, { desc = '[R]efactor [P]rintf debug' })

      vim.keymap.set({ 'n', 'x' }, '<leader>rd', function()
        require('refactoring').debug.print_var()
      end, { desc = '[R]efactor print var [D]ebug' })

      vim.keymap.set('n', '<leader>rc', function()
        require('refactoring').debug.cleanup {}
      end, { desc = '[R]efactor [C]leanup debug prints' })

      -- Custom: Convert Python block if-else to inline ternary
      -- Converts:
      --   if condition:
      --       var = value1
      --   else:
      --       var = value2
      -- To:
      --   var = value1 if condition else value2
      vim.keymap.set('n', '<leader>rt', function()
        local bufnr = vim.api.nvim_get_current_buf()
        local ft = vim.bo[bufnr].filetype

        if ft ~= 'python' then
          vim.notify('If-else to ternary only supported for Python', vim.log.levels.WARN)
          return
        end

        local cursor = vim.api.nvim_win_get_cursor(0)
        local start_line = cursor[1] - 1 -- 0-indexed

        -- Get 4 lines starting from cursor
        local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, start_line + 4, false)

        if #lines < 4 then
          vim.notify('Not enough lines for if-else block', vim.log.levels.WARN)
          return
        end

        -- Parse the if-else block
        -- Line 1: if condition:
        local if_match = lines[1]:match '^(%s*)if%s+(.+):%s*$'
        local indent, condition = lines[1]:match '^(%s*)if%s+(.+):%s*$'

        if not condition then
          vim.notify('Cursor must be on an if statement', vim.log.levels.WARN)
          return
        end

        -- Line 2: var = value1 (with more indent)
        local if_indent = indent or ''
        local body_pattern = '^' .. if_indent .. '%s+(.+)%s*=%s*(.+)%s*$'
        local var1, value1 = lines[2]:match(body_pattern)

        if not var1 then
          vim.notify('If body must be a simple assignment', vim.log.levels.WARN)
          return
        end

        -- Line 3: else:
        local else_pattern = '^' .. if_indent .. 'else:%s*$'
        if not lines[3]:match(else_pattern) then
          vim.notify('Expected else: on line 3', vim.log.levels.WARN)
          return
        end

        -- Line 4: var = value2 (same var)
        local var2, value2 = lines[4]:match(body_pattern)

        if not var2 then
          vim.notify('Else body must be a simple assignment', vim.log.levels.WARN)
          return
        end

        -- Check same variable
        if var1 ~= var2 then
          vim.notify('Both branches must assign to the same variable', vim.log.levels.WARN)
          return
        end

        -- Build the ternary expression
        local ternary = if_indent .. var1 .. ' = ' .. value1 .. ' if ' .. condition .. ' else ' .. value2

        -- Replace the 4 lines with 1
        vim.api.nvim_buf_set_lines(bufnr, start_line, start_line + 4, false, { ternary })
        vim.notify('Converted to inline ternary', vim.log.levels.INFO)
      end, { desc = '[R]efactor if-else to [T]ernary' })
    end,
  },
}
