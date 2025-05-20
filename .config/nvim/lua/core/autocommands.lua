local utils = require("utils")

local M = {}

function M.setup()
	vim.api.nvim_create_autocmd("TextYankPost", {
		desc = "Highlight when copying text",
		callback = function()
			vim.highlight.on_yank()
		end,
	})

	vim.api.nvim_create_autocmd("DiagnosticChanged", {
		desc = "Update quickfix list when diagnostics change",
		callback = function()
			utils.diagnostics.refresh()
		end,
	})
end

return M
