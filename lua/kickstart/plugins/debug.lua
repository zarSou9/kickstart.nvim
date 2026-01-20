-- debug.lua
--
-- Configures nvim-dap for debugging Python and other languages.

return {
  'mfussenegger/nvim-dap',
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Python debugger
    'mfussenegger/nvim-dap-python',

    -- Inline variable values
    'theHamsta/nvim-dap-virtual-text',
  },
  keys = {
    -- Basic debugging keymaps
    { '<F5>', function() require('dap').continue() end, desc = 'Debug: Start/Continue' },
    { '<F1>', function() require('dap').step_into() end, desc = 'Debug: Step Into' },
    { '<F2>', function() require('dap').step_over() end, desc = 'Debug: Step Over' },
    { '<F3>', function() require('dap').step_out() end, desc = 'Debug: Step Out' },
    { '<F7>', function() require('dapui').toggle() end, desc = 'Debug: Toggle UI' },

    -- Leader keybindings for debugging
    { '<leader>b', function() require('dap').toggle_breakpoint() end, desc = 'Debug: Toggle [B]reakpoint' },
    { '<leader>B', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, desc = 'Debug: Conditional [B]reakpoint' },
    { '<leader>dc', function() require('dap').continue() end, desc = '[D]ebug: [C]ontinue' },
    { '<leader>di', function() require('dap').step_into() end, desc = '[D]ebug: Step [I]nto' },
    { '<leader>do', function() require('dap').step_over() end, desc = '[D]ebug: Step [O]ver' },
    { '<leader>dO', function() require('dap').step_out() end, desc = '[D]ebug: Step [O]ut' },
    { '<leader>dr', function() require('dap').repl.open() end, desc = '[D]ebug: Open [R]EPL' },
    { '<leader>dl', function() require('dap').run_last() end, desc = '[D]ebug: Run [L]ast' },
    { '<leader>du', function() require('dapui').toggle() end, desc = '[D]ebug: Toggle [U]I' },
    { '<leader>dt', function() require('dap').terminate() end, desc = '[D]ebug: [T]erminate' },
    { '<leader>dx', function() require('dap').clear_breakpoints() end, desc = '[D]ebug: Clear all breakpoints' },

    -- Attach to remote debugger (debugpy)
    {
      '<leader>da',
      function()
        local host = vim.fn.input('Host [127.0.0.1]: ', '127.0.0.1')
        if host == '' then
          host = '127.0.0.1'
        end
        local port = tonumber(vim.fn.input('Port [5678]: ', '5678'))
        if not port then
          port = 5678
        end

        require('dap').run {
          type = 'python',
          request = 'attach',
          connect = {
            host = host,
            port = port,
          },
          mode = 'remote',
          name = 'Attach to debugpy',
          cwd = vim.fn.getcwd(),
          pathMappings = {
            {
              localRoot = vim.fn.getcwd(),
              remoteRoot = '.',
            },
          },
        }
      end,
      desc = '[D]ebug: [A]ttach to remote server',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      handlers = {},
      ensure_installed = {
        'debugpy', -- Python debugger
      },
    }

    -- Dap UI setup
    dapui.setup {
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- Breakpoint icons
    vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DiagnosticError', linehl = '', numhl = '' })
    vim.fn.sign_define('DapBreakpointCondition', { text = '◐', texthl = 'DiagnosticWarn', linehl = '', numhl = '' })
    vim.fn.sign_define('DapLogPoint', { text = '◆', texthl = 'DiagnosticInfo', linehl = '', numhl = '' })
    vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DiagnosticOk', linehl = 'CursorLine', numhl = '' })
    vim.fn.sign_define('DapBreakpointRejected', { text = '○', texthl = 'DiagnosticError', linehl = '', numhl = '' })

    -- Inline virtual text for variables
    require('nvim-dap-virtual-text').setup {
      commented = true, -- prefix with comment string
    }

    -- Auto open/close dapui
    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Python debugger setup
    local debugpy_path = vim.fn.stdpath 'data' .. '/mason/packages/debugpy/venv/bin/python'
    require('dap-python').setup(debugpy_path)

    -- Python configurations
    dap.configurations.python = {
      {
        type = 'python',
        request = 'launch',
        name = 'Launch file',
        program = '${file}',
        pythonPath = function()
          -- Use activated virtualenv or fall back to system python
          local venv = os.getenv 'VIRTUAL_ENV'
          if venv then
            return venv .. '/bin/python'
          end
          return '/usr/bin/python3'
        end,
      },
      {
        type = 'python',
        request = 'launch',
        name = 'Launch file with arguments',
        program = '${file}',
        args = function()
          local args_string = vim.fn.input 'Arguments: '
          return vim.split(args_string, ' ')
        end,
        pythonPath = function()
          local venv = os.getenv 'VIRTUAL_ENV'
          if venv then
            return venv .. '/bin/python'
          end
          return '/usr/bin/python3'
        end,
      },
      {
        type = 'python',
        request = 'attach',
        name = 'Attach to debugpy (localhost:5678)',
        connect = {
          host = '127.0.0.1',
          port = 5678,
        },
        mode = 'remote',
        cwd = vim.fn.getcwd(),
        pathMappings = {
          {
            localRoot = vim.fn.getcwd(),
            remoteRoot = '.',
          },
        },
      },
    }
  end,
}
