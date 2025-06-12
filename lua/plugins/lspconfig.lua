return {
  {
    'neovim/nvim-lspconfig',
    config = function()
      vim.lsp.enable 'lua_ls'

      if vim.g.sz_nvim_is_work then
        local cwd = vim.fn.getcwd()
        vim.lsp.config('clangd', {
          cmd = {
            'clangd',
            '-j=14',
            '--compile-commands-dir=' .. cwd .. '/build/debug/cmake/',
            '--background-index',
            '--header-insertion=never',
            '--clang-tidy',
            '--pretty',
          },
        })
        vim.lsp.enable 'clangd'

        vim.lsp.config('pyright', {
          settings = {
            python = {
              pythonPath = cwd .. '/.venv/bin/python',
            },
          },
        })
        vim.lsp.enable 'pyright'
      end

      local function lsp_action_on_side(action, side)
        return function()
          local curr_buf = vim.api.nvim_get_current_buf()
          local cursor = vim.api.nvim_win_get_cursor(0)
          vim.cmd('wincmd ' .. side)
          vim.api.nvim_set_current_buf(curr_buf)
          vim.api.nvim_win_set_cursor(0, cursor)
          action()
        end
      end

      local picker = require 'snacks.picker'

      vim.keymap.set('n', 'gsy', lsp_action_on_side(picker.lsp_type_definitions, 'l'), { desc = 'Goto Type in Side Right' })
      vim.keymap.set('n', 'gSy', lsp_action_on_side(picker.lsp_type_definitions, 'h'), { desc = 'Goto Type in Side Left' })
      vim.keymap.set('n', 'gsr', lsp_action_on_side(picker.lsp_references, 'l'), { desc = 'Goto aeferences in side Right' })
      vim.keymap.set('n', 'gSr', lsp_action_on_side(picker.lsp_references, 'h'), { desc = 'Goto References in Side Left' })
      vim.keymap.set('n', 'gsI', lsp_action_on_side(picker.lsp_implementations, 'l'), { desc = 'Goto Implementation in Side Right' })
      vim.keymap.set('n', 'gSI', lsp_action_on_side(picker.lsp_implementations, 'h'), { desc = 'Goto Implementation in Side Left' })
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = '[R]e[n]ame' })
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = '[C]ode [A]ction' })

      local wk = require 'which-key'
      wk.add { { '<leader>r', group = 'Run/Rename' } }
      wk.add { { '<leader>t', group = 'Toggle' } }

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- don't do semantic highlights for string so our injections work
          -- (aka highlight SQL inside sqlx queries)
          if vim.bo.filetype == 'rust' then vim.api.nvim_set_hl(0, '@lsp.type.string', {}) end

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          local map = function(keys, func, desc) vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc }) end

          -- The following autocommand is used to enable inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, '[T]oggle Inlay [H]ints')
          end
        end,
      })
    end,
  },
}
