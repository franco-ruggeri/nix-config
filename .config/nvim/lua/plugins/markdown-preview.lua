return {
	"iamcco/markdown-preview.nvim",
	build = ":call mkdp#util#install()",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	keys = {
		{ "<leader>mp", "<Cmd>MarkdownPreviewToggle<CR>", desc = "[m]arkdown [p]review toggle" },
	},
}
