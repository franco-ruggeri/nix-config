return {
	"danymat/neogen",
	opts = {
		snippet_engine = "nvim", -- use built-in snippet engine (:h vim.snippet)
	},
	config = function(_, opts)
		require("neogen").setup(opts)
		vim.keymap.set("n", "<leader>ga", "<Cmd>Neogen<CR>", { desc = "[g]enerate [a]nnotation" })
	end,
}
