return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- for icons
		"letieu/harpoon-lualine", -- for harpoon component
		{ "franco-ruggeri/codecompanion-lualine.nvim", version = false, dev = true }, -- for codecompanion component
		{ "franco-ruggeri/mcphub-lualine.nvim", version = false, dev = true }, -- for mcphub component
	},
	opts = {
		options = {
			globalstatus = true,
		},
		sections = {
			-- Add lsp_status to know which LSP clients are active.
			-- Remove fileformat and encoding to save space.
			lualine_x = {
				"lsp_status",
				"filetype",
			},
		},
		tabline = {
			lualine_a = { "tabs" },
			lualine_b = {
				{
					"harpoon2",
					icon = "󰀱 ",
					indicators = { "1", "2", "3", "4", "5", "6", "7", "8", "9" },
					active_indicators = { "[1]", "[2]", "[3]", "[4]", "[5]", "[6]", "[7]", "[8]", "[9]" },
				},
			},
			lualine_c = { { "filename", path = 4 } },
			lualine_x = { "codecompanion", "mcphub" },
		},
	},
}
