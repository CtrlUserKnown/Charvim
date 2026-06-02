local M = {}

local ns = vim.api.nvim_create_namespace('multicursor')
local on_key_ns = vim.api.nvim_create_namespace('multicursor_on_key')

local cursors = nil
local last_real_pos = nil
local active_idx = nil
local in_tracking = false
local in_broadcast = false
local insert_start = nil
local skip_cursor_move = false
local multi_mode = false

local attached_buffers = {}

local function gc()
  return vim.api.nvim_win_get_cursor(0)
end

local function sc(pos)
  vim.api.nvim_win_set_cursor(0, pos)
end

local function lc(lnum)
  local lines = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)
  return lines[1] or ''
end

local function blc()
  return vim.api.nvim_buf_line_count(0)
end

local function cc(lnum, col)
  if col < 0 then return 0 end
  local line = lc(lnum)
  return math.min(col, #line)
end

local function sort_cursors()
  table.sort(cursors, function(a, b)
    if a[1] == b[1] then return a[2] < b[2] end
    return a[1] < b[1]
  end)
end

local function render()
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  if not cursors then return end
  for _, c in ipairs(cursors) do
    pcall(vim.api.nvim_buf_set_extmark, 0, ns, c[1] - 1, cc(c[1], c[2]), {
      sign_text = '▎',
      sign_hl_group = 'Cursor',
      priority = 250,
    })
  end
end

local function refresh_active_idx()
  if not cursors then return end
  local pos = gc()
  for i, c in ipairs(cursors) do
    if c[1] == pos[1] and c[2] == pos[2] then
      active_idx = i
      return
    end
  end
  active_idx = nil
end

function M.is_active()
  return cursors ~= nil
end

function M.enter()
  if cursors then return end
  local pos = gc()
  cursors = {{pos[1], pos[2]}}
  last_real_pos = {pos[1], pos[2]}
  active_idx = 1
  multi_mode = true
  render()
end

function M.add_above()
  local pos = gc()
  if not cursors then
    cursors = {{pos[1], pos[2]}}
    last_real_pos = {pos[1], pos[2]}
    active_idx = 1
    multi_mode = true
  end
  if pos[1] > 1 then
    local ok = true
    for _, c in ipairs(cursors) do
      if c[1] == pos[1] - 1 and c[2] == pos[2] then ok = false; break end
    end
    if ok then
      table.insert(cursors, {pos[1] - 1, pos[2]})
      sort_cursors()
      refresh_active_idx()
      render()
    end
  end
end

function M.add_below()
  local pos = gc()
  if not cursors then
    cursors = {{pos[1], pos[2]}}
    last_real_pos = {pos[1], pos[2]}
    active_idx = 1
    multi_mode = true
  end
  if pos[1] < blc() then
    local ok = true
    for _, c in ipairs(cursors) do
      if c[1] == pos[1] + 1 and c[2] == pos[2] then ok = false; break end
    end
    if ok then
      table.insert(cursors, {pos[1] + 1, pos[2]})
      sort_cursors()
      refresh_active_idx()
      render()
    end
  end
end

function M.exit()
  cursors = nil
  last_real_pos = nil
  active_idx = nil
  insert_start = nil
  multi_mode = false
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end

local function do_normal_jk(key, count)
  vim.cmd('normal! ' .. (count > 0 and count or 1) .. key)
end

local function j_handler()
  if not multi_mode then
    do_normal_jk('j', vim.v.count)
    return
  end
  local count = vim.v.count > 0 and vim.v.count or 1
  for _ = 1, count do
    local pos = gc()
    if pos[1] >= blc() then break end
    M.add_below()
    last_real_pos = {pos[1] + 1, pos[2]}
    sc({pos[1] + 1, pos[2]})
  end
  refresh_active_idx()
  render()
end

local function k_handler()
  if not multi_mode then
    do_normal_jk('k', vim.v.count)
    return
  end
  local count = vim.v.count > 0 and vim.v.count or 1
  for _ = 1, count do
    local pos = gc()
    if pos[1] <= 1 then break end
    M.add_above()
    last_real_pos = {pos[1] - 1, pos[2]}
    sc({pos[1] - 1, pos[2]})
  end
  refresh_active_idx()
  render()
end

local function move_all_cursors(dlnum, dcol)
  if not cursors or in_tracking then return end
  in_tracking = true
  for _, c in ipairs(cursors) do
    c[1] = math.max(1, math.min(blc(), c[1] + dlnum))
    c[2] = cc(c[1], c[2] + dcol)
  end
  in_tracking = false
  render()
end

local function broadcast_text(inserted, start_lnum, start_col)
  if not cursors or #inserted == 0 then return end
  local buf = vim.api.nvim_get_current_buf()
  local work = {}
  for i, c in ipairs(cursors) do
    work[#work + 1] = {i, c[1], c[2]}
  end
  table.sort(work, function(a, b)
    if a[2] == b[2] then return a[3] > b[3] end
    return a[2] > b[2]
  end)
  for _, item in ipairs(work) do
    local idx, lnum, col = item[1], item[2], item[3]
    if lnum ~= start_lnum or col ~= start_col then
      local line = lc(lnum)
      local new_line = line:sub(1, col) .. inserted .. line:sub(col + 1)
      vim.api.nvim_buf_set_lines(buf, lnum - 1, lnum, false, {new_line})
      cursors[idx][2] = col + #inserted
    else
      cursors[idx][2] = cursors[idx][2] + #inserted
    end
  end
  render()
end

local function insert_handler()
  if not cursors then return end
  local pos = gc()
  insert_start = {lnum = pos[1], col = pos[2], line = lc(pos[1])}
  last_real_pos = nil
end

local function insert_leave_handler()
  local state = insert_start
  insert_start = nil
  if not cursors or not state then return end
  local end_pos = gc()
  local final_lnum, final_col = end_pos[1], end_pos[2]
  if final_lnum == state.lnum then
    local new_line = lc(final_lnum)
    local inserted = new_line:sub(state.col + 1, final_col)
    broadcast_text(inserted, state.lnum, state.col)
    last_real_pos = {gc()[1], gc()[2]}
    return
  end
  last_real_pos = {gc()[1], gc()[2]}
end

local function cursor_handler()
  if not cursors or in_tracking then return end
  local new_pos = gc()

  if skip_cursor_move then
    skip_cursor_move = false
    last_real_pos = {new_pos[1], new_pos[2]}
    if active_idx and cursors[active_idx] then
      cursors[active_idx][1] = new_pos[1]
      cursors[active_idx][2] = new_pos[2]
    end
    render()
    return
  end

  if last_real_pos then
    local dlnum = new_pos[1] - last_real_pos[1]
    local dcol = new_pos[2] - last_real_pos[2]
    if dlnum ~= 0 or dcol ~= 0 then
      move_all_cursors(dlnum, dcol)
    end
  end
  last_real_pos = {new_pos[1], new_pos[2]}
  refresh_active_idx()
end

local function text_changed_handler()
  if not cursors or in_broadcast then return end
  in_broadcast = true
  local work = {}
  for _, c in ipairs(cursors) do
    work[#work + 1] = {c[1], c[2]}
  end
  table.sort(work, function(a, b)
    if a[1] == b[1] then return a[2] > b[2] end
    return a[1] > b[1]
  end)
  local feed_dot = vim.api.nvim_replace_termcodes('.', true, false, true)
  local origin_idx = active_idx
  if not origin_idx then
    local current = gc()
    for i, c in ipairs(cursors) do
      if c[1] == current[1] and c[2] == current[2] then
        origin_idx = i
        break
      end
    end
  end
  for _, pos in ipairs(work) do
    if not (origin_idx and cursors[origin_idx]
      and cursors[origin_idx][1] == pos[1]
      and cursors[origin_idx][2] == pos[2]) then
      sc(pos)
      vim.api.nvim_feedkeys(feed_dot, 'nx', false)
      local np = gc()
      for _, c in ipairs(cursors) do
        if c[1] == pos[1] and c[2] == pos[2] then
          c[1] = np[1]
          c[2] = np[2]
          break
        end
      end
    end
  end
  sort_cursors()
  render()
  in_broadcast = false
end

local function on_buf_lines(_, _, firstline, lastline, new_lastline)
  if not cursors then return end
  if new_lastline > lastline then
    local shift = new_lastline - lastline
    for _, c in ipairs(cursors) do
      if c[1] > firstline then
        c[1] = c[1] + shift
      end
    end
  elseif new_lastline < lastline then
    local deleted = lastline - new_lastline
    for _, c in ipairs(cursors) do
      if c[1] > lastline then
        c[1] = c[1] - deleted
      elseif c[1] > firstline then
        c[1] = firstline + 1
      end
    end
  end
  skip_cursor_move = true
  render()
end

local function ensure_attached()
  local buf = vim.api.nvim_get_current_buf()
  if attached_buffers[buf] then return end
  attached_buffers[buf] = true
  vim.api.nvim_buf_attach(buf, false, { on_lines = on_buf_lines })
end

local function setup_autocmds()
  local group = vim.api.nvim_create_augroup('multicursor', { clear = true })
  vim.api.nvim_create_autocmd('CursorMoved', { group = group, callback = cursor_handler })
  vim.api.nvim_create_autocmd('InsertEnter', { group = group, callback = insert_handler })
  vim.api.nvim_create_autocmd('InsertLeave', { group = group, callback = insert_leave_handler })
  vim.api.nvim_create_autocmd('TextChanged', { group = group, callback = text_changed_handler })
  vim.api.nvim_create_autocmd('BufEnter', { group = group, callback = ensure_attached })
end

local function setup_keymaps()
  vim.keymap.set({'n', 'v'}, '<C-Up>', M.add_above, { desc = 'Add cursor above' })
  vim.keymap.set({'n', 'v'}, '<C-Down>', M.add_below, { desc = 'Add cursor below' })
  vim.keymap.set('n', '<C-n>', M.enter, { desc = 'Enter multi-cursor mode' })
  vim.keymap.set('n', 'j', j_handler, { desc = 'j or add cursor below (multi-cursor)' })
  vim.keymap.set('n', 'k', k_handler, { desc = 'k or add cursor above (multi-cursor)' })
  vim.keymap.set('n', 'gj', j_handler, { desc = 'gj or add cursor below (multi-cursor)' })
  vim.keymap.set('n', 'gk', k_handler, { desc = 'gk or add cursor above (multi-cursor)' })
end

vim.on_key(function(key)
  if cursors and key == '\27' and vim.fn.mode() == 'n' then
    vim.wait(10, function() return vim.fn.getchar(0) ~= 0 end)
    if vim.fn.getchar(0) == 0 then
      M.exit()
    end
  end
end, on_key_ns)

function M.setup()
  setup_autocmds()
  setup_keymaps()
  ensure_attached()
end

return M
