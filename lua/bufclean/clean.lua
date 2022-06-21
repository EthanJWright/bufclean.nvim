local api = vim.api
local M = {}

local function close_buffers_relative_to_dir(directories, shouldMatch)
  -- get a list of all currently open buffers
  if not directories then
    return
  end
  local buffers = vim.tbl_filter(api.nvim_buf_is_loaded, api.nvim_list_bufs())
  local to_delete = vim.tbl_filter(function(buf)
    local buf_path = api.nvim_buf_get_name(buf)
    if buf_path == nil or buf_path == "" then
      return false
    end
    local isMatch = 0
    for _, dir in ipairs(directories) do
      if buf_path ~= nil then
        isMatch = string.find(buf_path, dir, 1, true) or isMatch
      end
    end
    if isMatch == 1 then
      return shouldMatch
    else
      return not shouldMatch
    end
  end, buffers)
  -- iterate through each to_delete and delete the buffer
  for _, buf in ipairs(to_delete) do
    api.nvim_command('bdelete ' .. buf)
  end
end

function M.close_buffers_in_parent_dir()
  local parent_dir = vim.fn.expand('%:p:h')
  close_buffers_relative_to_dir({ parent_dir }, true)
end

local function get_directory_removing_n_path_elements(parent_dir, n, include_from_cwd)
  if include_from_cwd == nil then
    include_from_cwd = true
  end
  local parent_dir_split = vim.split(parent_dir, '/')
  -- remove the last n elements from the parent_dir_split
  local path_length = vim.tbl_count(parent_dir_split)
  local cwd_elements = vim.tbl_count(vim.split(vim.fn.getcwd(), '/'))
  local new_path = parent_dir_split[1]
  if include_from_cwd then
    for i = 2, n + 1 + cwd_elements do
      new_path = new_path .. '/' .. parent_dir_split[i]
    end
  else
    for i = 2, path_length - n do
      new_path = new_path .. '/' .. parent_dir_split[i]
    end
  end
  return new_path
end

function M.close_buffers_in_context(parent_offset, include_from_cwd)
  if parent_offset == nil then
    parent_offset = 1
  end
  local parent_dir = vim.fn.expand('%:p:h')
  local new_path = get_directory_removing_n_path_elements(parent_dir, parent_offset, include_from_cwd)
  close_buffers_relative_to_dir({ new_path }, true)
end

function M.close_buffers_outside_context(parent_offset, include_from_cwd)
  if parent_offset == nil then
    parent_offset = 1
  end
  local parent_dir = vim.fn.expand('%:p:h')
  local new_path = get_directory_removing_n_path_elements(parent_dir, parent_offset, include_from_cwd)
  close_buffers_relative_to_dir({ new_path }, false)
end

function M.close_hidden_outside_visible_context(parent_offset, include_from_start)
  -- get list of not hidden buffers
  if parent_offset == nil then
    parent_offset = 1
  end
  local parents_to_keep = {}
  for _, win in ipairs(api.nvim_list_wins()) do
    local name = api.nvim_buf_get_name(api.nvim_win_get_buf(win))
    local keep_path = get_directory_removing_n_path_elements(name, parent_offset, include_from_start)
    -- push keep_path to parents_to_keep if it is not in the list
    if not vim.tbl_contains(parents_to_keep, keep_path) then
      table.insert(parents_to_keep, keep_path)
    end
  end
  close_buffers_relative_to_dir(parents_to_keep, false)
end

return M
