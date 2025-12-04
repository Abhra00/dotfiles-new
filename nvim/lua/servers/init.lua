-- Get default LSP capabilities
local default_capabilities = vim.lsp.protocol.make_client_capabilities()

-- Merge with blink.cmp capabilities
local capabilities = require('blink.cmp').get_lsp_capabilities(default_capabilities)

-- Language Server Protocol (LSP)
require 'servers.lua_ls'(capabilities)
require 'servers.ts_ls'(capabilities)
require 'servers.tailwindcss'(capabilities)
require 'servers.clangd'(capabilities)
require 'servers.bashls'(capabilities)
require 'servers.rust_analyzer'(capabilities)

-- Enable lsp servers
vim.lsp.enable {
  'lua_ls',
  'ts_ls',
  'tailwindcss',
  'clangd',
  'bashls',
  'rust_analyzer',
}
