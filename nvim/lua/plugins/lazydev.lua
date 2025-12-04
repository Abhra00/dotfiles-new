-- ================================================================================================
-- TITLE : Lazydev nvim
-- ABOUT : For faster lua_ls startup
-- LINKS : lazydev.nvim       : https://github.com/folke/lazydev.nvim
-- ================================================================================================

return {
  'folke/lazydev.nvim',
  ft = 'lua',
  opts = {
    library = {
      -- Load luvit types when the `vim.uv` word is found
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      -- Add snacks types
      { path = 'snacks.nvim', words = { 'Snacks', 'snacks.Config' } },
    },
  },
}
