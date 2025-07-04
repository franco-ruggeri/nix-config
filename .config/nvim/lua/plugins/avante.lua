return {
	"yetone/avante.nvim",
	version = false, -- latest commit, recommended
	build = "make",
	event = "VeryLazy",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"MunifTanjim/nui.nvim", -- required
		"nvim-telescope/telescope.nvim", -- for file_selector provider
		"nvim-tree/nvim-web-devicons", -- for icons
		"zbirenbaum/copilot.lua", -- for copilot provider
		"MeanderingProgrammer/render-markdown.nvim",
	},
	opts = {
		provider = "copilot",
		providers = {
			copilot = {
				model = "gemini-2.5-pro",
			},
		},
		hints = { enabled = false },
		windows = {
			ask = {
				start_insert = false, -- for consistency with other windows
			},
		},
		mappings = {
			sidebar = {
				close_from_input = { normal = "q" }, -- for consistency with edgy.nvim
			},
		},
		-- Integration with mcphub.nvim
		-- See https://ravitemer.github.io/mcphub.nvim/extensions/avante.html
		-- ====================
		system_prompt = function()
			local hub = require("mcphub").get_hub_instance()
			return hub and hub:get_active_servers_prompt() or ""
		end,
		custom_tools = function()
			return { require("mcphub.extensions.avante").mcp_tool() }
		end,
		-- ====================
	},
}
