-- ================================================================================================
-- TITLE : springboot-nvim
-- ABOUT : Simplify java spring boot development
-- -- LINKS :
--   > github : https://github.com/elmcgill/springboot-nvim
-- ================================================================================================

return {
  'elmcgill/springboot-nvim',
  ft = 'java',
  dependencies = {
    'neovim/nvim-lspconfig',
    'mfussenegger/nvim-jdtls',
  },
  config = function()
    -- gain acces to the springboot nvim plugin and its functions
    local springboot_nvim = require 'springboot-nvim'
    -- Only load springboot-nvim if it's really a Spring Boot project
    local is_spring_boot_project = vim.fn.filereadable 'pom.xml' == 1 or vim.fn.filereadable 'build.gradle' == 1 or vim.fn.filereadable 'build.gradle.kts' == 1

    if not is_spring_boot_project then
      vim.notify('Not a Spring Boot project — skipping springboot-nvim setup', vim.log.levels.WARN)
      return
    end

    -- set a vim motion to <Space> + <Shift>J + r to run the spring boot project in a vim terminal
    vim.keymap.set('n', '<leader>Jr', springboot_nvim.boot_run, { desc = 'Java Run Spring Boot' })
    -- set a vim motion to <Space> + <Shift>J + c to open the generate class ui to create a class
    vim.keymap.set('n', '<leader>Jc', springboot_nvim.generate_class, { desc = 'Java Create Class' })
    -- set a vim motion to <Space> + <Shift>J + i to open the generate interface ui to create an interface
    vim.keymap.set('n', '<leader>Ji', springboot_nvim.generate_interface, { desc = 'Java Create Interface' })
    -- set a vim motion to <Space> + <Shift>J + e to open the generate enum ui to create an enum
    vim.keymap.set('n', '<leader>Je', springboot_nvim.generate_enum, { desc = 'Java Create Enum' })

    -- run the setup function with default configuration
    springboot_nvim.setup()
  end,
}
