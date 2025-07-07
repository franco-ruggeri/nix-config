return {
	"kosayoda/nvim-lightbulb",
	version = false,
	opts = {
		autocmd = { enabled = true },
		-- Code actions are often available for lines with a diagnostic.
		-- However, in those lines, the sign should show the diagnostic type.
		-- We do not want to override that (and we would need to increase the priority.
		-- Thus, we show the lightbulb with virtual text.
		sign = { enabled = false },
		virtual_text = { enabled = true },
		-- Some tools always provide code actions of kind source (e.g., ruff).
		-- Thus, we exclude the source kinds to avoid always showing the lightbulb.
		action_kinds = { "quickfix", "refactor" },
	},
}
