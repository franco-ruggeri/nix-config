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

	vim.api.nvim_create_autocmd("DiagnosticChanged", {
		desc = "Update diagnostics quickfix list",
		callback = function()
			utils.diagnostics.refresh()
		end,
	})

	vim.api.nvim_create_autocmd("BufWinEnter", {
		desc = "Set position of quickfix and location lists",
		callback = function()
			local window_id = vim.api.nvim_get_current_win()
			local window_info = vim.fn.getwininfo(window_id)[1]

			if window_info.quickfix == 1 then
				if window_info.loclist == 1 then
					vim.cmd("wincmd L") -- location list --> right
				else
					vim.cmd("wincmd J") -- quickfix list --> bottom
				end
			end
		end,
	})

	vim.api.nvim_create_autocmd("BufWinEnter", {
		desc = "Close quickfix and location list on selection",
		callback = function()
			local window_id = vim.api.nvim_get_current_win()
			local window_info = vim.fn.getwininfo(window_id)[1]
			local quickfix_title = vim.fn.getqflist({ title = 1 }).title

			if window_info.quickfix == 1 then
				local should_close = false
				local close_cmd = nil

				if window_info.loclist == 0 then
					should_close = quickfix_title ~= utils.diagnostics.quickfix_title
					close_cmd = "cclose"
				else
					should_close = true
					close_cmd = "lclose"
				end

				if should_close then
					vim.keymap.set("n", "<CR>", ("<CR><Cmd>%s<CR>"):format(close_cmd), { buffer = true })
				end
			end
		end,
	})
end

return M
