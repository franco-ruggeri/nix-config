return {
  "jay-babu/mason-null-ls.nvim",
  dependencies = {
    "williamboman/mason.nvim",       -- package manager for linters and formatters
    "nvimtools/none-ls.nvim",
    "nvim-lua/plenary.nvim",         -- required
    "nvim-telescope/telescope.nvim", -- for LSP pickers (used in on_attach)
  },
  config = function()
    local null_ls = require("null-ls")
    local mason_null_ls = require("mason-null-ls")
    local is_venv = vim.env.VIRTUAL_ENV ~= nil

    mason_null_ls.setup({
      ensure_installed = {},
      automatic_installation = false,
      handlers = {
        -- Default handler: nothing special, just use the default setup
        function(source_name, methods)
          mason_null_ls.default_setup(source_name, methods)
        end,

        -- Use code quality tools only if installed in the venv.
        -- Use the binary from the venv, so that:
        -- - Tools see installed packages.
        -- - Tools use the config in pyproject.toml.
        pylint = function()
          if is_venv then
            local overrides = { command = vim.env.VIRTUAL_ENV .. "/bin/pylint" }
            null_ls.register(null_ls.builtins.diagnostics.pylint.with(overrides))
          end
        end,
        mypy = function()
          if is_venv then
            local overrides = { command = vim.env.VIRTUAL_ENV .. "/bin/mypy" }
            null_ls.register(null_ls.builtins.diagnostics.mypy.with(overrides))
          end
        end,
        black = function()
          if is_venv then
            local overrides = { command = vim.env.VIRTUAL_ENV .. "/bin/black" }
            null_ls.register(null_ls.builtins.formatting.black.with(overrides))
          end
        end,
      },
    })
  end,
}
