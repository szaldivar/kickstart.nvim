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
  {
    'sindrets/diffview.nvim',
    init = function()
      vim.keymap.set('n', '<leader>go', function()
        vim.cmd 'DiffviewOpen'
      end)
    end,
  },
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
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      'MunifTanjim/nui.nvim',
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      'rcarriga/nvim-notify',
    },
    config = function()
      require('noice').setup {
        lsp = {
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
          },
        },
        -- you can enable a preset for easier configuration
        presets = {
          bottom_search = false,
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = true, -- add a border to hover docs and signature help
        },
      }
    end,
  },
  {
    'stevearc/oil.nvim',
    config = function()
      local detail = false
      require('oil').setup {
        keymaps = {
          ['<C-h>'] = false,
          ['<C-l>'] = false,
          ['gd'] = {
            desc = 'Toggle file detail view',
            callback = function()
              detail = not detail
              if detail then
                require('oil').set_columns { 'icon', 'permissions', 'size', 'mtime' }
              else
                require('oil').set_columns { 'icon' }
              end
            end,
          },
        },
        win_options = {
          winbar = '%!v:lua.get_oil_winbar()',
        },
      }

      vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
    end,
    -- Optional dependencies
    dependencies = { { 'echasnovski/mini.icons', opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
  },
}
