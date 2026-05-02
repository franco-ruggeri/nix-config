local M = {}

M.setup = function()
	vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
	vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

	vim.keymap.set("n", "<Leader>xr", vim.diagnostic.reset, { desc = "diagnostics [r]eset" })
	vim.keymap.set("n", "<Leader>xv", function()
		local virtual_text = vim.diagnostic.config().virtual_text
		vim.diagnostic.config({ virtual_text = not virtual_text })
	end, { desc = "diagnostics [v]irtual text toggle" })

	vim.keymap.set("n", "<Leader>q", "<Cmd>copen<CR>", { desc = "[q]uickfix" })
	vim.keymap.set("x", "<Leader>p", '"_dP', { desc = "[p]aste without copying" })

	vim.keymap.set("n", "K", function()
		vim.lsp.buf.hover({ border = "rounded" })
	end, { desc = "Hover documentation" })

	-- Disable arrow keys
	vim.keymap.set("n", "<left>", "<Cmd>echo 'Use h to move left!'<CR>")
	vim.keymap.set("n", "<right>", "<Cmd>echo 'Use l to move right!'<CR>")
	vim.keymap.set("n", "<up>", "<Cmd>echo 'Use k to move up!'<CR>")
	vim.keymap.set("n", "<down>", "<Cmd>echo 'Use j to move down!'<CR>")
end

return M
