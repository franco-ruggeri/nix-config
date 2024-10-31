vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when copying text",
	callback = function()
		vim.highlight.on_yank()
	end,
})
