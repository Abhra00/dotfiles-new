-- My own statusline

-- Get icons
local icons = require 'utils.icons'

local M = {}

-- Don't show the command that produced the quickfix list.
vim.g.qf_disable_statusline = 1

-- Show the mode in my custom component instead.
vim.o.showmode = false

--- Keeps track of the highlight groups I've already created.
---@type table<string, boolean>
local statusline_hls = {}

---@param hl string
---@return string
function M.get_or_create_hl(hl)
  local hl_name = 'Statusline' .. hl

  if not statusline_hls[hl] then
    -- If not in the cache, create the highlight group using the icon's foreground color
    -- and the statusline's background color.
    local bg_hl = vim.api.nvim_get_hl(0, { name = 'StatusLine' })
    local fg_hl = vim.api.nvim_get_hl(0, { name = hl })
    vim.api.nvim_set_hl(0, hl_name, { bg = ('#%06x'):format(bg_hl.bg), fg = ('#%06x'):format(fg_hl.fg) })
    statusline_hls[hl] = true
  end

  return hl_name
end

--- Current mode.
---@return string
function M.mode_component()
  -- Note that: \19 = ^S and \22 = ^V.
  local mode_to_str = {
    ['n'] = 'NORMAL',
    ['no'] = 'OP-PENDING',
    ['nov'] = 'OP-PENDING',
    ['noV'] = 'OP-PENDING',
    ['no\22'] = 'OP-PENDING',
    ['niI'] = 'NORMAL',
    ['niR'] = 'NORMAL',
    ['niV'] = 'NORMAL',
    ['nt'] = 'NORMAL',
    ['ntT'] = 'NORMAL',
    ['v'] = 'VISUAL',
    ['vs'] = 'VISUAL',
    ['V'] = 'VISUAL',
    ['Vs'] = 'VISUAL',
    ['\22'] = 'VISUAL',
    ['\22s'] = 'VISUAL',
    ['s'] = 'SELECT',
    ['S'] = 'SELECT',
    ['\19'] = 'SELECT',
    ['i'] = 'INSERT',
    ['ic'] = 'INSERT',
    ['ix'] = 'INSERT',
    ['R'] = 'REPLACE',
    ['Rc'] = 'REPLACE',
    ['Rx'] = 'REPLACE',
    ['Rv'] = 'VIRT REPLACE',
    ['Rvc'] = 'VIRT REPLACE',
    ['Rvx'] = 'VIRT REPLACE',
    ['c'] = 'COMMAND',
    ['cv'] = 'VIM EX',
    ['ce'] = 'EX',
    ['r'] = 'PROMPT',
    ['rm'] = 'MORE',
    ['r?'] = 'CONFIRM',
    ['!'] = 'SHELL',
    ['t'] = 'TERMINAL',
  }

  -- Get the respective string to display.
  local mode = mode_to_str[vim.api.nvim_get_mode().mode] or 'UNKNOWN'

  -- Set the highlight group.
  local hl = 'Other'
  if mode:find 'NORMAL' then
    hl = 'Normal'
  elseif mode:find 'PENDING' then
    hl = 'Pending'
  elseif mode:find 'VISUAL' then
    hl = 'Visual'
  elseif mode:find 'INSERT' or mode:find 'SELECT' then
    hl = 'Insert'
  elseif mode:find 'COMMAND' or mode:find 'TERMINAL' or mode:find 'EX' then
    hl = 'Command'
  end

  -- Construct the bubble-like component.
  return table.concat {
    string.format('%%#StatuslineModeSeparatorBlendedBg%s#', hl),
    string.format('%%#StatuslineMode%s#%s', hl, mode),
    string.format('%%#StatuslineModeSeparator%s#', hl),
  }
end

--- Git status (if any).
---@return string
function M.git_component()
  local head = vim.b.gitsigns_head
  if not head or head == '' then
    return ''
  end

  local component = string.format(' %s', head)

  local num_hunks = #(require('gitsigns').get_hunks() or {})
  if num_hunks > 0 then
    component = component .. string.format(' (#Hunks: %d)', num_hunks)
  end

  return string.format('%%#StatuslineGit#%s', component)
end

--- The current debugging status (if any).
---@return string?
function M.dap_component()
  if not package.loaded['dap'] or require('dap').status() == '' then
    return nil
  end

  return string.format('%%#%s#%s  %s', M.get_or_create_hl 'Special', icons.misc.bug, require('dap').status())
end

---@type table<string, string?>
local progress_status = {
  client = nil,
  kind = nil,
  title = nil,
}

