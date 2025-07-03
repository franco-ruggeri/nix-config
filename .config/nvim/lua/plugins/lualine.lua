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
		sections = {
			lualine_c = { "filename", "lsp_status" }, -- + LSP status
		},
		tabline = {
			lualine_a = { "tabs" },
			lualine_b = { "filename" },
		},
	},
	config = function(_, opts)
		local lualine = require("lualine")

		-- + MCPHub status
		local lualine_x = lualine.get_config().sections.lualine_x
		table.insert(lualine_x, 1, { require("mcphub.extensions.lualine") })
		opts.sections.lualine_x = lualine_x

		lualine.setup(opts)
	end,
}
