return {
	"williamboman/mason-lspconfig.nvim",
	dependencies = {
		"williamboman/mason.nvim", -- package manager for LSP servers
		"neovim/nvim-lspconfig",
		"hrsh7th/cmp-nvim-lsp", -- provides extra capabilities for autocompletion
	},
	config = function()
		local lspconfig = require("lspconfig")
		local mason_lspconfig = require("mason-lspconfig")
		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		mason_lspconfig.setup()
		mason_lspconfig.setup_handlers({
			function(server_name)
				lspconfig[server_name].setup({ capabilities = capabilities })
			end,
		})
	end,
}
