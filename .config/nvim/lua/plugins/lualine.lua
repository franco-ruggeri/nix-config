local function get_lualine_component_lazy(lazy_module, component)
	local M = require("lualine.component"):extend()

	function M:init(options)
		M.super.init(self, options)
		self.options = options or {}
	end

	function M:update_status()
		if not package.loaded[lazy_module] then
			-- Module not loaded yet. Act as a dummy component that shows nothing.
			return nil
		else
			-- Module loaded. It's time to initialize the component.
			-- Make self:<method> point to the mcphub component's respective method.
			-- So, after this call, self:update_status() will point to the actual component's method.
			setmetatable(self, { __index = require(component) })
			self:init(self.options)
		end
	end

	return M
end

return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- for icons
		"letieu/harpoon-lualine", -- for harpoon component
		{ "franco-ruggeri/codecompanion-lualine.nvim", dev = true }, -- for codecompanion component
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
		table.insert(opts.tabline.lualine_x, { get_lualine_component_lazy("mcphub", "mcphub.extensions.lualine") })
		require("lualine").setup(opts)
	end,
}
