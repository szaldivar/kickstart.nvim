local function lsp_action_on_side(action, side)
  local curr_buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  vim.cmd('wincmd ' .. side)
  vim.api.nvim_set_current_buf(curr_buf)
  vim.api.nvim_win_set_cursor(0, cursor)
  action()
end

return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    config = function()
      local snacks = require 'snacks'
      local wk = require 'which-key'

      wk.add {
        { '<leader>b', group = 'Buffers' },
        { '<leader>s', group = 'Search' },
        { '<leader>d', group = 'Document' },
        { '<leader>w', group = 'Workspace' },
        { '<leader>gs', group = 'Go to on side (Right)' },
        { '<leader>gS', group = 'Go to on side (Left)' },
        { '<leader>o', group = 'Open' },
        { '<leader>og', group = 'Git' },
      }

      vim.keymap.set('n', '<leader>bd', function() snacks.bufdelete() end, { desc = '[B]uffer [D]elete' })
      vim.keymap.set('n', '<leader>ba', function() snacks.bufdelete.all() end, { desc = '[B]uffer delete [A]ll' })

      vim.keymap.set({ 'n', 'v' }, '<leader>ogh', function()
        snacks.gitbrowse.open {
          open = function(url)
            vim.notify('Copied url to clipboard', 'info')
            vim.fn.setreg('+', url)
          end,
          notify = false,
        }
      end, { desc = 'Copy git url' })

      snacks.setup {
        picker = { formatters = { file = { truncate = 200 } } },
        input = {},
        notifier = {},
        gitbrowse = {},
      }
    end,
    keys = {
      { '<leader><space>', function() Snacks.picker.buffers { layout = 'vscode' } end, desc = 'Buffers' },
      { '<leader>/', function() Snacks.picker.grep() end, desc = 'Grep' },
      { '<leader>:', function() Snacks.picker.command_history() end, desc = 'Command History' },
      { '<leader>n', function() Snacks.picker.notifications() end, desc = 'Notification History' },
      { '<leader>sf', function() Snacks.picker.files { layout = 'vscode' } end, desc = 'Find Files' },
      { '<leader>s.', function() Snacks.picker.recent { layout = 'vscode' } end, desc = 'Recent' },
      { '<leader>/', function() Snacks.picker.lines() end, desc = 'Buffer Lines' },
      { '<leader>s/', function() Snacks.picker.grep_buffers() end, desc = 'Grep Open Buffers' },
      { '<leader>sg', function() Snacks.picker.grep() end, desc = 'Grep' },
      { '<leader>sd', function() Snacks.picker.diagnostics() end, desc = 'Diagnostics' },
      { '<leader>sD', function() Snacks.picker.diagnostics_buffer() end, desc = 'Buffer Diagnostics' },
      { '<leader>sh', function() Snacks.picker.help() end, desc = 'Help Pages' },
      { '<leader>sj', function() Snacks.picker.jumps() end, desc = 'Jumps' },
      { '<leader>sk', function() Snacks.picker.keymaps() end, desc = 'Keymaps' },
      { '<leader>sl', function() Snacks.picker.loclist() end, desc = 'Location List' },
      { '<leader>sm', function() Snacks.picker.marks() end, desc = 'Marks' },
      { '<leader>sq', function() Snacks.picker.qflist() end, desc = 'Quickfix List' },
      { '<leader>sr', function() Snacks.picker.resume() end, desc = 'Resume' },
      -- LSP
      { 'gd', function() Snacks.picker.lsp_definitions() end, desc = 'Goto Definition' },
      { 'gsd', function() lsp_action_on_side(Snacks.picker.lsp_definitions, 'l') end, desc = 'Goto Definition in Side Right' },
      { 'gSd', function() lsp_action_on_side(Snacks.picker.lsp_definitions, 'h') end, desc = 'Goto Definition in Side Left' },
      { 'gD', function() Snacks.picker.lsp_declarations() end, desc = 'Goto Declaration' },
      { 'gr', function() Snacks.picker.lsp_references() end, nowait = true, desc = 'References' },
      { 'gI', function() Snacks.picker.lsp_implementations() end, desc = 'Goto Implementation' },
      { 'gy', function() Snacks.picker.lsp_type_definitions() end, desc = 'Goto T[y]pe Definition' },
      { '<leader>ds', function() Snacks.picker.lsp_symbols() end, desc = 'LSP Symbols' },
      { '<leader>ws', function() Snacks.picker.lsp_workspace_symbols() end, desc = 'LSP Workspace Symbols' },
    },
  },
}
