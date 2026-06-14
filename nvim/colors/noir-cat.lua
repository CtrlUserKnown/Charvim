vim.g.colors_name = 'noir-cat'

local c = {
  bg           = '#1a1a1a',
  fg           = '#d4d4d4',
  cursor       = '#ffffff',
  sel_bg       = '#313244',
  sel_fg       = '#d4d4d4',
  black        = '#1a1a1a',
  red          = '#f38ba8',
  green        = '#a6e3a1',
  yellow       = '#f9e2af',
  blue         = '#89b4fa',
  purple       = '#cba6f7',
  cyan         = '#89dceb',
  white        = '#d4d4d4',
  bright_black = '#585b70',
  bright_red   = '#f38ba8',
  bright_green = '#a6e3a1',
  bright_yellow= '#f9e2af',
  bright_blue  = '#89b4fa',
  bright_purple= '#cba6f7',
  bright_cyan  = '#89dceb',
  bright_white = '#ffffff',
  surface0     = '#313244',
  surface1     = '#45475a',
  surface2     = '#585b70',
  overlay0     = '#6c7086',
  overlay1     = '#7f849c',
  subtext0     = '#a6adc8',
  subtext1     = '#bac2de',
  lavender     = '#89b4fa',
  mauve        = '#cba6f7',
  maroon       = '#eba0ac',
  peach        = '#fab387',
  pink         = '#f5c2e7',
  flamingo     = '#f2cdcd',
  rosewater    = '#f5e0dc',
  teal         = '#89dceb',
  sky          = '#89dceb',
  sapphire     = '#74c7ec',
  none         = 'NONE',
}

local hl = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

--- Editor & UI ---
hl('Normal',        { fg = c.fg, bg = c.bg })
hl('NormalFloat',   { fg = c.fg, bg = c.bg })
hl('NormalSB',      { fg = c.fg, bg = c.bg })
hl('EndOfBuffer',   { fg = c.bg })
hl('NonText',       { fg = c.overlay0 })
hl('Whitespace',    { fg = c.surface2 })
hl('Conceal',       { fg = c.overlay0 })
hl('Cursor',        { bg = c.cursor, fg = c.bg })
hl('CursorLine',    { bg = c.surface0 })
hl('CursorLineNr',  { fg = c.peach, bold = true })
hl('CursorColumn',  { bg = c.surface0 })
hl('ColorColumn',   { bg = c.surface0 })
hl('SignColumn',    { bg = c.bg })
hl('LineNr',        { fg = c.surface2 })
hl('LineNrAbove',   { fg = c.surface2 })
hl('LineNrBelow',   { fg = c.surface2 })
hl('Folded',        { fg = c.subtext0, bg = c.surface0 })
hl('FoldColumn',    { fg = c.overlay0, bg = c.bg })
hl('Visual',        { bg = c.selection_bg })
hl('VisualNOS',     { bg = c.surface0 })
hl('Search',        { fg = c.bg, bg = c.lavender })
hl('IncSearch',     { fg = c.bg, bg = c.teal })
hl('Substitute',    { fg = c.bg, bg = c.red })
hl('MatchParen',    { fg = c.mauve, bg = c.surface2 })
hl('Pmenu',         { fg = c.fg, bg = c.surface0 })
hl('PmenuSel',      { fg = c.bg, bg = c.lavender })
hl('PmenuSbar',     { bg = c.surface0 })
hl('PmenuThumb',    { bg = c.surface2 })
hl('Question',      { fg = c.mauve })
hl('ModeMsg',       { fg = c.fg })
hl('MsgArea',       { fg = c.fg, bg = c.bg })
hl('MsgSeparator',  { fg = c.surface0 })
hl('MoreMsg',       { fg = c.mauve })
hl('ErrorMsg',      { fg = c.red })
hl('WarningMsg',    { fg = c.yellow })
hl('QuickFixLine',  { bg = c.surface0 })

