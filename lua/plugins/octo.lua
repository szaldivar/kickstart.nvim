return {
  {
    'pwntester/octo.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'folke/snacks.nvim',
    },
    config = function()
      local octo = require 'octo'

      local gh_env = nil
      if vim.g.sz_nvim_is_work then gh_env = {
        HTTPS_PROXY = vim.g.sz_nvim_http_proxy,
      } end

      octo.setup {
        use_local_fs = true,
        file_panel = {
          size = 10,
          use_icons = true,
        },
        picker = 'snacks',
        gh_env = gh_env,
        mappings = {
          pull_request = {
            add_comment = { lhs = '<leader>oca', desc = 'add comment' },
            delete_comment = { lhs = '<leader>ocd', desc = 'delete comment' },
          },
          review_thread = {
            add_comment = { lhs = '<leader>oca', desc = 'add comment' },
            delete_comment = { lhs = '<leader>ocd', desc = 'delete comment' },
          },
          review_diff = {
            add_review_comment = { lhs = '<leader>oca', desc = 'add comment' },
            add_review_suggestion = { lhs = '<leader>oca', desc = 'add suggestion' },
            select_next_entry = { lhs = '<tab>', desc = 'move to next changed file' },
            select_prev_entry = { lhs = '<s-tab>', desc = 'move to previous changed file' },
          },
          submit_win = {
            approve_review = { lhs = '<leader>osa', desc = 'approve review', mode = { 'n', 'i' } },
            comment_review = { lhs = '<leader>osc', desc = 'comment review', mode = { 'n', 'i' } },
            request_changes = { lhs = '<leader>osr', desc = 'request changes review', mode = { 'n', 'i' } },
            close_review_tab = { lhs = '<leader>osC', desc = 'close review tab', mode = { 'n', 'i' } },
          },
        },
        suppress_missing_scope = { projects_v2 = true },
      }
    end,
  },
}
