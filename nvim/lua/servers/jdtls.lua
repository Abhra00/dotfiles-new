-- ================================================================================================
-- TITLE : nvim-jdtls.nvim
-- ABOUT : config for nvim jdtls
-- LINKS :
--   > github: https://github.com/mfussenegger/nvim-jdtls
-- ================================================================================================

local M = {}

function M:setup()
  -- Configure paths
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
  local workspace_dir = vim.fn.stdpath 'data' .. package.config:sub(1, 1) .. 'jdtls-workspace' .. package.config:sub(1, 1) .. project_name
  local mason_path = vim.env.MASON or vim.fn.expand '~/.local/share/nvim/mason'
  local jdtls_path = mason_path .. '/packages/jdtls'
  local launcher_path = vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')
  local lombok_path = jdtls_path .. '/lombok.jar'
  local os_name = vim.uv.os_uname().sysname
  local config_dir = jdtls_path .. '/config_' .. (os_name == 'Linux' and 'linux' or os_name == 'Darwin' and 'mac' or 'win')
  local java_debug_path = mason_path .. '/packages/java-debug-adapter'
  local java_test_path = mason_path .. '/packages/java-test'

  -- Get the default extended client capablities of the JDTLS language server
  local extendedClientCapabilities = require('jdtls').extendedClientCapabilities
  -- Modify one property called resolveAdditionalTextEditsSupport and set it to true
  extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

  -- Merge jdtls capabilities with blink.cmp capablities
  local capabilities = {
    workspace = {
      configuration = true,
    },
    textDocument = {
      completion = {
        snippetSupport = true,
      },
    },
  }

  local lsp_capabilities = require('blink.cmp').get_lsp_capabilities()
  capabilities = vim.tbl_deep_extend('force', lsp_capabilities, capabilities)

  -- Setup java specific keymaps
  local function java_keymaps()
    local opts = { buffer = true }
    -- stylua: ignore start
    vim.keymap.set('n', '<leader>Jo', "<Cmd>lua require('jdtls').organize_imports()<CR>", vim.tbl_extend('force', opts, { desc = 'Java Organize Imports' }))
    vim.keymap.set('n', '<leader>Jv', "<Cmd>lua require('jdtls').extract_variable()<CR>", vim.tbl_extend('force', opts, { desc = 'Java Extract Variable' }))
    vim.keymap.set('v', '<leader>Jv', "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", vim.tbl_extend('force', opts, { desc = 'Java Extract Variable' }))
    vim.keymap.set('n', '<leader>JC', "<Cmd>lua require('jdtls').extract_constant()<CR>", vim.tbl_extend('force', opts, { desc = 'Java Extract Constant' }))
    vim.keymap.set('v', '<leader>JC', "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", vim.tbl_extend('force', opts, { desc = 'Java Extract Constant' }))
    vim.keymap.set('n', '<leader>Jt', "<Cmd>lua require('jdtls').test_nearest_method()<CR>", vim.tbl_extend('force', opts, { desc = 'Java Test Method' }))
    vim.keymap.set('v', '<leader>Jt', "<Esc><Cmd>lua require('jdtls').test_nearest_method(true)<CR>", vim.tbl_extend('force', opts, { desc = 'Java Test Method' }))
    vim.keymap.set('n', '<leader>JT', "<Cmd>lua require('jdtls').test_class()<CR>", vim.tbl_extend('force', opts, { desc = 'Java Test Class' }))
    vim.keymap.set('n', '<leader>Ju', '<Cmd>JdtUpdateConfig<CR>', vim.tbl_extend('force', opts, { desc = 'Java Update Config' }))
    -- stylua: ignore end
  end
  -- Function that will be ran once the language server is attached
  local on_attach = function(_, bufnr)
    -- Map the Java specific key mappings once the server is attached
    java_keymaps()

    -- Setup the java debug adapter of the JDTLS server
    require('jdtls.dap').setup_dap()

    -- Find the main method(s) of the application so the debug adapter can successfully start up the application
    -- Sometimes this will randomly fail if language server takes to long to startup for the project, if a ClassDefNotFoundException occurs when running
    -- the debug tool, attempt to run the debug tool while in the main class of the application, or restart the neovim instance
    -- Unfortunately I have not found an elegant way to ensure this works 100%
    require('jdtls.dap').setup_dap_main_class_configs()
    -- Refresh the codelens
    -- Code lens enables features such as code reference counts, implemenation counts, and more.
    vim.lsp.codelens.refresh()

    -- Setup a function that automatically runs every time a java file is saved to refresh the code lens
    vim.api.nvim_create_autocmd('BufWritePost', {
      pattern = { '*.java' },
      callback = function()
        local _, _ = pcall(vim.lsp.codelens.refresh)
      end,
    })
  end
  -- Get bundles
  local function get_bundles()
    local bundles = {
      vim.fn.glob(java_debug_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar', true),
    }
    -- Add all of the Jars for running tests in debug mode to the bundles list
    vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_path .. '/extension/server/*.jar', true), '\n'))
    return bundles
  end
  -- Define config
  local config = {
    cmd = {
      'java',
      '-Declipse.application=org.eclipse.jdt.ls.core.id1',
      '-Dosgi.bundles.defaultStartLevel=4',
      '-Declipse.product=org.eclipse.jdt.ls.core.product',
      '-Dlog.protocol=true',
      '-Dlog.level=ALL',
      '-Xmx1g',
      '--add-modules=ALL-SYSTEM',
      '--add-opens',
      'java.base/java.util=ALL-UNNAMED',
      '--add-opens',
      'java.base/java.lang=ALL-UNNAMED',
      '-javaagent:' .. lombok_path,
      '-jar',
      launcher_path,
      '-configuration',
      config_dir,
      '-data',
      workspace_dir,
    },
    root_dir = require('jdtls.setup').find_root { '.git', 'mvnw', 'gradlew' },
    settings = {
      java = {
        inlayHints = { parameterNames = { enabled = 'all' } },
        configuration = { runtimes = {} },
        autobuild = { enabled = true },
        completion = {
          favoriteStaticMembers = {
            'java.util.Objects.requireNonNull',
            'java.util.Objects.requireNonNullElse',
            'java.util.Collections.*',
            'java.util.Arrays.*',
            'java.lang.Math.*',
          },
        },
        format = {
          settings = {
            url = vim.fn.expand '~/.local/share/java/Formatter/google-style.xml',
            profile = 'GoogleStyle',
          },
        },
      },
    },
    capabilities = capabilities,
    init_options = {
      bundles = get_bundles(),
      extendedClientCapabilities = extendedClientCapabilities,
    },
    on_attach = on_attach,
  }
  require('jdtls').start_or_attach(config)
end

return M
