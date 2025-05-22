local utils = require("utils")

local M = {}

M.setup = function()
	vim.api.nvim_create_autocmd("TextYankPost", {
		desc = "Highlight when copying text",
		callback = function()
			vim.highlight.on_yank()
		end,
	})

	vim.api.nvim_create_autocmd("LspAttach", {
		desc = "Set keymaps and autocommands",
		callback = function(args)
			utils.lsp.set_keymaps(args.buf)
			utils.lsp.set_autocommands(args.buf)
		end,
	})
end

return M
