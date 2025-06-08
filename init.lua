--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local env = os.getenv 'NVIM_SZ_ENVIRONMENT'
if not env or env == '' then vim.notify('env var NVIM_SZ_ENVIRONMENT should be set', 'error') end
vim.g.sz_nvim_is_work = env == 'WORK'

if vim.g.sz_nvim_is_work then vim.g.sz_nvim_http_proxy = os.getenv 'NVIM_SZ_HTTP_PROXY' end

vim.opt.termguicolors = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.wrap = false

vim.opt.mouse = 'a'

vim.opt.showmode = false

vim.opt.clipboard = 'unnamedplus'

vim.opt.breakindent = true

vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣', eol = '⇙' }

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 5

vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.diagnostic.config {
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.INFO] = '',
      [vim.diagnostic.severity.HINT] = '',
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = 'ErrorMsg',
      [vim.diagnostic.severity.WARN] = 'WarningMsg',
      [vim.diagnostic.severity.INFO] = 'DiagnosticInfo',
      [vim.diagnostic.severity.HINT] = 'DiagnosticHint',
    },
  },
  virtual_text = { current_line = true },
}

-- better diffs
vim.opt.fillchars = {
  diff = ' ',
}
vim.opt.diffopt = {
  'internal',
  'filler',
  'closeoff',
  'context:12',
  'algorithm:histogram',
  'linematch:200',
  'indent-heuristic',
}

-- spelling
vim.opt.spell = true
vim.opt.spelllang = 'en_au'
vim.opt.spelloptions = 'camel'

-- don't run spell check on terminal buffers
vim.api.nvim_create_augroup('TerminalNoSpell', { clear = true })
vim.api.nvim_create_autocmd('TermOpen', {
  group = 'TerminalNoSpell',
  pattern = '*',
  callback = function() vim.opt_local.spell = false end,
})

-- folding
vim.o.foldenable = true
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.o.foldtext = ''
vim.opt.foldcolumn = '0'
vim.opt.fillchars:append { fold = ' ' }

-- Diagnostic keymaps
vim.keymap.set('n', ']d', function() vim.diagnostic.jump { count = 1 } end, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', '[d', function() vim.diagnostic.jump { count = -1 } end, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- spell check
vim.keymap.set('n', '<leader>zc', function() require('lint').try_lint 'cspell' end, { desc = 'Spell [C]heck' })
vim.keymap.set('v', '<leader>za', function() require('custom/scripts/cspell_add').add_visual_to_words(true) end, { desc = 'Spell [A]dd word' })

-- quickfix navigation
vim.keymap.set('n', '<M-n>', function() vim.cmd 'cnext' end, { desc = 'Go to next item in quickfix list' })
vim.keymap.set('n', '<M-p>', function() vim.cmd 'cprev' end, { desc = 'Go to previous item in quickfix list' })

-- for oil.nvim
function _G.get_oil_winbar()
  local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  local dir = require('oil').get_current_dir(bufnr)
  if dir then
    return vim.fn.fnamemodify(dir, ':~')
  else
    -- If there is no current directory (e.g. over ssh), just show the buffer name
    return vim.api.nvim_buf_get_name(0)
  end
end

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<up>', '5<C-y>5k')
vim.keymap.set('n', '<down>', '5<C-e>5j')
vim.keymap.set('x', '<up>', '5<C-y>5k')
vim.keymap.set('x', '<down>', '5<C-e>5j')

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

require 'config.lazy'
