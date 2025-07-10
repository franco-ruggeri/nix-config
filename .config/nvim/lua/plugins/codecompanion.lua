-- If available, open the last chat, otherwise open a new chat
local function open_chat()
	local chat = require("codecompanion.strategies.chat").last_chat()
	if chat then
		chat.ui:open()
		vim.api.nvim_set_current_win(chat.ui.winnr)
	else
		vim.cmd("CodeCompanionChat")
	end
end

return {
	"olimorris/codecompanion.nvim",
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
		{ "franco-ruggeri/codecompanion-spinner.nvim", dev = true }, -- for spinner
	},
	keys = {
		{ "<Leader>Aa", "<Cmd>CodeCompanionActions<CR>", mode = { "n", "x" }, desc = "[A]I CodeCompanion [a]ctions" },
		{ "<Leader>Ac", open_chat, mode = { "n", "x" }, desc = "[A]I CodeCompanion [c]hat" },
		{ "<Leader>AC", "<Cmd>CodeCompanionChat<CR>", mode = { "n", "x" }, desc = "[A]I CodeCompanion new [c]hat" },
		{
			"<Leader>An",
			":CodeCompanionCmd ",
			mode = { "n", "x" },
			desc = "[A]I CodeCompanion [N]eovim command",
		},
		{ "<Leader>Ai", "<Cmd>CodeCompanion<CR>", mode = { "n", "x" }, desc = "[A]I CodeCompanion [i]nline" },
	},
	cmd = { "CodeCompanionActions", "CodeCompanionChat", "CodeCompanionCmd", "CodeCompanion" },
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
		extensions = {
			spinner = {
				opts = {
					-- log_level = "debug",
				},
			},
			-- Integration with mcphub.nvim
			-- See https://ravitemer.github.io/mcphub.nvim/extensions/codecompanion.html
			mcphub = { callback = "mcphub.extensions.codecompanion" },
		},
	},
	config = function(_, opts)
		require("codecompanion").setup(opts)

		-- With rose-pine, chat variables would be highlighted as normal text.
		-- To make them stand out, we change their highlight group.
		vim.api.nvim_set_hl(0, "CodeCompanionChatVariable", { link = "@tag.attribute" })
	end,
}
