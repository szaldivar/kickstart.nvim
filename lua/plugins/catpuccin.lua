return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    opts = {
      styles = {
        comments = { 'italic' },
        conditionals = { 'italic', 'bold' },
        loops = { 'bold' },
        functions = {},
        keywords = { 'bold' },
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = { 'bold' },
        -- miscs = {}, -- Uncomment to turn off hard-coded styles
      },
      integrations = {
        gitsigns = true,
        treesitter = true,
        notify = true,
        noice = true,
        mini = {
          enabled = true,
          indentscope_color = '',
        },
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { 'italic' },
            hints = { 'italic' },
            warnings = { 'italic' },
            information = { 'italic' },
            ok = { 'italic' },
          },
          underlines = {
            errors = { 'undercurl' },
            hints = { 'undercurl' },
            warnings = { 'undercurl' },
            information = { 'undercurl' },
            ok = { 'undercurl' },
          },
        },
      },
    },
    init = function() vim.cmd.colorscheme 'catppuccin-macchiato' end,
  },
}
