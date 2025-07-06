-- Adapted from https://github.com/olimorris/codecompanion.nvim/discussions/640#discussioncomment-12866279
-- TODO: consider wrapping it into a plugin
-- ====================
local spinners = {}

local Spinner = {}

function Spinner:new(buffer)
	local object = {
		buffer = buffer,
		namespace_id = vim.api.nvim_create_namespace("CodeCompanionSpinner"),
		processing = false,
		spinner_index = 1,
		timer = nil,
		filetype = "codecompanion",
		spinner_symbols = {
			"⠋",
			"⠙",
			"⠹",
			"⠸",
			"⠼",
			"⠴",
			"⠦",
			"⠧",
			"⠇",
			"⠏",
		},
	}
	self.__index = self
	setmetatable(object, self)

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionRequest*",
		callback = function(request)
			if request.buf == self.buffer then
				if request.match == "CodeCompanionRequestStarted" then
					self:start()
				elseif request.match == "CodeCompanionRequestFinished" then
					self:stop()
				end
			end
		end,
	})

	return object
end

function Spinner:update()
	if not self.processing then
		self:stop()
		return
	end

	vim.api.nvim_buf_clear_namespace(self.buffer, self.namespace_id, 0, -1)
	self.spinner_index = (self.spinner_index % #self.spinner_symbols) + 1
	local last_line = vim.api.nvim_buf_line_count(self.buffer) - 1
	vim.api.nvim_buf_set_extmark(self.buffer, self.namespace_id, last_line, 0, {
		virt_lines = { { { self.spinner_symbols[self.spinner_index] .. " Processing...", "Comment" } } },
		virt_lines_above = true, -- false means below the line
	})
end

function Spinner:start()
	print("started")

	self.processing = true
	self.spinner_index = 0

	if self.timer then
		self.timer:stop()
		self.timer:close()
		self.timer = nil
	end

	self.timer = vim.uv.new_timer()
	self.timer:start(
		0,
		100,
		vim.schedule_wrap(function()
			self:update()
		end)
	)
end

function Spinner:stop()
	print("stopped")
	self.processing = false

	if self.timer then
		self.timer:stop()
		self.timer:close()
		self.timer = nil
	end

	vim.api.nvim_buf_clear_namespace(self.buffer, self.namespace_id, 0, -1)
end
-- ====================

return {
	"olimorris/codecompanion.nvim",
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

		vim.api.nvim_create_autocmd("FileType", {
			desc = "Create CodeCompanion spinner",
			pattern = "codecompanion",
			callback = function(args)
				print("create spinner for ", args.buf)
				spinners[args.buf] = Spinner:new(args.buf)
			end,
		})

		-- TODO: doesnt work... bufdelete gets called when I type #{buffer}
		vim.api.nvim_create_autocmd("BufDelete", {
			desc = "Clear CodeCompanion spinner",
			callback = function(args)
				print("buf delete ", args.buf)
				if spinners[args.buf] then
					print(vim.inspect(spinners[args.buf]))
					spinners[args.buf]:stop()
					spinners[args.buf] = nil
				end
			end,
		})
	end,
}
