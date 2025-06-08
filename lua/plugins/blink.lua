return {
  {
    'saghen/blink.cmp',
    dependencies = { 'rafamadriz/friendly-snippets' },
    -- use a release tag to download pre-built binaries
    version = '1.*',
    config = function()
      local blink = require 'blink-cmp'
      ---@type blink.cmp.PrebuiltBinariesConfigPartial?
      local prebuilt_binaries = nil
      if vim.g.sz_nvim_is_work then
        prebuilt_binaries = {
          proxy = {
            url = vim.g.sz_nvim_http_proxy,
          },
        }
      end
      blink.setup {
        keymap = { preset = 'default' },
        appearance = {
          nerd_font_variant = 'mono',
        },
        completion = { documentation = { auto_show = true } },
        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer' },
          providers = {
            lazydev = {
              name = 'LazyDev',
              module = 'lazydev.integrations.blink',
              -- make lazydev completions top priority (see `:h blink.cmp`)
              score_offset = 100,
            },
          },
        },
        fuzzy = {
          implementation = 'rust',
          prebuilt_binaries = prebuilt_binaries,
        },
      }
    end,
    opts_extend = { 'sources.default' },
  },
}