--- Tabs & Windows ---
hl('TabLine',       { fg = c.overlay0, bg = c.surface0 })
hl('TabLineFill',   { bg = c.surface0 })
hl('TabLineSel',    { fg = c.fg, bg = c.bg })
hl('WinSeparator',  { fg = c.surface2 })
hl('WinBar',        { fg = c.fg, bg = c.bg })
hl('WinBarNC',      { fg = c.overlay0, bg = c.surface0 })
hl('FloatBorder',   { fg = c.surface2 })
hl('FloatTitle',    { fg = c.lavender })
hl('Title',         { fg = c.lavender, bold = true })
hl('StatusLine',    { fg = c.fg, bg = c.surface1 })
hl('StatusLineNC',  { fg = c.overlay0, bg = c.surface0 })
hl('StatusLineTerm',    { fg = c.fg, bg = c.surface1 })
hl('StatusLineTermNC',  { fg = c.overlay0, bg = c.surface0 })

--- Spelling ---
hl('SpellBad',    { sp = c.red, undercurl = true })
hl('SpellCap',    { sp = c.yellow, undercurl = true })
hl('SpellLocal',  { sp = c.lavender, undercurl = true })
hl('SpellRare',   { sp = c.purple, undercurl = true })

--- Diffs ---
hl('DiffAdd',     { fg = c.green, bg = c.surface0 })
hl('DiffChange',  { fg = c.yellow, bg = c.surface0 })
hl('DiffDelete',  { fg = c.red, bg = c.surface0 })
hl('DiffText',    { fg = c.lavender, bg = c.surface0 })

--- Syntax ---
hl('Comment',        { fg = c.overlay0, italic = true })
hl('Constant',       { fg = c.peach })
hl('String',         { fg = c.green })
hl('Character',      { fg = c.green })
hl('Number',         { fg = c.peach })
hl('Boolean',        { fg = c.peach })
hl('Float',          { fg = c.peach })
hl('Identifier',     { fg = c.mauve })
hl('Function',       { fg = c.lavender })
hl('Statement',      { fg = c.mauve })
hl('Conditional',    { fg = c.mauve })
hl('Repeat',         { fg = c.mauve })
hl('Label',          { fg = c.mauve })
hl('Operator',       { fg = c.rosewater })
hl('Keyword',        { fg = c.mauve })
hl('Exception',      { fg = c.mauve })
hl('PreProc',        { fg = c.mauve })
hl('Include',        { fg = c.lavender })
hl('Define',         { fg = c.mauve })
hl('Macro',          { fg = c.mauve })
hl('PreCondit',      { fg = c.mauve })
hl('Type',           { fg = c.yellow })
hl('StorageClass',   { fg = c.yellow })
hl('Structure',      { fg = c.yellow })
hl('Typedef',        { fg = c.yellow })
hl('Special',        { fg = c.lavender })
hl('SpecialChar',    { fg = c.lavender })
hl('Tag',            { fg = c.lavender })
hl('Delimiter',      { fg = c.fg })
hl('SpecialComment', { fg = c.overlay0 })
hl('Debug',          { fg = c.red })
hl('Underlined',     { fg = c.lavender, underline = true })
hl('Ignore',         { fg = c.overlay0 })
hl('Error',          { fg = c.red })
hl('Todo',           { fg = c.bg, bg = c.yellow })

