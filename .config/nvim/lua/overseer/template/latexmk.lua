return {
	name = "latexmk",
	builder = function()
		return {
			cmd = "latexmk",
			args = {
				"-pdf",
				"-interaction=nonstopmode",
				"-synctex=1",
				"-outdir=output",
			},
			components = {
				{ "on_output_quickfix", open = true },
				{ "default" },
			},
		}
	end,
	condition = {
		callback = function()
			return #vim.lsp.get_clients({ name = "texlab" }) > 0
		end,
	},
}
