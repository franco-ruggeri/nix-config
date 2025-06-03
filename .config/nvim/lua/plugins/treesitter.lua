return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	main = "nvim-treesitter.configs",
	opts = {
		auto_install = true,
		highlight = {
			enable = true,
			disable = {
				"latex", -- conflicts with VimTeX
				"gitcommit", -- conflicts with default syntax higlighting
			},
		},
		indent = {
			enable = true,
			disable = {
				"latex", -- conflicts with VimTeX
			},
		},
	},
}
