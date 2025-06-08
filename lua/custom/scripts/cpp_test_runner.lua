local p = require 'plenary.path'
local a = require 'plenary.async'

local M = {}

local get_root = function(bufnr)
  local parser = vim.treesitter.get_parser(bufnr, 'cpp', {})
  local tree = parser:parse()[1]
  return tree:root()
end

local test_query = vim.treesitter.query.parse(
  'cpp',
  [[
(function_definition
  (function_declarator
	declarator: (identifier) @type_of_test (#any-of? @type_of_test "TEST_F" "TEST_P" "TEST")
  )
)
  ]]
)

local find_executable_query = vim.treesitter.query.parse(
  'cmake',
  [[
(
  (normal_command
    (identifier) @_command_name (#eq? @_command_name "set")
    (argument_list
      (argument) @_first_arg (#eq? @_first_arg "MODULE_NAME")
      (argument) @second_arg
    )
  )
)
  ]]
)

local ns = vim.api.nvim_create_namespace 'cpp_test_runner'

local compile_job_id = nil
local replace_with = nil

local get_executable_name = function()
  local orig_buf = vim.api.nvim_get_current_buf()
  local orig_view = vim.fn.winsaveview()
  local current_file = p:new(vim.api.nvim_buf_get_name(0))
  local cmake_file = current_file:find_upwards 'CMakeLists.txt'
  vim.api.nvim_command('edit! ' .. cmake_file:absolute())
  local cmake_buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_set_current_buf(orig_buf)
  vim.fn.winrestview(orig_view)

  local parser = vim.treesitter.get_parser(cmake_buf, 'cmake')
  local tree = parser:parse()[1]
  local root = tree:root()
  for id, node in find_executable_query:iter_captures(root, cmake_buf, 0, -1) do
    local name = find_executable_query.captures[id]
    if name == 'second_arg' then
      return vim.treesitter.get_node_text(node, cmake_buf)
    end
  end
  return -1
end
--let s:lines = ['']
-- func! s:on_event(job_id, data, event) dict
--   let eof = (a:data == [''])
--   " Complete the previous line.
--   let s:lines[-1] .= a:data[0]
--   " Append (last item may be a partial line, until EOF).
--   call extend(s:lines, a:data[1:])
-- endf

local compile_tests = function(test_binary_name, callback)
  if compile_job_id then
    vim.notify('Cancelling previous compilation', vim.log.levels.INFO)
    vim.fn.jobstop(compile_job_id)
  end
  vim.notify('Compiling ' .. test_binary_name, vim.log.levels.INFO)
  local line = ''
  local should_keep = true
  compile_job_id = vim.fn.jobstart({ 'cc-env', './build.py', '-j', '15', '-b', test_binary_name }, {
    env = { BUILD_INFO_DUMMY = '1' },
    on_exit = function(job_id, exit_code)
      should_keep = false
      if job_id == compile_job_id then
        compile_job_id = nil
      end
      if exit_code ~= 0 then
        vim.notify('Compilation error', vim.log.levels.ERROR)
        return
      end
      callback()
    end,
    on_stdout = function(job_id, data, name)
      for _, partial_line in ipairs(data) do
        if partial_line == '' then
          if line:sub(1, 1) == '[' then
            replace_with = vim.notify(line, vim.log.levels.INFO, {
              title = 'Compiling ' .. test_binary_name,
              replace = replace_with,
              keep = function()
                return should_keep
              end,
              max_width = 40,
              render = 'wrapped-compact',
            })
          end
          line = ''
        else
          line = line .. partial_line
        end
      end
    end,
  })
end

local failed_state = {}
local test_name_to_line = {}

local process_results = function(output_file, bufnr)
  local results_file = p:new(output_file)
  a.run(function()
    if not results_file:exists() then
      vim.notify('Results file does not exists', vim.log.levels.ERROR)
      return
    end

    local contents, err = results_file:read()
    if err then
      vim.notify('Error reading Results file', vim.log.levels.ERROR)
      return
    end
    failed_state = {}
    test_name_to_line = {}

    local json_table = vim.json.decode(contents, {})
    local tests = json_table.testsuites
    local failed_diag = {}
    for _, test_suite in ipairs(tests) do
      for _, test in ipairs(test_suite.testsuite) do
        if test.failures == nil then
          vim.api.nvim_buf_set_extmark(bufnr, ns, test.line - 1, 0, { virt_text = { { '✅' } } })
        else
          table.insert(failed_diag, {
            bufnr = bufnr,
            lnum = test.line - 1,
            col = 0,
            severity = vim.diagnostic.severity.ERROR,
            source = 'cpp-test',
            message = 'Test Failed',
            user_data = {},
          })
          if failed_state[test.line] == nil then
            failed_state[test.line] = { failed_tests = {} }
            local stripped_name = test.name:gsub('/.*', '')
            test_name_to_line[stripped_name] = test.line
          end
          local failed_tests = failed_state[test.line].failed_tests
          local output = {}
          for _, failure in ipairs(test.failures) do
            local strings = vim.split(failure.failure, '\n')
            for _, str in ipairs(strings) do
              table.insert(output, str)
            end
          end
          table.insert(failed_tests, {
            name = test.name,
            output = output,
          })
        end
      end
    end

    vim.diagnostic.set(ns, bufnr, failed_diag, {})
  end, function() end)
end

local run_test = function(binary_name, fixture_name, unit_name, is_parameterised, bufnr)
  local test_dir = vim.fn.getcwd() .. '/build/debug/unit_test/'
  local command = test_dir .. binary_name
  local filter = '--gtest_filter=' .. fixture_name .. '.' .. unit_name
  if is_parameterised then
    filter = filter .. '/*'
  end
  local output_file = test_dir .. binary_name .. '.results.json'
  local output_file_h = p:new(output_file)
  if output_file_h:exists() then
    output_file_h:rm { recursive = false }
  end
  local output = '--gtest_output=json:' .. output_file
  vim.notify('Running tests', vim.log.levels.INFO)
  vim.fn.jobstart({ command, filter, output }, {
    cwd = test_dir,
    on_exit = function(job_id, exit_code)
      if exit_code == 0 then
        vim.notify('All tests passed', vim.log.levels.INFO)
      else
        vim.notify('At least one test failed', vim.log.levels.WARN)
      end
      process_results(output_file, bufnr)
    end,
  })
end

local get_filter = function(fixture_name, unit_name, is_parameterised)
  local filter = '--gtest_filter=' .. fixture_name .. '.' .. unit_name
  if is_parameterised then
    filter = filter .. '/*'
  end
  return filter
end

local debug_test = function(binary_name, filter)
  local binary = vim.fn.getcwd() .. '/build/debug/unit_test/' .. binary_name
  local dap = require 'dap'
  local config = {
    name = 'Debugging unit test',
    type = 'cppdbg',
    request = 'launch',
    program = binary,
    args = { filter },
    cwd = '${workspaceFolder}',
    stopAtEntry = false,
    setupCommands = {
      {
        text = '-enable-pretty-printing',
        description = 'enable pretty printing',
        ignoreFailures = false,
      },
    },
  }
  dap.run(config)
end

local get_test_info = function(bufnr)
  local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
  local search_range_low = math.max(0, cursor_row - 200)

  local root = get_root(bufnr)
  for pattern, match, metadata in test_query:iter_matches(root, bufnr, search_range_low, cursor_row, { all = true }) do
    for id, nodes in pairs(match) do
      for _, node in ipairs(nodes) do
        local parent = node:parent()
        local function_def = parent:parent()
        local start_row, start_col, end_row, end_col = function_def:range()
        if start_row <= cursor_row and end_row + 1 >= cursor_row then
          local name = test_query.captures[id]
          local type_of_test = vim.treesitter.get_node_text(node, bufnr)
          local parameter_list = node:next_sibling()
          if parameter_list:named_child_count() ~= 2 then
            vim.notify('Only test with {Fixture} {TestName} are supported', vim.log.levels.ERROR)
            return true, -1, -1, -1, -1
          end
          local fixture_name_node = parameter_list:named_child(0)
          local test_name_node = parameter_list:named_child(1)

          local fixture = vim.treesitter.get_node_text(fixture_name_node, bufnr, { metadata = metadata[id] })
          local test = vim.treesitter.get_node_text(test_name_node, bufnr, { metadata = metadata[id] })
          return false, fixture, test, type_of_test
        end
      end
    end
  end
  vim.notify('Could not find test, please place cursor inside of a test', vim.log.levels.WARN)
  return true, -1, -1, -1, -1
end

M.run_unit_test = function(run_fixture)
  local bufnr = vim.api.nvim_get_current_buf()

  if vim.bo[bufnr].filetype ~= 'cpp' then
    vim.notify 'can only be used in cpp'
    return
  end

  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  vim.diagnostic.reset(ns, bufnr)
  local error, fixture, test, type_of_test = get_test_info(bufnr)
  if error then
    return
  end
  local exec = get_executable_name()
  if exec == -1 then
    vim.notify('Could not find executable name', vim.log.levels.ERROR)
    return
  end
  if run_fixture then
    test = '*'
  end
  compile_tests(exec, function()
    run_test(exec, fixture, test, type_of_test == 'TEST_P', bufnr)
  end)
end

M.debug_unit_test = function()
  local bufnr = vim.api.nvim_get_current_buf()

  if vim.bo[bufnr].filetype ~= 'cpp' then
    vim.notify 'can only be used in cpp'
    return
  end

  local error, fixture, test, type_of_test = get_test_info(bufnr)
  if error then
    return
  end
  local exec = get_executable_name()
  if exec == -1 then
    vim.notify('Could not find executable name', vim.log.levels.ERROR)
    return
  end
  compile_tests(exec, function()
    debug_test(exec, get_filter(fixture, test, type_of_test == 'TEST_P'))
  end)
end

M.view_test_output = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local error, fixture, test, type_of_test = get_test_info(bufnr)
  if error then
    return
  end
  local test_line = test_name_to_line[test]
  local failed = failed_state[test_line]
  if failed == nil then
    vim.notify('Could not find info for this test', vim.log.levels.ERROR)
    return
  end
  vim.cmd 'belowright new'
  local out_buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = out_buf })
  vim.api.nvim_set_option_value('bufhidden', 'hide', { buf = out_buf })
  vim.api.nvim_set_option_value('swapfile', false, { buf = out_buf })
  vim.api.nvim_set_option_value('buflisted', false, { buf = out_buf })
  vim.cmd 'wincmd J' -- Move the new split to the bottom
  vim.cmd('resize ' .. math.floor(vim.o.lines / 3)) -- Adjust height

  vim.cmd 'highlight CppTestOutputTest guifg=#477EF5'

  local output = {}
  local test_lines = {}
  for _, failed_test in ipairs(failed.failed_tests) do
    table.insert(output, '===== ' .. failed_test.name)
    table.insert(test_lines, #output)
    for _, str in ipairs(failed_test.output) do
      table.insert(output, str)
    end
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, output)
  for _, line in ipairs(test_lines) do
    vim.hl.range(bufnr, ns, 'CppTestOutputTest', { line - 1, 0 }, { line - 1, -1 })
  end
end

return M
