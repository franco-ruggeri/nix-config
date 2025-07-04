return {
	"olimorris/codecompanion.nvim",
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
	dependencies = {
		{
			"nvim-lua/plenary.nvim", -- required
			version = false, -- latest commit, see https://codecompanion.olimorris.dev/installation.html
		},
		"nvim-treesitter/nvim-treesitter", -- required
		"MeanderingProgrammer/render-markdown.nvim", -- for rendering chat
		"ravitemer/mcphub.nvim", -- for integration with mcphub.nvim
		"zbirenbaum/copilot.lua", -- for copilot authentication
		"echasnovski/mini.diff", -- for cleaner diff with @{insert_edit_into_file}
	},
	opts = {
		adapters = {
			copilot = function() -- select default model
				return require("codecompanion.adapters").extend("copilot", {
					schema = {
						model = { default = "claude-3.7-sonnet" },
					},
				})
			end,
		},
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
	config = function(_, opts)
		require("codecompanion").setup(opts)

		-- By default, CodeCompanionChatVariable is linked to Identifier.
		-- The rose-pine colorscheme highlights Identifiers as normal text.
		-- We change to make variables highlighted differently from text.
		vim.api.nvim_set_hl(0, "CodeCompanionChatVariable", { link = "@tag.attribute" })
	end,
}
