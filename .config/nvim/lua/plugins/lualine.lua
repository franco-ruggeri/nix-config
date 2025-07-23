-- TODO: wrap into a plugin
local function get_mcphub_component()
	local M = require("lualine.component"):extend()

	local default_options = {
		icon = "󰐻 ",
		spinner_symbols = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
		stopped_symbol = "-",
	}

	function M:init(options)
		M.super.init(self, options)
		self.options = vim.tbl_deep_extend("keep", self.options or {}, default_options)
		self.spinner_index = 0
	end

	function M:update_status()
		if not vim.g.loaded_mcphub then
			return nil
		end

		local status = vim.g.mcphub_status
		local text = nil
		if not status then
			text = self.options.stopped_symbol
		elseif vim.g.mcphub_executing or status == "starting" or status == "restarting" then
			self.spinner_index = (self.spinner_index % #self.options.spinner_symbols) + 1
			text = self.options.spinner_symbols[self.spinner_index]
		else
			text = vim.g.mcphub_servers_count or 0
			text = tostring(text)
		end
		return text
	end

	return M
end

return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- for icons
		"letieu/harpoon-lualine", -- for harpoon component
		{ "franco-ruggeri/codecompanion-lualine.nvim", version = false, dev = true }, -- for codecompanion component
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
			lualine_c = { "filename" },
			lualine_x = { "codecompanion" },
		},
	},
	config = function(_, opts)
		table.insert(opts.tabline.lualine_x, { get_mcphub_component() })
		require("lualine").setup(opts)
	end,
}
