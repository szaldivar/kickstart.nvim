return {
  {
    'sindrets/diffview.nvim',
    config = function()
      require('diffview').setup {
        use_icons = true,
        file_panel = {
          win_config = {
            width = 50,
          },
        },
        keymaps = {
          view = {
            {
              'n',
              '<leader>gc',
              function()
                vim.cmd 'tabclose'
              end,
              { desc = 'close diffview tab' },
            },
            {
              'n',
              '<C-p>',
              require('diffview.actions').prev_conflict,
              { desc = 'Jump to previous conflict' },
            },
            {
              'n',
              '<C-n>',
              require('diffview.actions').next_conflict,
              { desc = 'Jump to next conflict' },
            },
          },
          file_panel = {
            {
              'n',
              '<leader>gc',
              function()
                vim.cmd 'tabclose'
              end,
              { desc = 'close diffview tab' },
            },
          },
        },
      }

      local wk = require 'which-key'
      wk.add { '<leader>g', group = 'Git' }
      wk.add { '<leader>gf', group = 'File' }

      vim.keymap.set('n', '<leader>go', function()
        vim.cmd 'DiffviewOpen'
      end, { desc = 'Open diff' })

      vim.keymap.set('n', '<leader>gh', function()
        vim.cmd 'DiffviewFileHistory'
      end, { desc = 'Open history' })

      vim.keymap.set('n', '<leader>gfh', function()
        vim.cmd 'DiffviewFileHistory %'
      end, { desc = 'Open history' })

      local function open_diff_from_blame()
        local lnum = vim.api.nvim_win_get_cursor(0)[1]
        local filename = vim.fn.expand '%:p'
        local blame_output = vim.fn.system('git blame -L ' .. lnum .. ',' .. lnum .. ' --porcelain ' .. filename)
        local commit_hash = blame_output:match '^(%w+)'
        if not commit_hash then
          vim.notify('Could not retrieve commit hash for current line', 'warn')
          return
        end
        vim.cmd('DiffviewOpen ' .. commit_hash .. '^!')
      end

      vim.keymap.set('n', '<leader>gb', open_diff_from_blame, { desc = 'Open current line blame diff', noremap = true })
    end,
  },
}
