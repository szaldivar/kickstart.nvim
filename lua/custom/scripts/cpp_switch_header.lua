local M = {}

M.switch_source_header = function(bufnr)
  local method = 'textDocument/switchSourceHeader'
  local client = vim.lsp.get_clients({ bufnr = bufnr, name = 'clangd' })[1]
  if not client then return vim.notify(('method %s is not supported by any servers on this buffer'):format(method), vim.log.levels.WARN) end
  local params = vim.lsp.util.make_text_document_params(bufnr)
  local handler = function(err, result)
    if err then error(tostring(err)) end
    -- 1) If clangd gave us a file, jump there and done.
    if result then
      vim.cmd.edit(vim.uri_to_fname(result))
      return
    end
    -- 2) Fallback: manually look for _impl.h ↔ .h in same directory
    local fname = vim.api.nvim_buf_get_name(bufnr)
    if fname == '' then
      vim.notify('No filename for current buffer', vim.log.levels.ERROR)
      return
    end
    local dir = vim.fn.fnamemodify(fname, ':h')
    local tail = vim.fn.fnamemodify(fname, ':t') -- e.g. "foo_impl.h" or "foo.h"
    local base = vim.fn.fnamemodify(fname, ':t:r') -- e.g. "foo_impl" or "foo"
    local candidate = nil
    -- if we're in foo_impl.h, go back to foo.h
    if tail:match '_impl%.h$' then
      local header = base:gsub('_impl$', '') .. '.h'
      candidate = dir .. '/' .. header
      -- if we're in foo.h, try foo_impl.h
    elseif tail:match '%.h$' then
      candidate = dir .. '/' .. base .. '_impl.h'
    end
    local Path = require 'plenary.path'
    if candidate and Path:new(candidate):exists() then
      vim.cmd.edit(candidate)
    else
      vim.notify("Couldn't find corresponding _impl.h/.h file", vim.log.levels.INFO)
    end
  end

  client.request(method, params, handler, bufnr)
end

return M
