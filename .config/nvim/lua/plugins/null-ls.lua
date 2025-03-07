local function format(buf)
	local filetype = vim.bo[buf].filetype
	local generators = require("null-ls.generators")
	local methods = require("null-ls.methods")
	local has_formatter = #generators.get_available(filetype, methods.internal.FORMATTING) > 0

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
			callback = function(event)
				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = event.buf,
					callback = function()
						format(event.buf)
					end,
				})
			end,
		})
	end,
}
