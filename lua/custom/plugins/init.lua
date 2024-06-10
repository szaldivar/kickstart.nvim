return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    init = function()
      vim.cmd.colorscheme 'catppuccin-mocha'
      -- You can configure highlights by doing something like:
      vim.cmd.hi 'Comment gui=none'
    end,
  },
  {
    'almo7aya/openingh.nvim',
    init = function()
      vim.g.openingh_copy_to_register = true
      vim.keymap.set('n', '<leader>ogh', function()
        vim.cmd 'OpenInGHFile+'
      end, { desc = 'Copy [O]pen on [G]it[H]ub url' })
      vim.keymap.set('v', '<leader>ogh', ':OpenInGHFileLines+<CR>', { desc = 'Copy [O]pen on [G]it[H]ub url' })
    end,
  },
  { 'tpope/vim-fugitive' },
}
