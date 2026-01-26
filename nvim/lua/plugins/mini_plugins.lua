-- Mini_plugins
-- A library of 40+ independent Lua modules.

return {
  { 'nvim-mini/mini.ai', version = false, event = 'VeryLazy', opts = {} },
  { 'nvim-mini/mini.comment', version = false, event = 'VeryLazy', opts = {} },
  { 'nvim-mini/mini.move', version = false, event = 'VeryLazy', opts = {} },
  { 'nvim-mini/mini.surround', version = false, event = 'VeryLazy', opts = {} },
  { 'nvim-mini/mini.pairs', version = false, event = 'VeryLazy', opts = {} },
  { 'nvim-mini/mini.trailspace', version = false, event = 'VeryLazy', opts = {} },
  { 'nvim-mini/mini.indentscope', version = false, event = 'VeryLazy', opts = {} },
  -- Set up mini icons and make it act as web-dev icons
  {
    'nvim-mini/mini.icons',
    lazy = true,
    opts = {
      file = {
        ['.keep'] = { glyph = '󰊢', hl = 'MiniIconsGrey' },
        ['devcontainer.json'] = { glyph = '', hl = 'MiniIconsAzure' },
      },
      filetype = {
        dotenv = { glyph = '', hl = 'MiniIconsYellow' },
      },
    },
    init = function()
      package.preload['nvim-web-devicons'] = function()
        require('mini.icons').mock_nvim_web_devicons()
        return package.loaded['nvim-web-devicons']
      end
    end,
  },
}
