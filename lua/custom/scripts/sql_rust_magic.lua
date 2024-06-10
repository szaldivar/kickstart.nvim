local run_formatter = function(text_to_format)
  local result = vim.system({ 'python3', '/Users/szaldivar/bin/sql_format.py' }, { stdin = text_to_format }):wait()
  local lines = {}
  table.insert(lines, '')
  -- Use string.gmatch to iterate over each line
  for line in string.gmatch(result.stdout, '([^\n]*)\n?') do
    table.insert(lines, line)
  end
  return lines
end

local embedded_sql = vim.treesitter.query.parse(
  'rust',
  [[
(macro_invocation
 (scoped_identifier
   path: (identifier) @_path (#eq? @_path "sqlx")
   name: (identifier) @_name (#any-of? @_name "query_as" "query" "query_scalar")
 )
 (token_tree
  (raw_string_literal) @sql
  (#offset! @sql 0 3 0 -2)
 )
)
]]
)

local get_root = function(bufnr)
  local parser = vim.treesitter.get_parser(bufnr, 'rust', {})
  local tree = parser:parse()[1]
  return tree:root()
end

local M = {}

M.format_dat_sql = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if vim.bo[bufnr].filetype ~= 'rust' then
    vim.notify 'can only be used in rust'
    return
  end

  local root = get_root(bufnr)
  local changes = {}
  for id, node, metadata in embedded_sql:iter_captures(root, bufnr, 0, -1) do
    local name = embedded_sql.captures[id]
    if name == 'sql' then
      -- Run the formatter, based on the node text
      local formatted = run_formatter(vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[id] }))
      -- { start row, start col, end row, end col }
      local range = metadata[id].range
      assert(range ~= nil)

      -- keep track of changes
      --   But insert them in reverse order of the file,
      --   so that when we make modifications, we don't have
      --   any out of date line numbers
      table.insert(changes, 1, { start_row = range[1], start_col = range[2], final_row = range[3], final_col = range[4], formatted = formatted })
    end
  end

  for _, change in ipairs(changes) do
    vim.api.nvim_buf_set_text(bufnr, change.start_row, change.start_col, change.final_row, change.final_col, change.formatted)
  end
end

return M
