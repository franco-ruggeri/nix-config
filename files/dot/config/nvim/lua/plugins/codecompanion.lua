-- If available, open the last chat, otherwise open a new chat
local function open_chat()
	local chat = require("codecompanion.interactions.chat").last_chat()
	if chat then
		chat.ui:open()
		vim.api.nvim_set_current_win(chat.ui.winnr)
	else
		vim.cmd("CodeCompanionChat")
	end
end

return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		{
			"nvim-lua/plenary.nvim", -- required
			version = false, -- latest commit, see https://codecompanion.olimorris.dev/installation.html
		},
		"nvim-treesitter/nvim-treesitter", -- required
		"MeanderingProgrammer/render-markdown.nvim", -- for rendering chat
		"zbirenbaum/copilot.lua", -- for copilot authentication
		"ravitemer/codecompanion-history.nvim", -- for chat history management
		{ "franco-ruggeri/codecompanion-spinner.nvim", version = false, dev = true }, -- for spinner
	},
	keys = {
		{
			"<Leader>aa",
			"<Cmd>CodeCompanionActions<CR>",
			mode = { "n", "x" },
			desc = "[A]I [a]ctions",
		},
		{ "<Leader>ac", open_chat, desc = "[A]I [c]hat" },
		{
			"<Leader>ac",
			"<Cmd>CodeCompanionChat Add<CR>",
			mode = "x",
			desc = "[A]I [c]hat add",
		},
		{
			"<Leader>ai",
			":CodeCompanion ",
			mode = { "n", "x" },
			desc = "[A]I [i]nline",
		},
		{
			"<Leader>an",
			":CodeCompanionCmd ",
			mode = { "n", "x" },
			desc = "[A]I CodeCompanion [N]eovim command",
		},
		{ "<Leader>ah", "<Cmd>CodeCompanionHistory<CR>", desc = "[A]I chat [h]istory" },
	},
	cmd = {
		"CodeCompanionActions",
		"CodeCompanionChat",
		"CodeCompanionCmd",
		"CodeCompanion",
		"CodeCompanionHistory",
	},
	opts = {
		interactions = {
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
			chat = {
				window = {
					layout = "tab",
				},
			},
			action_palette = {
				provider = "default", -- use vim.ui.select()
			},
		},
		extensions = {
			history = {
				opts = {
					expiration_days = 7,
					chat_filter = function(chat_data) -- only chats for the cwd
						return chat_data.cwd == vim.fn.getcwd()
					end,
					-- Use cheap models for generating summaries.
					-- ====================
					title_generation_opts = {
						adapter = "copilot",
						model = "gpt-4.1",
					},
					summary = {
						generation_opts = {
							adapter = "copilot",
							model = "gpt-4.1",
						},
					},
					-- ====================
				},
			},
			spinner = {
				-- opts = { log_level = "debug" },
			},
		},
	},
	config = function(_, opts)
		require("codecompanion").setup(opts)

		-- With rose-pine, chat variables would be highlighted as normal text.
		-- To make them stand out, we change their highlight group.
		vim.api.nvim_set_hl(0, "CodeCompanionChatVariable", { link = "@tag.attribute" })
	end,
}
