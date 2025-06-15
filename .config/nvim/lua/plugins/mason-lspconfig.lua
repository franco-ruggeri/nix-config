return {
	"williamboman/mason-lspconfig.nvim",
	dependencies = {
		"williamboman/mason.nvim", -- package manager for language servers
		"neovim/nvim-lspconfig", -- default configurations for LSP clients
	},
	opts = {
		automatic_enable = {
			exclude = {
				"jdtls", -- handled separately by nvim-jdtls
			},
		},
	},
}
