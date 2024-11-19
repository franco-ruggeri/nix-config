return {
  'stevearc/conform.nvim',
  -- Lazy loading on buffer writing
	event = { "BufWritePre" },
  opts = {
		formatters_by_ft = {
			lua = { "stylua" },
      python = { "black" },
		},
		format_on_save = {
      -- Fallback to LSP
      lsp_format = "fallback",
    },
  },
}
