return {
	"franco-ruggeri/pdf-preview.nvim",
	dev = true,
  cmd = { "PdfPreviewStart", "PdfPreviewToggle" },
	keys = {
		{ "<leader>p", "<Cmd>PdfPreviewToggle<CR>", desc = "[P]DF preview toggle" },
	},
  opts = {},
}
