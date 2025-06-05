local M = {}

M.setup = function()
	vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
	vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
	vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
	vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
	vim.keymap.set("n", "<leader>xr", vim.diagnostic.reset, { desc = "Diagnostics [r]eset" })

	-- Disable arrow keys
	vim.keymap.set("n", "<left>", "<Cmd>echo 'Use h to move left!'<CR>")
	vim.keymap.set("n", "<right>", "<Cmd>echo 'Use l to move right!'<CR>")
	vim.keymap.set("n", "<up>", "<Cmd>echo 'Use k to move up!'<CR>")
	vim.keymap.set("n", "<down>", "<Cmd>echo 'Use j to move down!'<CR>")
end

return M
