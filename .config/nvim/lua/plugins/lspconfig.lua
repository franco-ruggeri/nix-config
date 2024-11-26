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
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end
        local telescope = require("telescope.builtin")

        -- Note: you can press <C-t> to jump back
        map('gd', telescope.lsp_definitions, '[G]oto [D]efinition')
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        map('gr', telescope.lsp_references, '[G]oto [R]eferences')
        map('gI', telescope.lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>ds', telescope.lsp_document_symbols, '[D]ocument [S]ymbols')
        map('<leader>ws', telescope.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
        map('<leader>td', telescope.lsp_type_definitions, '[T]ype [D]efinition')
      end,
    })

    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = { "lua_ls" },
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
