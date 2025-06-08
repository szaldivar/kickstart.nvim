return {
  { -- Autoformat
    'stevearc/conform.nvim',
    lazy = false,
    keys = {
      {
        '<leader>f',
        function()
          if vim.bo.filetype == 'rust' then require('custom/scripts/sql_rust_magic').format_dat_sql() end
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    config = function()
      local conform = require 'conform'
      conform.setup {
        notify_on_error = true,
        formatters = {
          rustfmt = {
            prepend_args = { '+nightly' },
          },
          customsql = {
            inherit = false,
            command = 'sql-formatter',
            args = { '-c', '.sql_formatter.json', '$FILENAME' },
          },
        },
        formatters_by_ft = {
          lua = { 'stylua' },
          python = { 'ruff_format', 'ruff_organize_imports' },
          cpp = { 'clang_format' },
          c = { 'clang_format' },
          json = { 'fixjson' },
          javascript = { 'prettier' },
          typescript = { 'prettier' },
          rust = { 'rustfmt' },
          sql = { 'customsql' },
          svg = { 'xmllint' },
          xml = { 'xmllint' },
        },
      }
    end,
  },
}
