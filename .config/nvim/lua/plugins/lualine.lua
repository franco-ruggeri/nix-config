return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- for icons
		"ravitemer/mcphub.nvim", -- for mcphub component
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
	config = function(_, opts)
		opts.sections = {
			lualine_x = {
				"lsp_status",
				"filetype",
				{ require("mcphub.extensions.lualine") },
			},
		}
		require("lualine").setup(opts)
	end,
}
