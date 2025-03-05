return {
  "nvimtools/none-ls.nvim",      -- maintained fork of null-ls
  dependencies = {
    "nvim-lua/plenary.nvim",     -- required dependency
    "williamboman/mason.nvim",   -- package manager for linters and formatters
    "jay-babu/mason-null-ls.nvim", -- automates null-ns setup
  },
  config = function()
    require("null-ls").setup()

    -- Automatic registration in null-ls of each package installed with Mason.
    require("mason-null-ls").setup({ handlers = {}, ensure_installed = {}, automatic_installation = false })
  end,
}
