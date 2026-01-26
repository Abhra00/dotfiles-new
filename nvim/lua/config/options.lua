-- Options
-- Some QoL options for neovim

-- Get icons
local arrows = require('utils.icons').arrows

-- For convenience
local opt = vim.opt

-- Basic Settings
opt.number = true -- Line numbers
opt.relativenumber = true -- Relative line numbers
opt.cursorline = true -- Highlight current line
opt.scrolloff = 4 -- Keep 4 lines above/below cursor
opt.sidescrolloff = 8 -- Keep 8 columns left/right of cursor
opt.wrap = false -- Don't wrap lines
opt.linebreak = true -- Wrap lines at convenient points (if wrap enabled)
opt.cmdheight = 1 -- Command line height
opt.spelllang = { 'en' } -- Set language for spellchecking
opt.ruler = false -- Disable the default ruler

-- Tabbing / Indentation
opt.tabstop = 2 -- Tab width
opt.shiftwidth = 2 -- Indent width
opt.softtabstop = 2 -- Soft tab stop
opt.expandtab = true -- Use spaces instead of tabs
opt.smartindent = true -- Smart auto-indenting
opt.autoindent = true -- Copy indent from current line
opt.shiftround = true -- Round indent
opt.grepprg = 'rg --vimgrep' -- Use ripgrep if available
opt.grepformat = '%f:%l:%c:%m' -- filename, line number, column, content

-- Search Settings
opt.ignorecase = true -- Case-insensitive search
opt.smartcase = true -- Case-sensitive if uppercase in search
opt.hlsearch = true -- Enable highlighting of search results
opt.incsearch = true -- Show matches as you type
opt.inccommand = 'nosplit' -- Preview incremental substitute

-- Visual Settings
opt.termguicolors = true -- Enable 24-bit colors
opt.signcolumn = 'yes' -- Always show sign column
opt.colorcolumn = '100' -- Show column at 100 characters
opt.showmatch = true -- Highlight matching brackets
opt.matchtime = 2 -- How long to show matching bracket
opt.completeopt = 'menu,menuone,noselect' -- Completion options
opt.showmode = false -- Don't show mode in command line
opt.pumheight = 10 -- Popup menu height
opt.pumblend = 10 -- Popup menu transparency
opt.winblend = 0 -- Floating window transparency
opt.conceallevel = 2 -- Hide * markup for bold and italic
opt.concealcursor = '' -- Show markup even on cursor line
opt.lazyredraw = false -- Redraw while executing macros (better UX)
opt.redrawtime = 10000 -- Timeout for syntax highlighting redraw
opt.maxmempattern = 20000 -- Max memory for pattern matching
opt.synmaxcol = 300 -- Syntax highlighting column limit
opt.laststatus = 3 -- Global statusline

-- File Handling
opt.backup = false -- Don't create backup files
opt.writebackup = false -- Don't backup before overwriting
opt.swapfile = false -- Don't create swap files
opt.undofile = true -- Persistent undo
opt.undolevels = 10000 -- Number of undo levels
opt.updatetime = 200 -- Time in ms to trigger CursorHold
opt.timeoutlen = 300 -- Time in ms to wait for mapped sequence
opt.ttimeoutlen = 0 -- No wait for key code sequences
opt.autoread = true -- Auto-reload file if changed outside
opt.autowrite = true -- Enable auto write
opt.diffopt:append 'vertical' -- Vertical diff splits
opt.diffopt:append 'algorithm:patience' -- Better diff algorithm
opt.diffopt:append 'linematch:60' -- Better diff highlighting (smart line matching)

-- Set undo directory and ensure it exists
local undodir = '~/.local/share/nvim/undodir' -- Undo directory path
opt.undodir = vim.fn.expand(undodir) -- Expand to full path
local undodir_path = vim.fn.expand(undodir)
if vim.fn.isdirectory(undodir_path) == 0 then
  vim.fn.mkdir(undodir_path, 'p') -- Create if not exists
end

-- Behavior Settings
opt.errorbells = false -- Disable error sounds
opt.backspace = 'indent,eol,start' -- Make backspace behave naturally
opt.autochdir = false -- Don't change directory automatically
opt.iskeyword:append '-' -- Treat dash as part of a word
opt.path:append '**' -- Search into subfolders with `gf`
opt.selection = 'inclusive' -- Use inclusive selection
opt.mouse = 'a' -- Enable mouse support
opt.virtualedit = 'block' -- Allow cursor to move where there is no text in visual block mode
opt.modifiable = true -- Allow editing buffers
opt.encoding = 'UTF-8' -- Use UTF-8 encoding
opt.wildmenu = true -- Enable command-line completion menu
opt.wildmode = 'longest:full,full' -- Completion mode for command-line
opt.wildignorecase = true -- Case-insensitive tab completion in commands
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.smoothscroll = true -- Enable smooth scrolling
opt.jumpoptions = 'view' -- Save view when jumping
opt.sessionoptions = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help', 'globals', 'skiprtp', 'folds' } -- Session options
opt.formatoptions = 'jcroqlnt' -- Format options
opt.shortmess:append { W = true, I = true, c = true, C = true } -- Shorter messages
opt.winminwidth = 5 -- Minimum window width

-- Clipboard (conditional on SSH)
opt.clipboard = vim.env.SSH_CONNECTION and '' or 'unnamedplus' -- Sync with system clipboard

-- Cursor Settings
opt.guicursor = {
  'n-v-c:block', -- Normal, Visual, Command-line
  'i-ci-ve:block', -- Insert, Command-line Insert, Visual-exclusive
  'r-cr:hor20', -- Replace, Command-line Replace
  'o:hor50', -- Operator-pending
  'a:blinkwait700-blinkoff400-blinkon250', -- All modes: blinking
  'sm:block-blinkwait175-blinkoff150-blinkon175', -- Showmatch mode
}

-- Folding Settings
opt.foldmethod = 'expr' -- Use expression for folding
opt.foldlevel = 99 -- Keep all folds open by default

-- Split Behavior
opt.splitbelow = true -- Horizontal splits open below
opt.splitright = true -- Vertical splits open to the right
opt.splitkeep = 'screen' -- Keep screen content stable when splitting (fixes noice.nvim bouncing)

-- List characters
opt.list = true -- Enable list
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Fill chararcters
opt.fillchars = { -- Set how listchars will look
  eob = ' ',
  fold = '·',
  foldclose = arrows.right,
  foldopen = arrows.down,
  foldsep = ' ',
  msgsep = '─',
}

-- Set my statusline
vim.o.statusline = "%!v:lua.require'utils.status_line'.render()"

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0
