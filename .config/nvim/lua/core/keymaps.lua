local utils = require("utils")

local M = {}

	vim.keymap.set("n", "<leader>q", utils.diagnostics.toggle, { desc = "[q]uickfix diagnostics" })
M.setup = function()
	vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })
	vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
	vim.keymap.set("n", "<M-n>", "<cmd>cnext<cr>", { desc = "Quickfix list next" })
	vim.keymap.set("n", "<M-p>", "<cmd>cprevious<cr>", { desc = "Quickfix list previous" })
	vim.keymap.set("n", "<leader>e", "<cmd>Explore<cr>", { desc = "[e]xplore with netrw" })

	-- Disable arrow keys
	vim.keymap.set("n", "<left>", "<cmd>echo 'Use h to move left!'<cr>")
	vim.keymap.set("n", "<right>", "<cmd>echo 'Use l to move right!'<cr>")
	vim.keymap.set("n", "<up>", "<cmd>echo 'Use k to move up!'<cr>")
	vim.keymap.set("n", "<down>", "<cmd>echo 'Use j to move down!'<cr>")
end

return M
