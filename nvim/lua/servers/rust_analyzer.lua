-- ================================================================================================
-- TITLE : rust_analyzer LSP Setup
-- LINKS :
--   > github: https://github.com/rust-analyzer/rust-analyzer
-- ================================================================================================

--- @param capabilities table LSP client capabilities (typically from bink-cmp or similar)
--- @return nil
return function(capabilities)
  vim.lsp.config('rust_analyzer', {
    cmd = { 'rust-analyzer' },
    filetypes = { 'rust' },
    root_markers = { 'Cargo.toml', 'rust-project.json', '.git' },
    capabilities = capabilities,
    settings = {
      ['rust-analyzer'] = {
        cargo = { allFeatures = true },
      },
    },
  })
end
