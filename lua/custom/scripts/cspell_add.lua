local a = require 'plenary.async'

local M = {}

M.add_visual_to_words = function(lint_after)
  lint_after = lint_after or false
  local p = require 'plenary.path'
  local mode = vim.api.nvim_get_mode().mode
  if mode ~= 'v' then
    vim.notify('Not in visual mode', vim.log.levels.ERROR)
    return
  end
  vim.cmd 'normal! \027' -- \027 is the escape character
  local _, start_row, start_col, _ = unpack(vim.fn.getpos "'<")
  local _, end_row, end_col, _ = unpack(vim.fn.getpos "'>")
  if start_row ~= end_row then
    vim.notify('Please select only one word', vim.log.levels.ERROR)
    return
  end
  local bufnr = vim.api.nvim_get_current_buf()
  local word = vim.api.nvim_buf_get_text(bufnr, start_row - 1, start_col - 1, end_row - 1, end_col, {})

  local current_file = p:new(vim.api.nvim_buf_get_name(0))
  local cspell_filename = current_file:find_upwards '.cspell.json'
  local cspell_file = p:new(cspell_filename)
  a.run(function()
    if not cspell_file:exists() then
      vim.notify('CSpell file does not exists', vim.log.levels.ERROR)
      return
    end

    local contents, err = cspell_file:read()
    if err then
      vim.notify('Error reading CSpell file', vim.log.levels.ERROR)
      return
    end

    local json_table = vim.json.decode(contents, {})
    json_table.words = json_table.words or {}
    table.insert(json_table.words, word[1])
    local json_str = vim.json.encode(json_table)
    cspell_file:write(json_str, 'w')
    if lint_after then
      require('lint').try_lint 'cspell'
    end
  end, function() end)
end

return M
