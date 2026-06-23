local M = {}

local themes = {
  {
    name = 'Auto',
    setup = function()
      vim.cmd.colorscheme('default')
    end,
  },
  {
    name = 'Knew-pines',
    setup = function()
      require('rose-pine').setup({
        variant = 'main',
        disable_background = true,
        disable_float_background = true,
        disable_italics = false,
        highlight_groups = {
          CursorLineNr = { fg = 'gold', bold = true },
        },
      })
      vim.cmd.colorscheme('rose-pine')
    end,
  },
  {
    name = 'Noir-cat',
    setup = function()
      vim.cmd.colorscheme('noir-cat')
    end,
  },
  {
    name = 'Tokyo Night',
    setup = function()
      require('tokyonight').setup({ style = 'night', transparent = true })
      vim.cmd.colorscheme('tokyonight')
    end,
  },
  {
    name = 'Catppuccin',
    setup = function()
      require('catppuccin').setup({ flavour = 'mocha', transparent_background = true })
      vim.cmd.colorscheme('catppuccin')
    end,
  },
  {
    name = 'Gruvbox',
    setup = function()
      require('gruvbox').setup({ transparent_mode = true })
      vim.cmd.colorscheme('gruvbox')
    end,
  },
  {
    name = 'Habamax',
    setup = function()
      vim.cmd.colorscheme('habamax')
    end,
  },
}

local current_theme_name = nil
local persist_path = vim.fn.stdpath('data') .. '/charvim_theme'

local function save_theme(name)
  local f = io.open(persist_path, 'w')
  if f then
    f:write(name)
    f:close()
  end
end

local function load_saved_theme()
  local f = io.open(persist_path, 'r')
  if not f then return nil end
  local name = f:read('*l')
  f:close()
  return name
end

local function apply_transparent_background()
  vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
  vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
end

local function apply_theme(theme, persist)
  theme.setup()
  apply_transparent_background()
  current_theme_name = theme.name
  if persist then save_theme(theme.name) end
end

local function restore_theme(name)
  for _, t in ipairs(themes) do
    if t.name == name then
      apply_theme(t)
      return
    end
  end
end

function M.select_theme()
  local ok, pickers = pcall(require, 'telescope.pickers')
  if not ok then
    -- fallback when telescope is unavailable
    local items = vim.tbl_map(function(t) return t.name end, themes)
    vim.ui.select(items, {
      prompt = 'Select theme',
      format_item = function(item)
        return (item == current_theme_name and '▸ ' or '  ') .. item
      end,
    }, function(choice)
      if not choice then return end
      for _, t in ipairs(themes) do
        if t.name == choice then apply_theme(t, true) end
      end
    end)
    return
  end

  local finders     = require('telescope.finders')
  local conf        = require('telescope.config').values
  local actions     = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  local saved = current_theme_name or 'Auto'

  pickers.new({
    layout_strategy  = 'center',
    layout_config    = { width = 0.28, height = 0.45 },
    sorting_strategy = 'ascending',
  }, {
    prompt_title = '  Themes',
    previewer    = false,
    finder = finders.new_table({
      results = themes,
      entry_maker = function(theme)
        return {
          value   = theme,
          display = (theme.name == saved and ' • ' or '   ') .. theme.name,
          ordinal = theme.name,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      local function preview_selected()
        local entry = action_state.get_selected_entry()
        if entry then
          entry.value.setup()
          apply_transparent_background()
        end
      end

      local function do_cancel()
        restore_theme(saved)
        actions.close(prompt_bufnr)
      end

      -- wrap movement to live-preview each theme
      map('i', '<C-n>',  function() actions.move_selection_next(prompt_bufnr);     preview_selected() end)
      map('i', '<C-p>',  function() actions.move_selection_previous(prompt_bufnr); preview_selected() end)
      map('i', '<Down>', function() actions.move_selection_next(prompt_bufnr);     preview_selected() end)
      map('i', '<Up>',   function() actions.move_selection_previous(prompt_bufnr); preview_selected() end)
      map('n', 'j',      function() actions.move_selection_next(prompt_bufnr);     preview_selected() end)
      map('n', 'k',      function() actions.move_selection_previous(prompt_bufnr); preview_selected() end)

      -- confirm
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if entry then
          apply_theme(entry.value, true)
        else
          restore_theme(saved)
        end
      end)

      -- cancel — restore original
      map('i', '<Esc>', do_cancel)
      map('n', 'q',     do_cancel)
      map('n', '<Esc>', do_cancel)

      return true
    end,
  }):find()
end

function M.set_theme(name)
  for _, t in ipairs(themes) do
    if t.name:lower() == name:lower() then
      apply_theme(t, true)
      return
    end
  end
  vim.notify('Unknown theme: ' .. name, vim.log.levels.ERROR)
end

function M.setup()
  vim.schedule(function()
    local saved = load_saved_theme()
    if saved then
      restore_theme(saved)
    else
      apply_theme(themes[1])
    end
  end)

  vim.api.nvim_create_user_command('ThemeSelect', M.select_theme, { desc = 'Open theme picker' })
  vim.api.nvim_create_user_command('Theme', function(opts)
    M.set_theme(opts.args)
  end, { nargs = 1, desc = 'Switch to theme by name' })
end

M.setup()

return M
