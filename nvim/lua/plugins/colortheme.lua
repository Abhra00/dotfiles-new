-- ================================================================================================
-- TITLE : tokyonight-nvim
-- ABOUT : A cool dark vivid tokyonight color theme created by folke(the G.O.A.T)
-- LINKS :
--   > github : https://github.com/folke/tokyonight.nvim
-- ================================================================================================

return {
  'folke/tokyonight.nvim',
  lazy = false,
  priority = 1000,
  opts = {},
  init = function()
    vim.cmd [[colorscheme tokyonight-night]]
  end,
}
