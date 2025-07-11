return {
	"danymat/neogen",
	keys = {
		{ "<Leader>ga", "<Cmd>Neogen<CR>", desc = "[g]enerate [a]nnotation" },
	},
	opts = {
		snippet_engine = "nvim", -- use built-in snippet engine (:h vim.snippet)
	},
}
