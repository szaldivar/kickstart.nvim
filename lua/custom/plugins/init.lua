return {
  {
    'rebelot/kanagawa.nvim',
    priority = 1000,
    init = function()
      -- vim.cmd.colorscheme 'kanagawa-wave'
    end,
  },
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = {},
    init = function()
      vim.cmd.colorscheme 'tokyonight'
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
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require 'harpoon'
      -- REQUIRED
      harpoon:setup()
      -- REQUIRED
      vim.keymap.set('n', '<leader>p', function()
        harpoon:list():add()
      end)
      vim.keymap.set('n', '<C-q>', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end)

      vim.keymap.set('n', '<leader>j', function()
        harpoon:list():select(1)
      end)
      vim.keymap.set('n', '<leader>k', function()
        harpoon:list():select(2)
      end)
      vim.keymap.set('n', '<leader>l', function()
        harpoon:list():select(3)
      end)
      vim.keymap.set('n', '<leader>;', function()
        harpoon:list():select(4)
      end)
    end,
  },
  {
    'ggandor/leap.nvim',
    config = function()
      vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap-forward)')
      vim.keymap.set({ 'n', 'x', 'o' }, 'S', '<Plug>(leap-backward)')
      vim.keymap.set({ 'n', 'x', 'o' }, 'gl', '<Plug>(leap-from-window)')
    end,
  },
}
