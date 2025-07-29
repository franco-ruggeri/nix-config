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
		-- Some parsers are required by other plugins but the automatic installation is not triggered by them
		ensure_installed = {
			-- CodeCompanion
			"markdown",
			"markdown_inline",
			"yaml",
			-- render-markdown
			"latex",
		},
	},
}
