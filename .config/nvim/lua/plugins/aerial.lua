return {
	"stevearc/aerial.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	opts = {
		-- Since the window is managed by edgy.nvim, if `resize_to_content` is true:
		-- * The first time, the width gets resized to fit the content.
		-- * The second time (or after a zoom), the width gets adjusted by edgy.nvim.
		--
		-- Essentially, there would be inconsistency and an ugly flicker at the beginning.
		-- Setting it to false avoids that.
		resize_to_content = false,
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
				-- * For other filetypes, gO does nothing. We want to open Aerial anyway, as it's nice to have it open for layout reasons.
				--
				-- Aerial takes care of calling `vim.lsp.buf.document_symbol()`. So, it's enough to open it.
				if not vim.tbl_contains({ "help", "man" }, args.match) then
					vim.keymap.set("n", "gO", "<Cmd>AerialOpen<CR>", { buffer = args.buf, desc = "[g]oto [o]utline" })
				end
			end,
		})
	end,
}
