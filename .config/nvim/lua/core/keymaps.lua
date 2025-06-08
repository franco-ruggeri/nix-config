local M = {}

local virtual_text = false

M.setup = function()
	vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
	vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
	vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
	vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })

	vim.keymap.set("n", "<leader>xr", vim.diagnostic.reset, { desc = "Diagnostics [r]eset" })
	vim.keymap.set("n", "<leader>xv", function()
		virtual_text = not virtual_text
		vim.diagnostic.config({ virtual_text = virtual_text })
	end, { desc = "Diagnostics [v]irtual text toggle" })

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
