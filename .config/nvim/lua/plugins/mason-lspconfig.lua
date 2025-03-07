return {
  "williamboman/mason-lspconfig.nvim",
  dependencies = {
    "williamboman/mason.nvim", -- package manager for LSP servers
    "neovim/nvim-lspconfig",
    "hrsh7th/cmp-nvim-lsp",  -- provides extra capabilities for autocompletion
  },
  config = function()
    -- Automatic configuration of LSP client for each LSP server installed with Mason
    require("mason-lspconfig").setup()
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    require("mason-lspconfig").setup_handlers({
      function(server_name)
        require("lspconfig")[server_name].setup({ capabilities = capabilities })
      end,
    })
  end,
}
