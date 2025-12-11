-- ================================================================================================
-- TITLE : mini.nvim
-- LINKS :
--   > github : https://github.com/echasnovski/mini.nvim
-- ABOUT : Library of 40+ independent Lua modules.
-- ================================================================================================

return {
  { 'echasnovski/mini.ai', event = 'VeryLazy', opts = {} },
  { 'echasnovski/mini.comment', event = 'VeryLazy', opts = {} },
  { 'echasnovski/mini.move', event = 'VeryLazy', opts = {} },
  { 'echasnovski/mini.surround', event = 'VeryLazy', opts = {} },
  { 'echasnovski/mini.cursorword', event = 'VeryLazy', opts = {} },
  { 'echasnovski/mini.pairs', event = 'VeryLazy', opts = {} },
  { 'echasnovski/mini.trailspace', event = 'VeryLazy', opts = {} },
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
