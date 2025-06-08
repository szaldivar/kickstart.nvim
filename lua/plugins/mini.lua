return {
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup {
        mappings = {
          add = 'ra', -- Add surrounding in Normal and Visual modes
          delete = 'rd', -- Delete surrounding
          find = 'rf', -- Find surrounding (to the right)
          find_left = 'rF', -- Find surrounding (to the left)
          highlight = 'rh', -- Highlight surrounding
          replace = 'rr', -- Replace surrounding
          update_n_lines = 'rn', -- Update `n_lines`

          suffix_last = 'l', -- Suffix to search with "prev" method
          suffix_next = 'n', -- Suffix to search with "next" method
        },
      }
      require('mini.sessions').setup {
        autoread = true,
        file = 'Session.vim',
        directory = '',
      }
      require('mini.icons').setup {}
      MiniIcons.mock_nvim_web_devicons()
    end,
  },
}
