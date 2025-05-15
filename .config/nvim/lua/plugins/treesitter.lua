return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	main = "nvim-treesitter.configs",
	opts = {
		ensure_installed = "all",
		highlight = { enable = true, disable = { "latex" } },
		indent = { enable = true, disable = { "latex" } },
	},
}
