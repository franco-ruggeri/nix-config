return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	main = "nvim-treesitter.configs",
	opts = {
		ensure_installed = { "markdown", "markdown_inline" }, -- for CodeCompanion
		auto_install = true,
		highlight = {
			enable = true,
			disable = {
				"gitcommit", -- conflicts with default syntax higlighting
			},
		},
		indent = {
			enable = true,
		},
	},
}
