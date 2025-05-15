return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"sindrets/diffview.nvim", -- see modifications
		"nvim-telescope/telescope.nvim", -- for better menu UI
	},
	config = function()
		require("neogit").setup({})
		vim.keymap.set("n", "<leader>gs", "<cmd>Neogit<cr>", { desc = "[g]it [s]tatus" })
	end,
}
