return {
	"olimorris/codecompanion.nvim",
	version = false, -- TODO: remove after new release >17.6.0, need https://github.com/olimorris/codecompanion.nvim/commit/17f7cbb6cabdc12195f164acf4c59c7c7c205b64
	dev = true,
	dependencies = {
		{
			"nvim-lua/plenary.nvim", -- required
			version = false, -- latest commit, see https://codecompanion.olimorris.dev/installation.html
		},
		"nvim-treesitter/nvim-treesitter", -- required
		"MeanderingProgrammer/render-markdown.nvim", -- for rendering chat
		"ravitemer/mcphub.nvim", -- for MCP servers
		"zbirenbaum/copilot.lua", -- for copilot authentication
		"echasnovski/mini.diff", -- for cleaner diff with @{insert_edit_into_file}
		"franco-ruggeri/codecompanion-spinner.nvim", -- for spinner
	},
	keys = {
		{
			"<Leader>Aa",
			"<Cmd>CodeCompanionActions<CR>",
			mode = { "n", "x" },
			desc = "[A]I CodeCompanion [a]ctions",
		},
		{
			"<Leader>Ac",
			"<Cmd>CodeCompanionChat<CR>",
			mode = { "n", "x" },
			desc = "[A]I CodeCompanion [c]hat",
		},
		{
			"<Leader>Ai",
			"<Cmd>CodeCompanion<CR>",
			mode = { "n", "x" },
			desc = "[A]I CodeCompanion [i]nline",
		},
	},
	cmd = { "CodeCompanionActions", "CodeCompanionChat", "CodeCompanion" },
	opts = {
		strategies = {
			chat = {
				tools = {
					opts = {
						-- Submit errors to the LLM, so it can suggest fixes.
						-- See https://codecompanion.olimorris.dev/configuration/chat-buffer.html#auto-submit-tool-output-recursion
						auto_submit_errors = true,
					},
				},
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
