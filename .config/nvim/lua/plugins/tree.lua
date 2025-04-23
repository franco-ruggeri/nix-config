return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("nvim-tree").setup({})
		vim.keymap.set("n", "<leader>et", "<cmd>NvimTreeToggle<cr>", { desc = "[e]xplore [t]oggle tree" })
		vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeFindFile<cr>", { desc = "[e]xplore find [b]uffer in tree" })
	end,
}
