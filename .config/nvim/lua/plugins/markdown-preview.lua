return {
	"iamcco/markdown-preview.nvim",
	build = ":call mkdp#util#install()",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	ft = { "markdown" }, -- TODO: need to understnad why without this it doesn't work
	keys = {
		{ "<leader>mp", "<Cmd>MarkdownPreviewToggle<CR>", desc = "[m]arkdown [p]review toggle" },
	},
	init = function()
		vim.g.mkdp_echo_preview_url = 1
	end,
}
