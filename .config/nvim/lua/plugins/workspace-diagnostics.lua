return {
	"artemave/workspace-diagnostics.nvim",
	opts = {},
	config = function()
		vim.api.nvim_create_autocmd("LspAttach", {
			desc = "Configure workspace diagnostics",
			callback = function(args)
				if not args.data then
					return
				end

				local client = vim.lsp.get_client_by_id(args.data.client_id)
				local buffer = args.buf

				-- Enable workspace diagnostics
				local workspace_diagnostics = require("workspace-diagnostics")
				workspace_diagnostics.populate_workspace_diagnostics(client, buffer)
			end,
		})
	end,
}
