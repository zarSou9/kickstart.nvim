-- Quick-insert snippet keymaps (<leader>i prefix)
--
-- Filetype-aware print/log wrappers:
--   Normal mode: inserts print(...) and places cursor inside parens
--   Visual mode: wraps selection in print(...)
--
-- To add more snippets, add entries to the `snippets` table below.

-- Map of filetype → { fn = "function_name", open = "(", close = ")" }
-- Add new filetypes here as needed.
local print_fns = {
  python = 'print',
  javascript = 'console.log',
  typescript = 'console.log',
  javascriptreact = 'console.log',
  typescriptreact = 'console.log',
  lua = 'print',
  rust = 'println!',
  go = 'fmt.Println',
  ruby = 'puts',
  java = 'System.out.println',
}

local function get_print_fn()
  local ft = vim.bo.filetype
  return print_fns[ft] or 'print'
end

-- Each snippet: { key, desc, normal_fn, visual_fn }
local snippets = {
  {
    key = 'p',
    desc = 'Insert print/log',
    normal = function()
      local fn = get_print_fn()
      local text = fn .. '()'
      vim.api.nvim_put({ text }, 'c', false, false)
      -- Place cursor inside the parens (on the closing paren)
      local pos = vim.api.nvim_win_get_cursor(0)
      vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] + #fn })
    end,
    visual = function()
      local fn = get_print_fn()
      local mode = vim.fn.visualmode()
      -- Yank selection into register z
      vim.cmd 'normal! "zy'
      local text = vim.fn.getreg 'z'
      if mode == 'V' then
        -- Linewise: preserve leading indent, wrap just the content
        text = text:gsub('\n$', '')
        local indent, content = text:match '^(%s*)(.*)'
        vim.fn.setreg('z', indent .. fn .. '(' .. content .. ')\n', 'l')
      else
        -- Characterwise: wrap directly
        vim.fn.setreg('z', fn .. '(' .. text .. ')', 'c')
      end
      -- Reselect and paste over the selection
      vim.cmd 'normal! gv"zp'
    end,
  },
}

return {
  -- No actual plugin to install; just a container for keymaps
  dir = vim.fn.stdpath 'config',
  name = 'custom-snippets',
  lazy = false,
  config = function()
    for _, s in ipairs(snippets) do
      vim.keymap.set('n', '<leader>i' .. s.key, s.normal, { desc = '[I]nsert: ' .. s.desc })
      vim.keymap.set('x', '<leader>i' .. s.key, s.visual, { desc = '[I]nsert: ' .. s.desc .. ' (wrap)' })
    end
  end,
}