vim.api.nvim_create_autocmd('LspProgress', {
  group = vim.api.nvim_create_augroup('mariasolos/statusline', { clear = true }),
  desc = 'Update LSP progress in statusline',
  pattern = { 'begin', 'end' },
  callback = function(args)
    -- This should in theory never happen, but I've seen weird errors.
    if not args.data then
      return
    end

    progress_status = {
      client = vim.lsp.get_client_by_id(args.data.client_id).name,
      kind = args.data.params.value.kind,
      title = args.data.params.value.title,
    }

    if progress_status.kind == 'end' then
      progress_status.title = nil
      -- Wait a bit before clearing the status.
      vim.defer_fn(function()
        vim.cmd.redrawstatus()
      end, 3000)
    else
      vim.cmd.redrawstatus()
    end
  end,
})
--- The latest LSP progress message.
---@return string
function M.lsp_progress_component()
  if not progress_status.client or not progress_status.title then
    return ''
  end

  -- Avoid noisy messages while typing.
  if vim.startswith(vim.api.nvim_get_mode().mode, 'i') then
    return ''
  end

  return table.concat {
    '%#StatuslineSpinner#󱥸 ',
    string.format('%%#StatuslineTitle#%s  ', progress_status.client),
    string.format('%%#StatuslineItalic#%s...', progress_status.title),
  }
end

--- The current working directory.
---@return string
function M.cwd_component()
  -- Set cwd and diricons
  local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ':t') -- Changed to :t for tail (basename)
  local dir_icon = icons.misc.directory

  -- Get hl groups
  local icon_bg_hl_name = 'StatuslineCwdIcon'
  local separator_hl_name = 'StatuslineCwdSeparator'
  local text_hl_name = 'StatuslineCwdText'

  return table.concat {
    string.format('%%#%s#', separator_hl_name),
    string.format('%%#%s#%s', icon_bg_hl_name, dir_icon),
    string.format('%%#%s#', separator_hl_name),
    string.format(' %%#%s#%s', text_hl_name, cwd),
  }
end

