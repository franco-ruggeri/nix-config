local M = {}

local function get_format_filter(buffer)
	local use_null_ls = false
	local lsp_clients = vim.lsp.get_clients({ bufnr = buffer })

	for i = 1, #lsp_clients do
		local lsp_client = lsp_clients[i]

		if lsp_client.name == "null-ls" then
			local null_ls = require("null-ls")
			local sources = null_ls.get_source({
				filetype = vim.bo[buffer].filetype,
				method = null_ls.methods.FORMATTING,
			})

			if #sources > 0 then
				use_null_ls = true
			end
			break
		end
	end

	-- We assume there can be only two LSP servers providing formatting: null-ls and another one.
	-- If there is a null-ls formatter, we use only that to solve conflicts.
	if use_null_ls then
		return function(client)
			return client.name == "null-ls"
		end
	else
		return function()
			return true
		end
	end
end

M.setup = function()
	vim.api.nvim_create_autocmd("TextYankPost", {
		desc = "Highlight when copying text",
		callback = function()
			vim.highlight.on_yank()
		end,
	})

	vim.api.nvim_create_autocmd("LspAttach", {
		desc = "Set keymaps and autocommands",
		callback = function(args)
			local function map(mode, key, action, desc)
				vim.keymap.set(mode, key, action, { buffer = args.buf, desc = desc })
			end
			map("n", "gD", vim.lsp.buf.declaration, "[g]oto [d]eclaration")

			-- Format on save
			-- Multiple LSP servers might provide formatting.
			-- To avoid conflicts, we use a filter so that only one of them go through.
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = vim.api.nvim_create_augroup("my-lsp-format", { clear = false }),
				buffer = args.buf,
				callback = function()
					vim.lsp.buf.format({ filter = get_format_filter(args.buf) })
				end,
			})
		end,
	})
end

return M