--- Treesitter (@ groups) ---
hl('@variable',            { fg = c.fg })
hl('@variable.builtin',    { fg = c.red })
hl('@constant',            { fg = c.peach })
hl('@constant.builtin',    { fg = c.peach })
hl('@constant.macro',      { fg = c.peach })
hl('@module',              { fg = c.red })
hl('@module.builtin',      { fg = c.red })
hl('@label',               { fg = c.mauve })
hl('@symbol',              { fg = c.teal })
hl('@string',              { fg = c.green })
hl('@string.documentation',{ fg = c.green })
hl('@string.regexp',       { fg = c.teal })
hl('@string.escape',       { fg = c.teal })
hl('@string.special',      { fg = c.teal })
hl('@character',           { fg = c.green })
hl('@character.special',   { fg = c.teal })
hl('@number',              { fg = c.peach })
hl('@boolean',             { fg = c.peach })
hl('@float',               { fg = c.peach })
hl('@function',            { fg = c.lavender })
hl('@function.builtin',    { fg = c.red })
hl('@function.macro',      { fg = c.lavender })
hl('@parameter',           { fg = c.peach })
hl('@method',              { fg = c.lavender })
hl('@field',               { fg = c.teal })
hl('@property',            { fg = c.teal })
hl('@constructor',         { fg = c.mauve })
hl('@conditional',         { fg = c.mauve })
hl('@repeat',              { fg = c.mauve })
hl('@operator',            { fg = c.rosewater })
hl('@keyword',             { fg = c.mauve })
hl('@keyword.function',    { fg = c.mauve })
hl('@keyword.operator',    { fg = c.mauve })
hl('@keyword.return',      { fg = c.mauve })
hl('@exception',           { fg = c.mauve })
hl('@type',                { fg = c.yellow })
hl('@type.builtin',        { fg = c.yellow })
hl('@type.qualifier',      { fg = c.mauve })
hl('@type.definition',     { fg = c.yellow })
hl('@include',             { fg = c.lavender })
hl('@attribute',           { fg = c.mauve })
hl('@tag',                 { fg = c.mauve })
hl('@tag.attribute',       { fg = c.teal })
hl('@tag.delimiter',       { fg = c.overlay0 })
hl('@punctuation.delimiter', { fg = c.overlay0 })
hl('@punctuation.bracket',   { fg = c.fg })
hl('@punctuation.special',   { fg = c.mauve })
hl('@comment',             { link = 'Comment' })
hl('@comment.error',       { fg = c.red })
hl('@comment.warning',     { fg = c.yellow })
hl('@comment.todo',        { link = 'Todo' })
hl('@comment.note',        { fg = c.lavender })
hl('@markup.strong',       { bold = true })
hl('@markup.italic',       { italic = true })
hl('@markup.strikethrough',{ strikethrough = true })
hl('@markup.underline',    { underline = true })
hl('@markup.heading',      { fg = c.lavender, bold = true })
hl('@markup.quote',        { fg = c.teal })
hl('@markup.math',         { fg = c.teal })
hl('@markup.link',         { fg = c.lavender, underline = true })
hl('@markup.link.url',     { fg = c.teal, underline = true })
hl('@markup.link.label',   { fg = c.lavender })
hl('@markup.list',         { fg = c.mauve })
hl('@markup.raw',          { fg = c.green })
hl('@diff.plus',           { link = 'DiffAdd' })
hl('@diff.minus',          { link = 'DiffDelete' })
hl('@diff.delta',          { link = 'DiffChange' })
hl('@none',                {})
hl('@error',               { fg = c.red })
hl('@warning',             { fg = c.yellow })
hl('@hint',                { fg = c.teal })
hl('@info',                { fg = c.lavender })
hl('@todo',                { link = 'Todo' })

--- LSP & Diagnostics ---
hl('DiagnosticError',              { fg = c.red })
hl('DiagnosticWarn',               { fg = c.yellow })
hl('DiagnosticInfo',               { fg = c.lavender })
hl('DiagnosticHint',               { fg = c.teal })
hl('DiagnosticOk',                 { fg = c.green })
hl('DiagnosticUnderlineError',     { sp = c.red, undercurl = true })
hl('DiagnosticUnderlineWarn',      { sp = c.yellow, undercurl = true })
hl('DiagnosticUnderlineInfo',      { sp = c.lavender, undercurl = true })
hl('DiagnosticUnderlineHint',      { sp = c.teal, undercurl = true })
hl('DiagnosticVirtualTextError',   { fg = c.red })
hl('DiagnosticVirtualTextWarn',    { fg = c.yellow })
hl('DiagnosticVirtualTextInfo',    { fg = c.lavender })
hl('DiagnosticVirtualTextHint',    { fg = c.teal })
hl('DiagnosticFloatingError',      { fg = c.red })
hl('DiagnosticFloatingWarn',       { fg = c.yellow })
hl('DiagnosticFloatingInfo',       { fg = c.lavender })
hl('DiagnosticFloatingHint',       { fg = c.teal })
hl('DiagnosticSignError',          { fg = c.red })
hl('DiagnosticSignWarn',           { fg = c.yellow })
hl('DiagnosticSignInfo',           { fg = c.lavender })
hl('DiagnosticSignHint',           { fg = c.teal })
hl('LspReferenceText',             { bg = c.surface0 })
hl('LspReferenceRead',             { bg = c.surface0 })
hl('LspReferenceWrite',            { bg = c.surface0 })
hl('LspCodeLens',                  { fg = c.overlay0 })
hl('LspCodeLensSeparator',         { fg = c.overlay0 })
hl('LspSignatureActiveParameter',  { fg = c.peach, bold = true })
hl('LspInlayHint',                 { fg = c.overlay0, bg = c.surface0 })
