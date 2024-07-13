return {
  {
    'rebelot/kanagawa.nvim',
    priority = 1000,
    init = function()
      vim.cmd.colorscheme 'kanagawa-wave'
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
  -- git stuff
  { 'tpope/vim-fugitive' },
  { 'sindrets/diffview.nvim' },
  -- database stuff
  { 'tpope/vim-dadbod' },
  { 'kristijanhusak/vim-dadbod-ui' },
  { 'kristijanhusak/vim-dadbod-completion' },
}
