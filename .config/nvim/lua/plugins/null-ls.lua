local function format(buf)
	local null_ls = require("null-ls")
	local sources = null_ls.get_source({
		filetype = vim.bo[buf].filetype,
		method = null_ls.methods.FORMATTING,
	})
	local has_formatter = #sources > 0

	local filter
	if has_formatter then -- null-ls provides a formatter, use only that
		filter = function(client)
			return client.name == "null-ls"
		end
	else -- otherwise, allow the LSP server's one
		filter = function(_)
			return true
		end
	end

	vim.lsp.buf.format({
		async = false,
		filter = filter,
	})
end

return {
	"nvimtools/none-ls.nvim", -- maintained fork of null-ls
	config = function()
		require("null-ls").setup()

		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if not client then
					error("client not found")
				elseif client.name ~= "null-ls" then
					return
				end

				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = args.buf,
					callback = function()
						format(args.buf)
					end,
				})
			end,
		})
	end,
}
