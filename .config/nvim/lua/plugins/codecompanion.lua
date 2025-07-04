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
		strategies = {
			chat = {
				adapter = {
					name = "copilot",
					model = "gemini-2.5-pro",
				},
				roles = {
					llm = function(adapter)
						return " " .. adapter.formatted_name
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
			mcphub = {
				callback = "mcphub.extensions.codecompanion",
				opts = {
					make_vars = true,
					make_slash_commands = true,
					show_result_in_chat = true,
				},
			},
		},
	},
}
