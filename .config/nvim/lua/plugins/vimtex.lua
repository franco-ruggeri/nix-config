return {
	"lervag/vimtex",
	ft = "tex",
	init = function()
		vim.g.vimtex_view_method = "zathura"
	end,
	config = function()
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "tex",
			callback = function(args)
				vim.keymap.set("n", "gO", "<Cmd>VimtexTocOpen<CR>", {
					desc = "[g]oto [o]utline (document symbols)",
					buffer = args.buf,
				})
			end,
		})
	end,
}
