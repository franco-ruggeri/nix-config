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

function M.on_attach(client, buffer)
	-- Enable workspace diagnostics
	local workspace_diagnostics = require("workspace-diagnostics")
	workspace_diagnostics.populate_workspace_diagnostics(client, buffer)

	-- Keymaps for main LSP methods
	local function map(mode, key, action, desc)
		vim.keymap.set(mode, key, action, { buffer = buffer, desc = desc or "" })
	end
	local telescope = require("telescope.builtin")
	map("n", "gd", telescope.lsp_definitions, "[g]oto [d]efinition")
	map("n", "gD", vim.lsp.buf.declaration, "[g]oto [d]eclaration")
	map("n", "<leader>lr", vim.lsp.buf.rename, "[L]SP [r]ename")
	map("n", "<leader>lc", vim.lsp.buf.code_action, "[L]SP [c]ode action")

	-- Format on save
	-- Multiple LSP servers might provide formatting.
	-- To avoid conflicts, we use a filter so that only one of them go through.
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = vim.api.nvim_create_augroup("my-lsp-format", { clear = false }),
		buffer = buffer,
		callback = function()
			vim.lsp.buf.format({ async = false, filter = get_format_filter(buffer) })
		end,
	})
end

return M
