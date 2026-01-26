-- My own colorscheme [NAGI 凪]

-- Reset highlighting.
vim.cmd.highlight 'clear'
if vim.fn.exists 'syntax_on' then
  vim.cmd.syntax 'reset'
end

-- Set termguicolors to true
vim.o.termguicolors = true

-- Set colorscheme name
vim.g.colors_name = 'nagi'

local colors = {
  none = 'NONE',
  bg = '#101314',
  fg = '#e2e5e6',
  color0 = '#1c2021',
  color1 = '#d95762',
  color2 = '#a6d98d',
  color3 = '#f38c61',
  color4 = '#95b7e6',
  color5 = '#d282d9',
  color6 = '#92e2f2',
  color7 = '#d5d7d8',
  color8 = '#2c3334',
  color9 = '#e65c68',
  color10 = '#b0e695',
  color11 = '#ff9366',
  color12 = '#9ec1f3',
  color13 = '#de89e5',
  color14 = '#98eeff',
  color15 = '#eef1f2',
  black = '#000000',
  turquoise = '#41d9cb',
  faded_hot_pink = '#f385bd',
  fg_grey = '#414c4d',
  fg_grey_statusline = '#566466',
  bg_grey_bright = '#3a4344',
  fg_yellow = '#cdb852',
  bg_error = '#4d2125',
  bg_warning = '#4c441e',
  bg_info = '#303c4c',
  bg_hint = '#2d484d',
  bg_orange = '#512f23',
}

-- Terminal colors.
vim.g.terminal_color_0 = colors.color0
vim.g.terminal_color_1 = colors.color1
vim.g.terminal_color_2 = colors.color2
vim.g.terminal_color_3 = colors.color3
vim.g.terminal_color_4 = colors.color4
vim.g.terminal_color_5 = colors.color5
vim.g.terminal_color_6 = colors.color6
vim.g.terminal_color_7 = colors.color7
vim.g.terminal_color_8 = colors.color8
vim.g.terminal_color_9 = colors.color9
vim.g.terminal_color_10 = colors.color10
vim.g.terminal_color_11 = colors.color11
vim.g.terminal_color_12 = colors.color12
vim.g.terminal_color_13 = colors.color13
vim.g.terminal_color_14 = colors.color14
vim.g.terminal_color_15 = colors.color15
vim.g.terminal_color_background = colors.bg
vim.g.terminal_color_foreground = colors.fg

-- Groups used for my sexy statusline.
---@type table<string, vim.api.keyset.highlight>
local statusline_groups = {}
for mode, color in pairs {
  Normal = 'color4',
  Pending = 'faded_hot_pink',
  Visual = 'color5',
  Insert = 'color2',
  Command = 'color3',
  Other = 'faded_hot_pink',
} do
  statusline_groups['StatuslineMode' .. mode] = { fg = colors.black, bg = colors[color] }
  statusline_groups['StatuslineModeSeparator' .. mode] = { fg = colors[color], bg = colors.color8 }
  statusline_groups['StatuslineModeSeparatorBlendedBg' .. mode] = { fg = colors[color], bg = colors.bg }
end
statusline_groups = vim.tbl_extend('error', statusline_groups, {
  StatuslineItalic = { fg = colors.fg_grey_statusline, bg = colors.color8, italic = true },
  StatuslineComment = { fg = colors.fg_grey_statusline, bg = colors.color8 },
  StatuslineSpinner = { fg = colors.color3, bg = colors.color8, bold = true },
  StatuslineTitle = { fg = colors.color15, bg = colors.color8, bold = true },
  StatuslineModified = { fg = colors.color9, bg = colors.color8, bold = true },
  StatuslineCwdIcon = { fg = colors.black, bg = colors.color3 },
  StatuslineCwdText = { fg = colors.color3, bg = colors.color8 },
  StatuslineCwdSeparator = { fg = colors.color3, bg = colors.color8 },
  StatuslineGit = { fg = colors.color5, bg = colors.color8, italic = true },
  StatuslinePosition = { fg = colors.color5, bg = colors.color8, italic = true },
})

