local M = {}

local function manual_pair(bufnr)
  local Path = require 'plenary.path'
  local fnm = vim.fn.fnamemodify
  local buf = vim.api.nvim_buf_get_name(bufnr)
  if buf == '' then return end

  local dir = fnm(buf, ':h')
  local file = fnm(buf, ':t') -- "foo.h", "foo_impl.h" or "foo.cc"
  local stem = fnm(buf, ':t:r') -- "foo" or "foo_impl"
  local base = stem:gsub('_impl$', '')

  local candidates = {}
  if file:match '_impl%.h$' then
    -- impl.h → header
    table.insert(candidates, base .. '.h')
  elseif file:match '%.h$' then
    -- header → impl.h first
    table.insert(candidates, base .. '_impl.h')
    -- (optional) then try C/C++ source siblings
    for _, ext in ipairs { '.cc', '.cpp', '.cxx', '.c' } do
      table.insert(candidates, base .. ext)
    end
  else
    -- source → headers
    table.insert(candidates, base .. '.h')
  end

  for _, name in ipairs(candidates) do
    local p = dir .. '/' .. name
    if p ~= buf and Path:new(p):exists() then return p end
  end
end

M.switch_source_header = function(bufnr)
  local local_target = manual_pair(bufnr)
  if local_target then return vim.cmd.edit(local_target) end
  local method_name = 'textDocument/switchSourceHeader'
  local client = vim.lsp.get_clients({ bufnr = bufnr, name = 'clangd' })[1]
  if not client then return vim.notify(('method %s is not supported by any servers active on the current buffer'):format(method_name)) end
  local params = vim.lsp.util.make_text_document_params(bufnr)
  local handler = function(err, result)
    if err then error(tostring(err)) end
    if not result then
      vim.notify 'corresponding file cannot be determined'
      return
    end
    vim.cmd.edit(vim.uri_to_fname(result))
  end
  client.request(method_name, params, handler, bufnr)
end

return M
