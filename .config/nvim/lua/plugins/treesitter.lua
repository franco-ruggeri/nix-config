return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	main = "nvim-treesitter.configs",
	opts = {
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
		-- Parsers required by CodeCompanion.
		-- They wouldn't be installed automatically, as the codecompanion filetype doesn't trigger installation.
		ensure_installed = { "markdown", "markdown_inline", "yaml" },
	},
}