---@type table<string, vim.api.keyset.highlight>
local groups = vim.tbl_extend('error', statusline_groups, {
  -- UI Elements
  Comment = { fg = colors.fg_grey, italic = true }, -- any comment
  ColorColumn = { bg = colors.color8 }, -- used for the columns set with 'colorcolumn'
  Conceal = { fg = colors.fg_grey }, -- placeholder characters substituted for concealed text
  Cursor = { fg = colors.bg, bg = colors.fg }, -- character under the cursor
  lCursor = { fg = colors.bg, bg = colors.fg }, -- the character under the cursor when |language-mapping| is used
  CursorIM = { fg = colors.bg, bg = colors.fg }, -- like Cursor, but used when in IME mode
  CursorColumn = { bg = colors.color8 }, -- Screen-column at the cursor, when 'cursorcolumn' is set
  CursorLine = { bg = colors.color8 }, -- Screen-line at the cursor, when 'cursorline' is set
  Directory = { fg = colors.color4 }, -- directory names (and other special names in listings)
  DiffAdd = { bg = colors.bg_hint }, -- diff mode: Added line
  DiffChange = { bg = colors.bg_warning }, -- diff mode: Changed line
  DiffDelete = { bg = colors.bg_error }, -- diff mode: Deleted line
  DiffText = { bg = colors.bg_info }, -- diff mode: Changed text within a changed line
  EndOfBuffer = { fg = colors.bg }, -- filler lines (~) after the end of the buffer
  ErrorMsg = { fg = colors.color1 }, -- error messages on the command line
  VertSplit = { fg = colors.fg_grey }, -- the column separating vertically split windows
  WinSeparator = { fg = colors.fg_grey, bold = true }, -- the column separating vertically split windows
  Folded = { fg = colors.color4, bg = colors.color8 }, -- line used for closed folds
  FoldColumn = { bg = colors.bg, fg = colors.fg_grey }, -- 'foldcolumn'
  SignColumn = { bg = colors.bg, fg = colors.fg_grey }, -- column where |signs| are displayed
  SignColumnSB = { bg = colors.bg, fg = colors.fg_grey }, -- column where |signs| are displayed
  Substitute = { bg = colors.color1, fg = colors.bg }, -- |:substitute| replacement text highlighting
  LineNr = { fg = colors.fg_grey }, -- Line number for ":number" and ":#" commands
  CursorLineNr = { fg = colors.color3, bold = true }, -- Like LineNr when 'cursorline' is set
  LineNrAbove = { fg = colors.fg_grey },
  LineNrBelow = { fg = colors.fg_grey },
  MatchParen = { fg = colors.color3, bold = true }, -- The character under the cursor or just before it, if it is a paired bracket
  ModeMsg = { fg = colors.fg, bold = true }, -- 'showmode' message (e.g., "-- INSERT -- ")
  MsgArea = { fg = colors.fg }, -- Area for messages and cmdline
  MoreMsg = { fg = colors.color4 }, -- |more-prompt|
  NonText = { fg = colors.fg_grey }, -- '@' at the end of the window, characters from 'showbreak'
  Normal = { fg = colors.fg, bg = colors.bg }, -- normal text
  NormalNC = { fg = colors.fg, bg = colors.bg }, -- normal text in non-current windows
  NormalSB = { fg = colors.fg, bg = colors.bg }, -- normal text in sidebar
  NormalFloat = { fg = colors.fg, bg = colors.bg }, -- Normal text in floating windows
  FloatBorder = { fg = colors.fg_grey, bg = colors.bg },
  FloatTitle = { fg = colors.color4, bg = colors.bg },
  Pmenu = { bg = colors.color8, fg = colors.fg }, -- Popup menu: normal item
  PmenuMatch = { bg = colors.color8, fg = colors.color3 }, -- Popup menu: Matched text in normal item
  PmenuSel = { bg = colors.bg_grey_bright }, -- Popup menu: selected item (highlight over color8)
  PmenuMatchSel = { bg = colors.bg_grey_bright, fg = colors.color3 }, -- Popup menu: Matched text in selected item
  PmenuSbar = { bg = colors.color8 }, -- Popup menu: scrollbar
  PmenuThumb = { bg = colors.fg_grey }, -- Popup menu: Thumb of the scrollbar
  Question = { fg = colors.color4 }, -- |hit-enter| prompt and yes/no questions
  QuickFixLine = { bg = colors.bg_grey_bright, bold = true }, -- Current |quickfix| item in the quickfix window (highlight over color8)
  Search = { bg = colors.bg_orange, fg = colors.color3 }, -- Last search pattern highlighting
  IncSearch = { bg = colors.color3, fg = colors.black }, -- 'incsearch' highlighting
  CurSearch = { link = 'IncSearch' },
  SpecialKey = { fg = colors.fg_grey }, -- Unprintable characters
  SpellBad = { sp = colors.color1, undercurl = true }, -- Word that is not recognized by the spellchecker
  SpellCap = { sp = colors.fg_yellow, undercurl = true }, -- Word that should start with a capital
  SpellLocal = { sp = colors.color4, undercurl = true }, -- Word that is recognized by the spellchecker as one that is used in another region
  SpellRare = { sp = colors.color6, undercurl = true }, -- Word that is recognized by the spellchecker as one that is hardly ever used
  StatusLine = { fg = colors.fg, bg = colors.color8 }, -- status line of current window
  StatusLineNC = { fg = colors.fg_grey, bg = colors.color8 }, -- status lines of not-current windows
  TabLine = { bg = colors.color8, fg = colors.fg_grey }, -- tab pages line, not active tab page label
  TabLineFill = { bg = colors.none }, -- tab pages line, where there are no labels
  TabLineSel = { fg = colors.bg, bg = colors.color4 }, -- tab pages line, active tab page label
  Title = { fg = colors.color4, bold = true }, -- titles for output from ":set all", ":autocmd" etc.
  Visual = { bg = colors.color8 }, -- Visual mode selection
  VisualNOS = { bg = colors.color8 }, -- Visual mode selection when vim is "Not Owning the Selection"
  WarningMsg = { fg = colors.fg_yellow }, -- warning messages
  Whitespace = { fg = colors.fg_grey }, -- "nbsp", "space", "tab" and "trail" in 'listchars'
  WildMenu = { bg = colors.color8 }, -- current match in 'wildmenu' completion
  WinBar = { link = 'StatusLine' }, -- window bar
  WinBarNC = { link = 'StatusLineNC' }, -- window bar in inactive windows

  -- Syntax Highlighting
  Bold = { bold = true, fg = colors.fg }, -- any bold text
  Character = { fg = colors.color2 }, -- a character constant: 'c', '\n'
  Constant = { fg = colors.color6 }, -- any constant
  Debug = { fg = colors.color3 }, -- debugging statements
  Delimiter = { fg = colors.color3 }, -- character that needs attention
  Error = { fg = colors.color1 }, -- any erroneous construct
  Function = { fg = colors.color4 }, -- function name (also: methods for classes)
  Identifier = { fg = colors.fg }, -- any variable name
  Italic = { italic = true, fg = colors.fg }, -- any italic text
  Keyword = { fg = colors.color5 }, -- any other keyword
  Operator = { fg = colors.color3 }, -- "sizeof", "+", "*", etc.
  PreProc = { fg = colors.color5 }, -- generic Preprocessor
  Special = { fg = colors.color3 }, -- any special symbol
  Statement = { fg = colors.faded_hot_pink }, -- any statement
  String = { fg = colors.color2 }, -- a string constant: "this is a string"
  Todo = { bg = colors.color3, fg = colors.bg }, -- anything that needs extra attention; mostly the keywords TODO FIXME and XXX
  Type = { fg = colors.color5 }, -- int, long, char, etc.
  Underlined = { underline = true }, -- text that stands out, HTML links
  debugBreakpoint = { bg = colors.bg_info, fg = colors.color4 }, -- used for breakpoint colors in terminal-debug
  debugPC = { bg = colors.color8 }, -- used for highlighting the current line in terminal-debug
  dosIniLabel = { link = '@property' },
  helpCommand = { bg = colors.color8, fg = colors.color4 },
  htmlH1 = { fg = colors.color5, bold = true },
  htmlH2 = { fg = colors.color4, bold = true },
  qfFileName = { fg = colors.color4 },
  qfLineNr = { fg = colors.fg_grey },

  -- LSP
  LspReferenceText = { bg = colors.color8 }, -- used for highlighting "text" references
  LspReferenceRead = { bg = colors.color8 }, -- used for highlighting "read" references
  LspReferenceWrite = { bg = colors.color8 }, -- used for highlighting "write" references
  LspSignatureActiveParameter = { bg = colors.bg_info, bold = true },
  LspCodeLens = { fg = colors.fg_grey },
  LspInlayHint = { bg = colors.bg_hint, fg = colors.fg_grey },
  LspInfoBorder = { fg = colors.fg_grey, bg = colors.bg },
  ComplHint = { fg = colors.color8 },

  -- Diagnostics
  DiagnosticError = { fg = colors.color1 }, -- Used as the base highlight group
  DiagnosticWarn = { fg = colors.fg_yellow }, -- Used as the base highlight group
  DiagnosticInfo = { fg = colors.color4 }, -- Used as the base highlight group
  DiagnosticHint = { fg = colors.color6 }, -- Used as the base highlight group
  DiagnosticUnnecessary = { fg = colors.color8 }, -- Used as the base highlight group
  DiagnosticVirtualTextError = { bg = colors.bg_error, fg = colors.color1 }, -- Used for "Error" diagnostic virtual text
  DiagnosticVirtualTextWarn = { bg = colors.bg_warning, fg = colors.fg_yellow }, -- Used for "Warning" diagnostic virtual text
  DiagnosticVirtualTextInfo = { bg = colors.bg_info, fg = colors.color4 }, -- Used for "Information" diagnostic virtual text
  DiagnosticVirtualTextHint = { bg = colors.bg_hint, fg = colors.color6 }, -- Used for "Hint" diagnostic virtual text
  DiagnosticUnderlineError = { undercurl = true, sp = colors.color1 }, -- Used to underline "Error" diagnostics
  DiagnosticUnderlineWarn = { undercurl = true, sp = colors.fg_yellow }, -- Used to underline "Warning" diagnostics
  DiagnosticUnderlineInfo = { undercurl = true, sp = colors.color4 }, -- Used to underline "Information" diagnostics
  DiagnosticUnderlineHint = { undercurl = true, sp = colors.color6 }, -- Used to underline "Hint" diagnostics

  -- Health
  healthError = { fg = colors.color1 },
  healthSuccess = { fg = colors.color10 },
  healthWarning = { fg = colors.fg_yellow },

  -- Diff
  diffAdded = { bg = colors.bg_hint, fg = colors.color10 },
  diffRemoved = { bg = colors.bg_error, fg = colors.color9 },
  diffChanged = { bg = colors.bg_warning, fg = colors.color11 },
  diffOldFile = { fg = colors.color4, bg = colors.bg_error },
  diffNewFile = { fg = colors.color4, bg = colors.bg_hint },
  diffFile = { fg = colors.color4 },
  diffLine = { fg = colors.fg_grey },
  diffIndexLine = { fg = colors.color5 },
  helpExample = { fg = colors.fg_grey },

  -- Treesitter
  ['@annotation'] = { link = 'PreProc' },
  ['@attribute'] = { link = 'PreProc' },
  ['@boolean'] = { link = 'Boolean' },
  ['@character'] = { link = 'Character' },
  ['@character.printf'] = { link = 'SpecialChar' },
  ['@character.special'] = { link = 'SpecialChar' },
  ['@comment'] = { link = 'Comment' },
  ['@comment.error'] = { fg = colors.color1 },
  ['@comment.hint'] = { fg = colors.color6 },
  ['@comment.info'] = { fg = colors.color4 },
  ['@comment.note'] = { fg = colors.color6 },
  ['@comment.todo'] = { fg = colors.color3 },
  ['@comment.warning'] = { fg = colors.fg_yellow },
  ['@constant'] = { link = 'Constant' },
  ['@constant.builtin'] = { link = 'Special' },
  ['@constant.macro'] = { link = 'Define' },
  ['@constructor'] = { fg = colors.color5 },
  ['@constructor.tsx'] = { fg = colors.color5 },
  ['@diff.delta'] = { link = 'DiffChange' },
  ['@diff.minus'] = { link = 'DiffDelete' },
  ['@diff.plus'] = { link = 'DiffAdd' },
  ['@function'] = { link = 'Function' },
  ['@function.builtin'] = { link = 'Special' },
  ['@function.call'] = { link = '@function' },
  ['@function.macro'] = { link = 'Macro' },
  ['@function.method'] = { link = 'Function' },
  ['@function.method.call'] = { link = '@function.method' },
  ['@keyword'] = { fg = colors.faded_hot_pink, italic = true }, -- For keywords that don't fall in previous categories
  ['@keyword.conditional'] = { link = 'Conditional' },
  ['@keyword.coroutine'] = { link = '@keyword' },
  ['@keyword.debug'] = { link = 'Debug' },
  ['@keyword.directive'] = { link = 'PreProc' },
  ['@keyword.directive.define'] = { link = 'Define' },
  ['@keyword.exception'] = { link = 'Exception' },
  ['@keyword.function'] = { fg = colors.color5 }, -- For keywords used to define a function
  ['@keyword.import'] = { link = 'Include' },
  ['@keyword.operator'] = { link = '@operator' },
  ['@keyword.repeat'] = { link = 'Repeat' },
  ['@keyword.return'] = { link = '@keyword' },
  ['@keyword.storage'] = { link = 'StorageClass' },
  ['@label'] = { fg = colors.color4 }, -- For labels: `label:` in C and `:label:` in Lua
  ['@markup'] = { link = '@none' },
  ['@markup.emphasis'] = { italic = true },
  ['@markup.environment'] = { link = 'Macro' },
  ['@markup.environment.name'] = { link = 'Type' },
  ['@markup.heading'] = { link = 'Title' },
  ['@markup.italic'] = { italic = true },
  ['@markup.link'] = { fg = colors.turquoise },
  ['@markup.link.label'] = { link = 'SpecialChar' },
  ['@markup.link.label.symbol'] = { link = 'Identifier' },
  ['@markup.link.url'] = { link = 'Underlined' },
  ['@markup.list'] = { fg = colors.color3 }, -- For special punctutation that does not fall in the categories before
  ['@markup.list.checked'] = { fg = colors.color10 }, -- For checked items
  ['@markup.list.markdown'] = { fg = colors.color3, bold = true },
  ['@markup.list.unchecked'] = { fg = colors.color4 }, -- For unchecked items
  ['@markup.math'] = { link = 'Special' },
  ['@markup.raw'] = { link = 'String' },
  ['@markup.raw.markdown_inline'] = { bg = colors.color8, fg = colors.color4 },
  ['@markup.strikethrough'] = { strikethrough = true },
  ['@markup.strong'] = { bold = true },
  ['@markup.underline'] = { underline = true },
  ['@module'] = { link = 'Include' },
  ['@module.builtin'] = { fg = colors.color1 }, -- Variable names that are defined by the languages
  ['@namespace.builtin'] = { link = '@variable.builtin' },
  ['@none'] = {},
  ['@number'] = { link = 'Number' },
  ['@number.float'] = { link = 'Float' },
  ['@operator'] = { fg = colors.color3 }, -- For any operator: `+`, but also `->` and `*` in C
  ['@property'] = { fg = colors.color4 },
  ['@punctuation.bracket'] = { fg = colors.color5 }, -- For brackets and parens
  ['@punctuation.delimiter'] = { fg = colors.color3 }, -- For delimiters ie: `.`
  ['@punctuation.special'] = { fg = colors.color3 }, -- For special symbols (e.g. `{}` in string interpolation)
  ['@punctuation.special.markdown'] = { fg = colors.color3 }, -- For special symbols in markdown
  ['@string'] = { link = 'String' },
  ['@string.documentation'] = { fg = colors.color11 },
  ['@string.escape'] = { fg = colors.color5 }, -- For escape characters within a string
  ['@string.regexp'] = { fg = colors.color6 }, -- For regexes
  ['@tag'] = { link = 'Label' },
  ['@tag.attribute'] = { link = '@property' },
  ['@tag.delimiter'] = { link = 'Delimiter' },
  ['@tag.delimiter.tsx'] = { fg = colors.color4 },
  ['@tag.tsx'] = { fg = colors.color1 },
  ['@tag.javascript'] = { fg = colors.color1 },
  ['@type'] = { link = 'Type' },
  ['@type.builtin'] = { fg = colors.turquoise, italic = true },
  ['@type.definition'] = { link = 'Typedef' },
  ['@type.qualifier'] = { link = '@keyword' },
  ['@variable'] = { fg = colors.fg }, -- Any variable name that does not have another highlight
  ['@variable.builtin'] = { fg = colors.faded_hot_pink }, -- Variable names that are defined by the languages, like `this` or `self`
  ['@variable.member'] = { fg = colors.color6 }, -- For fields
  ['@variable.parameter'] = { fg = colors.orange }, -- For parameters of a function
  ['@variable.parameter.builtin'] = { fg = colors.color11 }, -- For builtin parameters of a function

  -- LSP Semantic Tokens
  ['@lsp.type.boolean'] = { link = '@boolean' },
  ['@lsp.type.builtinType'] = { link = '@type.builtin' },
  ['@lsp.type.comment'] = { link = '@comment' },
  ['@lsp.type.decorator'] = { link = '@attribute' },
  ['@lsp.type.deriveHelper'] = { link = '@attribute' },
  ['@lsp.type.enum'] = { link = '@type' },
  ['@lsp.type.enumMember'] = { link = '@constant' },
  ['@lsp.type.escapeSequence'] = { link = '@string.escape' },
  ['@lsp.type.formatSpecifier'] = { link = '@markup.list' },
  ['@lsp.type.generic'] = { link = '@variable' },
  ['@lsp.type.interface'] = { fg = colors.color12 },
  ['@lsp.type.keyword'] = { link = '@keyword' },
  ['@lsp.type.lifetime'] = { link = '@keyword.storage' },
  ['@lsp.type.namespace'] = { link = '@module' },
  ['@lsp.type.namespace.python'] = { link = '@variable' },
  ['@lsp.type.number'] = { link = '@number' },
  ['@lsp.type.operator'] = { link = '@operator' },
  ['@lsp.type.parameter'] = { link = '@variable.parameter' },
  ['@lsp.type.property'] = { link = '@property' },
  ['@lsp.type.selfKeyword'] = { link = '@variable.builtin' },
  ['@lsp.type.selfTypeKeyword'] = { link = '@variable.builtin' },
  ['@lsp.type.string'] = { link = '@string' },
  ['@lsp.type.typeAlias'] = { link = '@type.definition' },
  ['@lsp.type.unresolvedReference'] = { undercurl = true, sp = colors.color1 },
  ['@lsp.type.variable'] = {}, -- use treesitter styles for regular variables
  ['@lsp.typemod.class.defaultLibrary'] = { link = '@type.builtin' },
  ['@lsp.typemod.enum.defaultLibrary'] = { link = '@type.builtin' },
  ['@lsp.typemod.enumMember.defaultLibrary'] = { link = '@constant.builtin' },
  ['@lsp.typemod.function.defaultLibrary'] = { link = '@function.builtin' },
  ['@lsp.typemod.keyword.async'] = { link = '@keyword.coroutine' },
  ['@lsp.typemod.keyword.injected'] = { link = '@keyword' },
  ['@lsp.typemod.macro.defaultLibrary'] = { link = '@function.builtin' },
  ['@lsp.typemod.method.defaultLibrary'] = { link = '@function.builtin' },
  ['@lsp.typemod.operator.injected'] = { link = '@operator' },
  ['@lsp.typemod.string.injected'] = { link = '@string' },
  ['@lsp.typemod.struct.defaultLibrary'] = { link = '@type.builtin' },
  ['@lsp.typemod.type.defaultLibrary'] = { fg = colors.color12 },
  ['@lsp.typemod.typeAlias.defaultLibrary'] = { fg = colors.color12 },
  ['@lsp.typemod.variable.callable'] = { link = '@function' },
  ['@lsp.typemod.variable.defaultLibrary'] = { link = '@variable.builtin' },
  ['@lsp.typemod.variable.injected'] = { link = '@variable' },
  ['@lsp.typemod.variable.static'] = { link = '@constant' },

  -- Gitsigns
  GitSignsAdd = { fg = colors.color2 }, -- diff mode: Added line |diff.txt|
  GitSignsChange = { fg = colors.color3 }, -- diff mode: Changed line |diff.txt|
  GitSignsDelete = { fg = colors.color1 }, -- diff mode: Deleted line |diff.txt|

  -- Lazy
  LazyProgressDone = { bold = true, fg = colors.color13 },
  LazyProgressTodo = { bold = true, fg = colors.fg_grey },

  -- Mini-icons
  MiniIconsGrey = { fg = colors.fg },
  MiniIconsPurple = { fg = colors.color5 },
  MiniIconsBlue = { fg = colors.color4 },
  MiniIconsAzure = { fg = colors.turquoise },
  MiniIconsCyan = { fg = colors.color6 },
  MiniIconsGreen = { fg = colors.color2 },
  MiniIconsYellow = { fg = colors.fg_yellow },
  MiniIconsOrange = { fg = colors.color3 },
  MiniIconsRed = { fg = colors.color1 },

  -- Mini-indentscope
  MiniIndentscopeSymbol = { fg = colors.faded_hot_pink, nocombine = true },

  -- Mini-trailspace
  MiniTrailspace = { fg = colors.color1, bg = colors.bg_error },

  -- Treesitter-context
  TreesitterContext = { bg = colors.bg_grey_bright },
})

for group, opts in pairs(groups) do
  vim.api.nvim_set_hl(0, group, opts)
end
