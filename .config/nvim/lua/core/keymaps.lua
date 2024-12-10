vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Disable arrow keys
vim.keymap.set("n", "<left>", "<cmd>echo 'Use h to move left!'<cr>")
vim.keymap.set("n", "<right>", "<cmd>echo 'Use l to move right!'<cr>")
vim.keymap.set("n", "<up>", "<cmd>echo 'Use k to move up!'<cr>")
vim.keymap.set("n", "<down>", "<cmd>echo 'Use j to move down!'<cr>")
