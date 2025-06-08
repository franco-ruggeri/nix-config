return {
	"franco-ruggeri/pdf-preview.nvim",
	dev = true,
	keys = {
		{ "<leader>lp", "<Cmd>PdfPreviewStart<CR>", desc = "[l]atex [p]review start" },
	},
	opts = {
		pdf_filepath = "build/main.pdf",
		port = 5001,
	},
	config = function(_, opts)
		require("pdf-preview").setup(opts)
		vim.keymap.set("n", "<leader>lP", "<Cmd>PdfPreviewStop<CR>", { desc = "[l]atex [p]review stop" })
	end,
}
