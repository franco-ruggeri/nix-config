return {
  -- lspconfig configures the built-in neovim LSP client
  "neovim/nvim-lspconfig",
  dependencies = {
    -- mason is a package manager for LSP servers, among other things
    { "williamboman/mason.nvim" },
    -- mason-lspconfig automates the LSP client setup
    { "williamboman/mason-lspconfig.nvim" },
    -- cmp-nvim-lsp provides extra capabilities for autocompletion
    { "hrsh7th/cmp-nvim-lsp" },
  },
  config = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(event)
        local telescope = require("telescope.builtin")

        -- Note: you can press <C-t> to jump back
        vim.keymap.set("n", "gd", telescope.lsp_definitions, { buffer = event.buf, desc = "[g]oto [d]efinition" })
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = event.buf, desc = "[g]oto [d]eclaration" })
      end,
    })

    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = {},
      automatic_installation = false,
    })

    -- Automatic LSP client setup for each LSP server installed with Mason.
    -- Otherwise, we'd need to set up the LSP client explicitly for every LSP server.
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    require("mason-lspconfig").setup_handlers({
      function (server_name)
        require("lspconfig")[server_name].setup({capabilities = capabilities})
      end,
    })
  end,
}