--- The current file name with filetype icon.
---@return string
function M.filename_component()
  local MiniIcons = require 'mini.icons'

  -- Special icons for some filetypes.
  local special_icons = {
    DiffviewFileHistory = { icons.misc.git, 'Number' },
    DiffviewFiles = { icons.misc.git, 'Number' },
    ['ccc-ui'] = { icons.misc.palette, 'Comment' },
    ['dap-view'] = { icons.misc.bug, 'Special' },
    ['grug-far'] = { icons.misc.search, 'Constant' },
    codecompanion = { icons.misc.robot, 'Conditional' },
    fzf = { icons.misc.terminal, 'Special' },
    gitcommit = { icons.misc.git, 'Number' },
    gitrebase = { icons.misc.git, 'Number' },
    lazy = { icons.symbol_kinds.Method, 'Special' },
    lazyterm = { icons.misc.terminal, 'Special' },
    minifiles = { icons.symbol_kinds.Folder, 'Directory' },
    qf = { icons.misc.search, 'Conditional' },
  }

  local filename = vim.fn.expand '%:t'
  if filename == '' then
    filename = '[No Name]'
  end

  local modified = vim.bo.modified
  local readonly = vim.bo.readonly

  -- Readonly icon
  local readonly_flag = readonly and string.format(' %%#StatuslineModified#%s', icons.misc.lock) or ''

  -- Filename color changes if modified
  local filename_hl = modified and 'StatuslineModified' or 'StatuslineTitle'

  -- Get relative path from cwd and truncate if needed
  local filepath = vim.fn.expand '%:~:.:h'
  local path_str = ''

  if filepath ~= '.' and filepath ~= '' then
    local parts = vim.split(filepath, '/', { plain = true })
    -- Filter out empty strings from leading slash
    parts = vim.tbl_filter(function(part)
      return part ~= ''
    end, parts)

    if #parts > 2 then
      -- Truncate middle parts: keep first, replace middle with ..., keep last
      path_str = '/' .. parts[1] .. '/' .. icons.misc.ellipsis .. '/' .. parts[#parts] .. '/'
    else
      path_str = filepath .. '/'
    end
  end

  -- Get filetype icon
  local filetype = vim.bo.filetype
  local icon, icon_hl
  if special_icons[filetype] then
    icon, icon_hl = unpack(special_icons[filetype])
  else
    icon, icon_hl = MiniIcons.get('filetype', filetype)
  end
  icon_hl = M.get_or_create_hl(icon_hl)

  return string.format(
    '%%#%s#%s %%#StatuslineComment#%s%%#%s#%s%%#StatuslineTitle#%s',
    icon_hl,
    icon,
    path_str,
    filename_hl,
    filename,
    readonly_flag
  )
end

--- Diagnostic counts for the current buffer.
---@return string
function M.diagnostic_component()
  local counts = { ERROR = 0, WARN = 0, INFO = 0, HINT = 0 }

  for _, diagnostic in ipairs(vim.diagnostic.get(0)) do
    local severity = vim.diagnostic.severity[diagnostic.severity]
    if counts[severity] then
      counts[severity] = counts[severity] + 1
    end
  end

  local components = {}

  if counts.ERROR > 0 then
    table.insert(components, string.format('%%#DiagnosticError#%s %d', icons.diagnostics.Error, counts.ERROR))
  end
  if counts.WARN > 0 then
    table.insert(components, string.format('%%#DiagnosticWarn#%s %d', icons.diagnostics.Warn, counts.WARN))
  end
  if counts.INFO > 0 then
    table.insert(components, string.format('%%#DiagnosticInfo#%s %d', icons.diagnostics.Info, counts.INFO))
  end
  if counts.HINT > 0 then
    table.insert(components, string.format('%%#DiagnosticHint#%s %d', icons.diagnostics.Hint, counts.HINT))
  end

  return table.concat(components, ' ')
end

--- The current line, total line count, and column position.
---@return string
function M.position_component()
  local line = vim.fn.line '.'
  local line_count = vim.api.nvim_buf_line_count(0)
  local col = vim.fn.virtcol '.'

  return table.concat {
    '%#StatuslinePosition#l: ',
    string.format('%%#StatuslineTitle#%d', line),
    string.format('%%#StatuslineItalic#/%d', line_count),
    '%#StatuslinePosition# c: ',
    string.format('%%#StatuslineItalic#%d', col),
  }
end

--- Current time
---@return string
function M.time_component()
  -- Note that: \19 = ^S and \22 = ^V.
  local mode_to_str = {
    ['n'] = 'NORMAL',
    ['no'] = 'OP-PENDING',
    ['nov'] = 'OP-PENDING',
    ['noV'] = 'OP-PENDING',
    ['no\22'] = 'OP-PENDING',
    ['niI'] = 'NORMAL',
    ['niR'] = 'NORMAL',
    ['niV'] = 'NORMAL',
    ['nt'] = 'NORMAL',
    ['ntT'] = 'NORMAL',
    ['v'] = 'VISUAL',
    ['vs'] = 'VISUAL',
    ['V'] = 'VISUAL',
    ['Vs'] = 'VISUAL',
    ['\22'] = 'VISUAL',
    ['\22s'] = 'VISUAL',
    ['s'] = 'SELECT',
    ['S'] = 'SELECT',
    ['\19'] = 'SELECT',
    ['i'] = 'INSERT',
    ['ic'] = 'INSERT',
    ['ix'] = 'INSERT',
    ['R'] = 'REPLACE',
    ['Rc'] = 'REPLACE',
    ['Rx'] = 'REPLACE',
    ['Rv'] = 'VIRT REPLACE',
    ['Rvc'] = 'VIRT REPLACE',
    ['Rvx'] = 'VIRT REPLACE',
    ['c'] = 'COMMAND',
    ['cv'] = 'VIM EX',
    ['ce'] = 'EX',
    ['r'] = 'PROMPT',
    ['rm'] = 'MORE',
    ['r?'] = 'CONFIRM',
    ['!'] = 'SHELL',
    ['t'] = 'TERMINAL',
  }

  -- Pretty time
  local function pretty_time()
    local hour = tonumber(os.date '%H')
    local clocks = {
      '󱑊', -- 12
      '󱐿', -- 1
      '󱑀', -- 2
      '󱑁', -- 3
      '󱑂', -- 4
      '󱑃', -- 5
      '󱑄', -- 6
      '󱑅', -- 7
      '󱑆', -- 8
      '󱑇', -- 9
      '󱑈', -- 10
      '󱑉', -- 11
    }
    -- Set icons
    local icon = clocks[(hour % 12) + 1]
    return icon .. ' ' .. os.date '%R'
  end

  -- Get the mode
  local mode = mode_to_str[vim.api.nvim_get_mode().mode] or 'UNKNOWN'

  -- Set the highlight group.
  local hl = 'Other'
  if mode:find 'NORMAL' then
    hl = 'Normal'
  elseif mode:find 'PENDING' then
    hl = 'Pending'
  elseif mode:find 'VISUAL' then
    hl = 'Visual'
  elseif mode:find 'INSERT' or mode:find 'SELECT' then
    hl = 'Insert'
  elseif mode:find 'COMMAND' or mode:find 'TERMINAL' or mode:find 'EX' then
    hl = 'Command'
  end

  -- Construct the bubble-like component.
  return table.concat {
    string.format('%%#StatuslineModeSeparator%s#', hl),
    string.format('%%#StatuslineMode%s#%s', hl, pretty_time()), -- Added () to call the function
    string.format('%%#StatuslineModeSeparatorBlendedBg%s#', hl),
  }
end

--- Renders the statusline.
---@return string
function M.render()
  ---@param components string[]
  ---@return string
  local function concat_components(components)
    return vim.iter(components):skip(1):fold(components[1], function(acc, component)
      return #component > 0 and string.format('%s    %s', acc, component) or acc
    end)
  end

  return table.concat {
    concat_components {
      M.mode_component(),
      M.cwd_component(),
      M.filename_component(),
      M.git_component(),
      M.dap_component() or M.lsp_progress_component(),
    },
    '%#StatusLine#%=',
    concat_components {
      M.diagnostic_component(),
      M.position_component(),
      M.time_component(),
    },
  }
end

return M
