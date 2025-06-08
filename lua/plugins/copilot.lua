return {
  {
    'zbirenbaum/copilot.lua',
    enabled = vim.g.sz_nvim_is_work,
    config = function()
      vim.g.copilot_proxy = vim.g.sz_nvim_http_proxy
      require('copilot').setup {
        suggestion = {
          keymap = {
            accept = false,
            accept_line = '<M-l>',
            next = '<M-]>',
            prev = '<M-[>',
            dismiss = '<C-]>',
          },
        },
      }
    end,
  },
}
