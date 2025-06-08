return {
  {
    'gbprod/substitute.nvim',
    config = function()
      vim.keymap.set('n', 'x', require('substitute').operator, { noremap = true, desc = 'substitute' })
      vim.keymap.set('n', 'xx', require('substitute').line, { noremap = true, desc = 'substitute line' })
      vim.keymap.set('n', 'X', require('substitute').eol, { noremap = true, desc = 'substitute to end of line' })
      vim.keymap.set('x', 'x', require('substitute').visual, { noremap = true, desc = 'substitute selection' })
      require('substitute').setup {
        highlight_substituted_text = {
          timer = 150,
        },
      }
    end,
  },
}
