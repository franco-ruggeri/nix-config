return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- for icons
	},
	opts = {
		options = {
			globalstatus = true,
		},
		-- From defaults: https://github.com/folke/trouble.nvim/blob/85bedb7eb7fa331a2ccbecb9202d8abba64d37b3/lua/trouble/sources/lsp.lua#L51
		-- ====================
		-- Adding LSP status to show LSP clients attached to the current buffer...
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch", "diff", "diagnostics" },
			lualine_c = { "filename" },
			lualine_x = { "lsp_status", "encoding", "fileformat", "filetype" }, -- ... here!
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
		-- ====================
		tabline = {
			lualine_a = { "tabs" },
			lualine_b = { "filename" },
		},
	},
}
