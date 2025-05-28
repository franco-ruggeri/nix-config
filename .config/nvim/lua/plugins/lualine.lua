return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- for icons
	},
	opts = {
		options = {
			globalstatus = true,
		},
		tabline = {
			lualine_a = { "tabs" },
			lualine_b = { "filename" },
		},
	},
}
