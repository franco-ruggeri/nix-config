return {
	"olimorris/codecompanion.nvim",
	event = "VeryLazy",
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
				keymaps = {
					-- Swap close and stop for consistency with edgy.nvim
					close = { modes = { n = "q" } },
					stop = { modes = { n = "<C-c>", i = "<C-c>" } },
				},
				tools = {
					opts = {
						default_tools = {
							-- TODO: do I need default tools?
						},
					},
				},
				opts = {
					-- TODO: need to open it in the current buffer (the one indicated by #{buffer}... how?
					-- by default it opens a new tab, I don't want that
					-- See https://codecompanion.olimorris.dev/configuration/chat-buffer.html#jump-action
					goto_file_action = "edit",
				},
				roles = {
					llm = function(adapter)
						return "󱜙 " .. adapter.formatted_name
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
	config = function(_, opts)
		require("codecompanion").setup(opts)
		-- TODO: check other commands and add the useful ones
		-- TODO: add commands
		-- TODO: change keymaps
		vim.keymap.set({ "n", "v" }, "<Leader>cc", "<Cmd>CodeCompanionActions<CR>", { desc = "[A]I [a]ctions" })
		-- vim.keymap.set("n", "<Leader>ac", "<Cmd>CodeCompanionChat<CR>", { desc = "[A]I [c]hat" })
		-- vim.keymap.set("v", "<Leader>ac", "<Cmd>CodeCompanionChat Add<CR>", { desc = "[A]I [c]hat" })
	end,
}
