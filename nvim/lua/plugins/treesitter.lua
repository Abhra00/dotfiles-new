-- Treesitter
-- Nvim-treesitter for syntax highlighting
-- Nvim-treesitter-context for showing the context of the currently visible buffer contents

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    version = false,
    build = function()
      local ok, TS = pcall(require, 'nvim-treesitter')
      if not ok then
        vim.notify('nvim-treesitter not available yet. Please restart Neovim and run :TSUpdate', vim.log.levels.WARN)
        return
      end
      TS.update(nil, { summary = true })
    end,
    event = { "BufReadPre", "BufNewFile", "VeryLazy" },
    cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
    config = function()
      local TS = require 'nvim-treesitter'
      TS.setup {
        install_dir = vim.fn.stdpath 'data' .. '/site',
      }

      -- Parsers to be installed
      local parsers = {
        'bash',
        'c',
        'cpp',
        'css',
        'diff',
        'fish',
        'git_config',
        'git_rebase',
        'gitcommit',
        'gitignore',
        'html',
        'java',
        'javascript',
        'json',
        'latex',
        'lua',
        'luadoc',
        'make',
        'markdown',
        'markdown_inline',
        'ninja',
        'python',
        'query',
        'ron',
        'rst',
        'rust',
        'regex',
        'scss',
        'svelte',
        'sql',
        'toml',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'xml',
      }

      -- Filetypes to ignore for treesitter
      local ignore_filetypes = {
        'lazy',
        'mason',
      }

      vim.schedule(function()
        TS.install(parsers, { summary = false })
      end)

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('TreesitterSetup', { clear = true }),
        callback = function(ev)
          if vim.tbl_contains(ignore_filetypes, ev.match) then
            return
          end

          -- Start treesitter highlighting & set indentation & folding
          pcall(vim.treesitter.start, ev.buf)
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        end,
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('nvim-treesitter-textobjects').setup {
        select = {
          lookahead = true,
        },
        move = {
          set_jumps = true,
        },
      }

      local map = vim.keymap.set

      -- Textobject selections
      map({ 'x', 'o' }, 'af', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects')
      end, { desc = 'outer function' })
      map({ 'x', 'o' }, 'if', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@function.inner', 'textobjects')
      end, { desc = 'inner function' })
      map({ 'x', 'o' }, 'ac', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@class.outer', 'textobjects')
      end, { desc = 'outer class' })
      map({ 'x', 'o' }, 'ic', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@class.inner', 'textobjects')
      end, { desc = 'inner class' })
      map({ 'x', 'o' }, 'aa', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@parameter.outer', 'textobjects')
      end, { desc = 'outer argument' })
      map({ 'x', 'o' }, 'ia', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@parameter.inner', 'textobjects')
      end, { desc = 'inner argument' })

      -- Movement
      map({ 'n', 'x', 'o' }, ']f', function()
        require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer', 'textobjects')
      end, { desc = 'next function start' })
      map({ 'n', 'x', 'o' }, '[f', function()
        require('nvim-treesitter-textobjects.move').goto_previous_start('@function.outer', 'textobjects')
      end, { desc = 'previous function start' })
      map({ 'n', 'x', 'o' }, ']F', function()
        require('nvim-treesitter-textobjects.move').goto_next_end('@function.outer', 'textobjects')
      end, { desc = 'next function end' })
      map({ 'n', 'x', 'o' }, '[F', function()
        require('nvim-treesitter-textobjects.move').goto_previous_end('@function.outer', 'textobjects')
      end, { desc = 'previous function end' })
      map({ 'n', 'x', 'o' }, ']k', function()
        require('nvim-treesitter-textobjects.move').goto_next_start('@class.outer', 'textobjects')
      end, { desc = 'next class start' })
      map({ 'n', 'x', 'o' }, '[k', function()
        require('nvim-treesitter-textobjects.move').goto_previous_start('@class.outer', 'textobjects')
      end, { desc = 'previous class start' })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      max_lines = 3,
      min_window_height = 20,
    },
    keys = {
      {
        '[C',
        function()
          require('treesitter-context').go_to_context()
        end,
        desc = 'go to context',
      },
    },
  },
}
