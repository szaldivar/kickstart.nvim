return {
  {
    'mfussenegger/nvim-dap',
    config = function()
      local dap = require 'dap'

      local wk = require 'which-key'
      wk.add { { '<leader>d', group = 'Debug' } }

      ---@param key string
      local function map(key, fn, description)
        local mapping = '<leader>d' .. key
        vim.keymap.set('n', mapping, fn, { desc = description })
      end

      map('c', dap.continue, 'Continue')
      map('r', dap.restart, 'Restart')
      map('t', dap.terminate, 'Terminate')
      map('b', dap.toggle_breakpoint, 'Toggle breakpoint')
      map('B', dap.set_breakpoint, 'Set breakpoint')
      map('l', dap.list_breakpoints, 'List breakpoints')
      map('C', dap.clear_breakpoints, 'Clear all breakpoints')
      map('v', dap.step_over, 'Step over')
      map('i', dap.step_into, 'Step into')
      map('o', dap.step_out, 'Step out')
      map('p', dap.pause, 'Pause')
      map('k', dap.run_to_cursor, 'Run to cursor')

      if vim.g.sz_nvim_is_work then
        local cpp_debug_path = os.getenv 'NVIM_SZ_CPP_DAP'
        dap.adapters.cppdbg = {
          id = 'cppdbg',
          type = 'executable',
          command = cpp_debug_path,
        }
      end
    end,
  },
  {
    'rcarriga/nvim-dap-ui',
    dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'
      dapui.setup {
        controls = {
          element = 'repl',
          enabled = true,
        },
      }

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      vim.keymap.set('n', '<leader>de', dapui.eval, { desc = 'Evaluate under cursor' })
    end,
  },
}
