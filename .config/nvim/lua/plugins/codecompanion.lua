return {
	"olimorris/codecompanion.nvim",
	keys = {
		{ "<Leader>am", "<Cmd>CodeCompanionActions<CR>", mode = { "n", "x" }, desc = "[A]I CodeCompanion [m]enu" },
	},
	dependencies = {
		{
			"nvim-lua/plenary.nvim", -- required
			version = false, -- latest commit, see https://codecompanion.olimorris.dev/installation.html
		},
		"nvim-treesitter/nvim-treesitter", -- required
		"MeanderingProgrammer/render-markdown.nvim", -- for rendering chat
		"ravitemer/mcphub.nvim", -- for integration with mcphub.nvim
		"zbirenbaum/copilot.lua", -- for copilot authentication
	},
	opts = {
		adapters = {
			copilot = function() -- select default model
				return require("codecompanion.adapters").extend("copilot", {
					schema = {
						model = { default = "gemini-2.5-pro" },
					},
				})
			end,
		},
		strategies = {
			chat = {
				roles = { -- make rendered roles nicer
					llm = function(adapter)
						return (" %s"):format(adapter.formatted_name)
					end,
					user = " User",
				},
			},
		},
		display = {
			action_palette = {
				provider = "default", -- use vim.ui.select()
			},
		},
		-- Integration with mcphub.nvim
		-- See https://ravitemer.github.io/mcphub.nvim/extensions/codecompanion.html
		extensions = {
			mcphub = { callback = "mcphub.extensions.codecompanion" },
		},
	},
}
