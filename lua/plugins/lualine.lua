return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'catppuccin',
        disabled_filetypes = { 'oil', 'statusline', 'winbar', 'DiffviewFiles', 'qf' },
      },
      sections = {
        lualine_c = {
          {
            'filename',
            path = 1,
            fmt = function(str)
              local parent_dir = vim.fn.fnamemodify(str, ':h:t')
              local filename = vim.fn.fnamemodify(str, ':t')
              return parent_dir .. '/' .. filename
            end,
          },
        },
        lualine_x = {
          {
            require('noice').api.status.mode.get,
            cond = require('noice').api.status.mode.has,
            color = { fg = '#ff9e64' },
          },
        },
      },
      inactive_sections = {
        lualine_c = {
          {
            'filename',
            path = 1,
            fmt = function(str)
              local parent_dir = vim.fn.fnamemodify(str, ':h:t')
              local filename = vim.fn.fnamemodify(str, ':t')
              return parent_dir .. '/' .. filename
            end,
          },
        },
      },
    },
  },
}
