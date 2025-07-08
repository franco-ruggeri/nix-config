return {
	"kosayoda/nvim-lightbulb",
	version = false,
	opts = {
		autocmd = {
			enabled = true,
			update_time = -1, -- no update time
		},
		priority = 1000, -- show sign above diagnostic ones
		-- Some tools always provide code actions of kind source (e.g., ruff).
		-- Thus, we exclude the source kinds to avoid always showing the lightbulb.
		action_kinds = { "quickfix", "refactor" },
	},
}
