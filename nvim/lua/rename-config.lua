local M = {}

local function get_visual_selection()
  local ls, cs = vim.fn.line("'<"), vim.fn.col("'<")
  local le, ce = vim.fn.line("'>"), vim.fn.col("'>")
  if ls ~= le then return nil end
  local line = vim.api.nvim_buf_get_lines(0, ls - 1, ls, false)[1] or ''
  return line:sub(cs, ce)
end

local function is_identifier(s)
  return s ~= '' and s:match('^[%a_][%w_]*$') ~= nil
end

function M.open(from_visual)
  local orig_win   = vim.api.nvim_get_current_win()
  local orig_bufnr = vim.api.nvim_get_current_buf()
  local orig_pos   = vim.api.nvim_win_get_cursor(0)
  local init_word  = from_visual and get_visual_selection() or nil
  init_word = (init_word and init_word ~= '') and init_word or vim.fn.expand('<cword>')

  -- Detect if LSP rename is available for this symbol
  local lsp_rename = false
  if is_identifier(init_word) then
    for _, c in ipairs(vim.lsp.get_clients({ bufnr = orig_bufnr })) do
      if c.server_capabilities.renameProvider then
        lsp_rename = true
        break
      end
    end
  end

  local Layout = require('nui.layout')
  local Popup  = require('nui.popup')

  local results = {}
  local focused = 'find'
  local stimer  = nil
  local alive   = false

  local find_pop = Popup({
    border      = { style = 'rounded', text = { top = ' 🔎 Find ', top_align = 'left' } },
    buf_options = { buftype = 'nofile', modifiable = true },
  })
  local replace_pop = Popup({
    border      = { style = 'rounded', text = { top = '  Replace ', top_align = 'left' } },
    buf_options = { buftype = 'nofile', modifiable = true },
  })
  local list_pop = Popup({
    border      = { style = 'rounded', text = { top = ' Results ', top_align = 'left' } },
    buf_options = { buftype = 'nofile', modifiable = false },
    win_options = { cursorline = true, wrap = false },
  })
  local hint_pop = Popup({
    border      = { style = 'none' },
    buf_options = { buftype = 'nofile', modifiable = false },
    win_options = { winhighlight = 'Normal:Comment' },
  })
  local preview_pop = Popup({
    border      = { style = 'rounded', text = { top = ' Preview ', top_align = 'left' } },
    buf_options = { buftype = 'nofile', modifiable = false },
    win_options = { wrap = false, cursorline = true },
  })

  local total_h = math.max(16, math.min(30, math.floor(vim.o.lines * 0.75)))
  local total_w = math.min(vim.o.columns - 4, 170)
  local left_w  = 48

  local layout = Layout(
    { relative = 'editor', position = '50%', size = { width = total_w, height = total_h } },
    Layout.Box({
      Layout.Box({
        Layout.Box({
          Layout.Box(find_pop,    { size = 3 }),
          Layout.Box(replace_pop, { size = 3 }),
          Layout.Box(list_pop,    { grow = 1 }),
        }, { dir = 'col', size = left_w }),
        Layout.Box(preview_pop, { grow = 1 }),
      }, { dir = 'row', grow = 1 }),
      Layout.Box(hint_pop, { size = 2 }),
    }, { dir = 'col' })
  )

  local ns = vim.api.nvim_create_namespace('charvim_rename_preview')

  local function get_find()
    return vim.api.nvim_buf_get_lines(find_pop.bufnr, 0, 1, false)[1] or ''
  end
  local function get_replace()
    return vim.api.nvim_buf_get_lines(replace_pop.bufnr, 0, 1, false)[1] or ''
  end

  local function update_preview(r)
    if not (alive and vim.api.nvim_win_is_valid(preview_pop.winid)) then return end
    vim.api.nvim_buf_clear_namespace(preview_pop.bufnr, ns, 0, -1)
    if not r then
      vim.bo[preview_pop.bufnr].modifiable = true
      vim.api.nvim_buf_set_lines(preview_pop.bufnr, 0, -1, false, {})
      vim.bo[preview_pop.bufnr].modifiable = false
      pcall(function() vim.wo[preview_pop.winid].winbar = '' end)
      return
    end

    local context = 8
    local lines, hl_row

    local buf = vim.fn.bufnr(r.filename)
    if buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) then
      local s = math.max(0, r.lnum - context - 1)
      lines   = vim.api.nvim_buf_get_lines(buf, s, r.lnum + context, false)
      hl_row  = r.lnum - 1 - s
    else
      local ok, all = pcall(vim.fn.readfile, r.filename)
      if not ok then
        vim.bo[preview_pop.bufnr].modifiable = true
        vim.api.nvim_buf_set_lines(preview_pop.bufnr, 0, -1, false, { '  (cannot read file)' })
        vim.bo[preview_pop.bufnr].modifiable = false
        return
      end
      local s = math.max(1, r.lnum - context)
      local e = math.min(#all, r.lnum + context)
      lines = {}
      for i = s, e do lines[#lines + 1] = all[i] end
      hl_row = r.lnum - s
    end

    vim.bo[preview_pop.bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(preview_pop.bufnr, 0, -1, false, lines)
    vim.bo[preview_pop.bufnr].modifiable = false

    -- Highlight the matched line and the matched text within it
    vim.api.nvim_buf_add_highlight(preview_pop.bufnr, ns, 'CursorLine', hl_row, 0, -1)
    local pat = get_find()
    if pat ~= '' then
      local col_s = (r.col or 1) - 1
      vim.api.nvim_buf_add_highlight(
        preview_pop.bufnr, ns, 'IncSearch', hl_row, col_s, col_s + #pat)
    end

    pcall(vim.api.nvim_win_set_cursor, preview_pop.winid, { hl_row + 1, 0 })
    pcall(vim.fn.win_execute, preview_pop.winid, 'normal! zz')

    local short = vim.fn.fnamemodify(r.filename, ':~:.')
    pcall(function() vim.wo[preview_pop.winid].winbar = ' ' .. short .. ':' .. r.lnum end)

    local ft = vim.filetype.match({ filename = r.filename }) or ''
    if ft ~= '' and vim.bo[preview_pop.bufnr].filetype ~= ft then
      vim.bo[preview_pop.bufnr].filetype = ft
    end
  end

  local function set_list(lines)
    vim.bo[list_pop.bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(list_pop.bufnr, 0, -1, false, lines)
    vim.bo[list_pop.bufnr].modifiable = false
  end

  local function update_results(new_results)
    results = new_results
    if #results == 0 then
      set_list({ '  (no matches)' })
      update_preview(nil)
    else
      local lines = {}
      for _, r in ipairs(results) do
        lines[#lines + 1] = string.format('  %s:%d  %s',
          vim.fn.fnamemodify(r.filename, ':~:.'), r.lnum, r.text)
      end
      set_list(lines)
      -- Show preview for the currently highlighted row (or first result)
      local row = vim.api.nvim_win_is_valid(list_pop.winid)
        and vim.api.nvim_win_get_cursor(list_pop.winid)[1] or 1
      update_preview(results[row] or results[1])
    end
  end

  local function run_search(pat)
    if pat == '' then update_results({}); return end
    local cwd = vim.fn.getcwd()
    vim.fn.jobstart(
      { 'rg', '--line-number', '--column', '--no-heading', '--color=never', '--', pat, '.' },
      {
        cwd             = cwd,
        stdout_buffered = true,
        on_stdout = function(_, data)
          local found = {}
          for _, line in ipairs(data or {}) do
            if line ~= '' then
              local f, ln, col, txt = line:match('^(.-):(%d+):(%d+):(.*)$')
              if f then
                found[#found + 1] = {
                  filename = vim.fn.fnamemodify(cwd .. '/' .. f, ':p'),
                  lnum     = tonumber(ln),
                  col      = tonumber(col),
                  text     = txt:match('^%s*(.-)%s*$') or txt,
                }
              end
            end
          end
          vim.schedule(function()
            if alive and vim.api.nvim_win_is_valid(list_pop.winid) then
              update_results(found)
            end
          end)
        end,
      }
    )
  end

  local function debounce(pat)
    if stimer then vim.fn.timer_stop(stimer) end
    stimer = vim.fn.timer_start(200, function()
      stimer = nil
      vim.schedule(function() run_search(pat) end)
    end)
  end

  local function focus_find()
    focused = 'find'
    vim.api.nvim_set_current_win(find_pop.winid)
    vim.cmd('startinsert!')
  end
  local function focus_replace()
    focused = 'replace'
    vim.api.nvim_set_current_win(replace_pop.winid)
    vim.cmd('startinsert!')
  end
  local function focus_list()
    focused = 'list'
    vim.api.nvim_set_current_win(list_pop.winid)
    local row = vim.api.nvim_win_get_cursor(list_pop.winid)[1]
    update_preview(results[row])
  end
  local function cycle()
    if     focused == 'find'    then focus_replace()
    elseif focused == 'replace' then focus_list()
    else                             focus_find() end
  end

  local function close()
    if not alive then return end
    alive = false
    if stimer then vim.fn.timer_stop(stimer); stimer = nil end
    layout:unmount()
    -- Restore normal mode in the underlying window after the popup is gone
    vim.schedule(function()
      if vim.api.nvim_get_mode().mode:sub(1, 1) == 'i' then
        vim.cmd('stopinsert')
      end
    end)
  end

  -- Y: accept all occurrences (LSP rename when applicable, else regex via cfdo)
  local function accept_all()
    local pat = get_find()
    local rep = get_replace()
    if pat == '' then vim.notify('Find field is empty', vim.log.levels.WARN); return end
    if #results == 0 then vim.notify('No matches', vim.log.levels.WARN); return end

    -- Use LSP rename when: LSP available, find term unchanged from original symbol
    if lsp_rename and pat == init_word and is_identifier(pat) then
      local new_name   = rep ~= '' and rep or nil
      local saved_win  = orig_win
      local saved_pos  = orig_pos
      close()
      -- Defer past the close() stopinsert callback so the window is fully settled
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(saved_win) then
          vim.api.nvim_set_current_win(saved_win)
          vim.api.nvim_win_set_cursor(saved_win, saved_pos)
        end
        vim.lsp.buf.rename(new_name)
      end)
      return
    end

    -- Regex replace across all matched files via quickfix
    local qfl = vim.tbl_map(function(r)
      return { filename = r.filename, lnum = r.lnum, col = r.col, text = r.text }
    end, results)
    close()
    vim.fn.setqflist(qfl)
    local ep = vim.fn.escape(pat, '/\\')
    local er = vim.fn.escape(rep, '/\\&')
    vim.cmd('cfdo %s/\\V' .. ep .. '/' .. er .. '/ge | update')
    vim.cmd('cclose')
  end

  -- y: accept the single occurrence under the list cursor
  local function accept_one()
    local row = vim.api.nvim_win_get_cursor(list_pop.winid)[1]
    local r   = results[row]
    if not r then return end
    local pat = get_find()
    local rep = get_replace()
    if pat == '' then return end

    local ep = '\\V' .. vim.fn.escape(pat, '\\')
    local er = vim.fn.escape(rep, '\\&')

    local buf = vim.fn.bufnr(r.filename)
    if buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) then
      local line = vim.api.nvim_buf_get_lines(buf, r.lnum - 1, r.lnum, false)[1] or ''
      vim.api.nvim_buf_set_lines(buf, r.lnum - 1, r.lnum, false,
        { vim.fn.substitute(line, ep, er, '') })
    else
      local ok, lines = pcall(vim.fn.readfile, r.filename)
      if not ok or not lines[r.lnum] then return end
      lines[r.lnum] = vim.fn.substitute(lines[r.lnum], ep, er, '')
      vim.fn.writefile(lines, r.filename)
    end

    table.remove(results, row)
    update_results(results)
  end

  local function jump()
    local row = vim.api.nvim_win_get_cursor(list_pop.winid)[1]
    local r   = results[row]
    if not r then return end
    close()
    vim.cmd('edit ' .. vim.fn.fnameescape(r.filename))
    vim.api.nvim_win_set_cursor(0, { r.lnum, (r.col or 1) - 1 })
  end

  local function bmap(pop, modes, key, fn)
    for _, m in ipairs(modes) do
      pop:map(m, key, fn, { noremap = true, silent = true })
    end
  end

  layout:mount()
  alive = true

  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
    buffer   = list_pop.bufnr,
    callback = function()
      if not alive then return end
      local row = vim.api.nvim_win_get_cursor(list_pop.winid)[1]
      update_preview(results[row])
    end,
  })

  local mode_label = lsp_rename and '  · LSP rename' or '  · Regex'
  vim.bo[hint_pop.bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(hint_pop.bufnr, 0, -1, false, {
    '',
    '  <Tab> cycle · j/k list · y accept · Y accept all · <CR> jump · <Esc> close' .. mode_label,
  })
  vim.bo[hint_pop.bufnr].modifiable = false

  vim.api.nvim_buf_set_lines(find_pop.bufnr, 0, -1, false, { init_word })

  vim.api.nvim_create_autocmd({ 'TextChangedI', 'TextChanged' }, {
    buffer   = find_pop.bufnr,
    callback = function() debounce(get_find()) end,
  })

  -- Find panel: Tab cycles, Esc closes, Y (normal) accepts all
  bmap(find_pop,    { 'i', 'n' }, '<Tab>', cycle)
  bmap(find_pop,    { 'i', 'n' }, '<Esc>', close)
  bmap(find_pop,    { 'n' },      'Y',     accept_all)

  -- Replace panel: Tab cycles, Esc closes, CR/Y accepts all
  bmap(replace_pop, { 'i', 'n' }, '<Tab>', cycle)
  bmap(replace_pop, { 'i', 'n' }, '<Esc>', close)
  bmap(replace_pop, { 'i', 'n' }, '<CR>',  accept_all)
  bmap(replace_pop, { 'n' },      'Y',     accept_all)

  local function list_down()
    local row = vim.api.nvim_win_get_cursor(list_pop.winid)[1]
    if row < #results then vim.api.nvim_win_set_cursor(list_pop.winid, { row + 1, 0 }) end
  end
  local function list_up()
    local row = vim.api.nvim_win_get_cursor(list_pop.winid)[1]
    if row > 1 then vim.api.nvim_win_set_cursor(list_pop.winid, { row - 1, 0 }) end
  end

  -- List panel: all keys mapped for both modes (mode-switching in nui is unreliable)
  bmap(list_pop,    { 'i', 'n' }, '<Tab>',  cycle)
  bmap(list_pop,    { 'i', 'n' }, '<Esc>',  close)
  bmap(list_pop,    { 'i', 'n' }, 'q',      close)
  bmap(list_pop,    { 'i', 'n' }, '<CR>',   jump)
  bmap(list_pop,    { 'i', 'n' }, 'y',      accept_one)
  bmap(list_pop,    { 'i', 'n' }, 'Y',      accept_all)
  bmap(list_pop,    { 'i', 'n' }, 'j',      list_down)
  bmap(list_pop,    { 'i', 'n' }, 'k',      list_up)
  bmap(list_pop,    { 'i', 'n' }, '<Down>', list_down)
  bmap(list_pop,    { 'i', 'n' }, '<Up>',   list_up)

  run_search(init_word)
  focus_find()
end

function M.setup()
  vim.api.nvim_create_user_command('Find', function(opts)
    M.open(opts.range > 0)
  end, { desc = 'Find & replace / rename', range = true })

  vim.keymap.set('n', '<leader>S', function() M.open(false) end, { desc = 'Find & replace / rename' })
  vim.keymap.set('v', '<leader>S', function() M.open(true) end,  { desc = 'Find & replace / rename (selection)' })
end

M.setup()
return M
