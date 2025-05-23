return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {},
	cmd = "Trouble",
	keys = {
		{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics toggle" },
	},
	config = function(_, opts)
		require("trouble").setup(opts)
		vim.keymap.set("n", "<M-n>", "<Cmd>Trouble diagnostics next jump=true<CR>", { desc = "Diagnostics [n]ext" })
		vim.keymap.set("n", "<M-p>", "<Cmd>Trouble diagnostics prev jump=true<CR>", { desc = "Diagnostics [p]revious" })
	end,
}
