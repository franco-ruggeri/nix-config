return {
	"yetone/avante.nvim",
	version = false, -- latest commit, recommended
	build = "make",
	keys = {
		-- Only for lazy-loading, no actual functionality for <Leader>a
		{ "<Leader>a", mode = { "n", "x" }, desc = "[A]I Avante" },
	},
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"MunifTanjim/nui.nvim", -- required
		"nvim-telescope/telescope.nvim", -- for file_selector provider
		"nvim-tree/nvim-web-devicons", -- for icons
		"ravitemer/mcphub.nvim", -- for MCP servers
		"zbirenbaum/copilot.lua", -- for copilot provider
		"MeanderingProgrammer/render-markdown.nvim",
	},
	opts = {
		provider = "copilot",
		providers = {
			copilot = { model = "gpt-4.1" },
		},
		hints = { enabled = false },
		windows = {
			ask = {
				start_insert = false, -- for consistency with other windows
			},
		},
		mappings = {
			sidebar = {
				close_from_input = { normal = "q" }, -- for consistency with other windows
			},
		},
		behaviour = {
			enable_token_counting = false, -- sluggish while typing
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
	config = function(_, opts)
		require("avante").setup(opts)

		vim.api.nvim_set_hl(0, "AvanteSidebarNormal", { link = "Normal" })
		vim.api.nvim_set_hl(0, "AvanteSidebarWinHorizontalSeparator", { link = "Normal" })
		vim.api.nvim_set_hl(0, "AvanteSidebarWinSeparator", { link = "WinSeparator" })
	end,
}
