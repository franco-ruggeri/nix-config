return {
  -- lspconfig configures the built-in neovim LSP client
  "neovim/nvim-lspconfig",
  dependencies = {
    -- mason is a package manager for LSP servers, among other things
    { "williamboman/mason.nvim" },
    -- mason-lspconfig automates the LSP client setup
    { "williamboman/mason-lspconfig.nvim" },
  },
  config = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(event)
        -- TODO: add keymaps to use LSP functions
      end,
    })

    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = { "lua_ls" },
    })

    -- Automatic LSP client setup for each LSP server installed with Mason.
    -- Otherwise, we'd need to setup the LSP client explicitly for every LSP server.
    require("mason-lspconfig").setup_handlers({
      function (server_name)
        require("lspconfig")[server_name].setup({}) -- table is required
      end,
    })
  end,
}
