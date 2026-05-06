return {
	"stevearc/aerial.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	opts = {
		layout = {
			default_direction = "float",
			min_width = 0.5,
			win_opts = {
				number = true,
				relativenumber = true,
			},
		},
		float = {
			relative = "editor",
			min_height = 0.5,
		},
	},
	config = function(_, opts)
		require("aerial").setup(opts)

		vim.api.nvim_create_autocmd("FileType", {
			desc = "Set keymap to open outline",
			callback = function(args)
				-- The default behavior of gO depends on the filetype:
				-- * For help and man buffers, gO opens the outline in a location list. We want to keep that behavior.
				-- * For buffers with LSP clients attached, gO calls `vim.lsp.buf.document_symbol()`.
				--  As a result, the outline is opened in a location list. We want to change that to open Aerial.
				-- * For other filetypes, gO does nothing. We want to open Aerial anyway.
				--
				-- Aerial takes care of calling `vim.lsp.buf.document_symbol()`. So, it's enough to open it.
				vim.keymap.set("n", "gO", "<Cmd>AerialOpen<CR>", { buffer = args.buf, desc = "[g]oto [o]utline" })
			end,
		})
	end,
}
