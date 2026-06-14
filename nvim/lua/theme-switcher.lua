local M = {}

local themes = {
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
    name = 'System Theme',
    setup = function()
      vim.cmd.colorscheme('default')
    end,
  },
  {
    name = 'Tokyo Night',
    setup = function()
      require('tokyonight').setup({
        style = 'night',
        transparent = true,
      })
      vim.cmd.colorscheme('tokyonight')
    end,
  },
  {
    name = 'Catppuccin',
    setup = function()
      require('catppuccin').setup({
        flavour = 'mocha',
        transparent_background = true,
      })
      vim.cmd.colorscheme('catppuccin')
    end,
  },
  {
    name = 'Gruvbox',
    setup = function()
      require('gruvbox').setup({
        transparent_mode = true,
      })
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

local colors_name_map = {
  ['rose-pine']  = 'Knew-pines',
  ['noir-cat']   = 'Noir-cat',
  ['default']    = 'System Theme',
  ['tokyonight'] = 'Tokyo Night',
  ['catppuccin'] = 'Catppuccin',
  ['gruvbox']    = 'Gruvbox',
  ['habamax']    = 'Habamax',
}

local function apply_transparent_background()
  vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
  vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
end

local function apply_theme(theme)
  theme.setup()
  apply_transparent_background()
  vim.g.colors_name = theme.name:lower():gsub(' ', '-')
end

function M.select_theme()
  local current = colors_name_map[vim.g.colors_name] or themes[1].name
  local items = vim.tbl_map(function(t) return t.name end, themes)
  vim.ui.select(items, {
    prompt = 'Select theme',
    format_item = function(item)
      return (item == current and '▸ ' or '  ') .. item
    end,
  }, function(choice)
    if not choice then return end
    for _, theme in ipairs(themes) do
      if theme.name == choice then
        apply_theme(theme)
        return
      end
    end
  end)
end

function M.set_theme(name)
  for _, theme in ipairs(themes) do
    if theme.name:lower() == name:lower() then
      apply_theme(theme)
      return
    end
  end
  vim.notify('Unknown theme: ' .. name, vim.log.levels.ERROR)
end

function M.setup()
  vim.schedule(function()
    if not vim.g.colors_name or vim.g.colors_name == '' then
      for _, theme in ipairs(themes) do
        if theme.name == 'Knew-pines' then
          apply_theme(theme)
          break
        end
      end
    else
      apply_transparent_background()
    end
  end)

  vim.api.nvim_create_user_command('ThemeSelect', function()
    M.select_theme()
  end, { desc = 'Open theme picker' })

  vim.api.nvim_create_user_command('Theme', function(opts)
    M.set_theme(opts.args)
  end, { nargs = 1, desc = 'Switch to theme by name' })
end

M.setup()

return M
