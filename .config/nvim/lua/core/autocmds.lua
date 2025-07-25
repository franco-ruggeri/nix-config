local M = {}

local function get_format_filter(buffer)
	local use_null_ls = false

	local lsp_clients = vim.lsp.get_clients({ bufnr = buffer })
	for _, lsp_client in pairs(lsp_clients) do
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

	-- We assume there can be only two language servers providing formatting: null-ls and another one.
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
		desc = "Set LSP keymaps and autocommands",
		callback = function(args)
			-- Multiple language servers might provide formatting.
			-- To avoid conflicts, we use a filter so that only one of them go through.
			local format_filter = get_format_filter(args.buf)
			local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

			-- Format on save
			if client:supports_method("textDocument/formatting") then
				vim.api.nvim_create_autocmd("BufWritePre", {
					group = vim.api.nvim_create_augroup("my-lsp-format", { clear = false }),
					buffer = args.buf,
					callback = function()
						vim.lsp.buf.format({ filter = format_filter })
					end,
				})
			end

			-- Fold using LSP
			vim.opt.foldmethod = "expr"
			vim.opt.foldexpr = "v:lua.vim.lsp.foldexpr()"

			-- Keymaps
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = args.buf, desc = "[g]oto [d]eclaration" })
		end,
	})

	vim.api.nvim_create_autocmd("FileType", {
		desc = "Set textwidth for markdown",
		pattern = "markdown",
		callback = function()
			vim.opt_local.textwidth = 80
		end,
	})

	vim.api.nvim_create_autocmd("FileType", {
		desc = "Set filetype to JSONC for devcontainer.json",
		pattern = "json",
		callback = function(args)
			local buffer = args.buf
			local buffer_name = vim.api.nvim_buf_get_name(buffer)
			local filename = vim.fs.basename(buffer_name)
			if filename == "devcontainer.json" then
				vim.bo[buffer].filetype = "jsonc"
			end
		end,
	})

	-- Both events are needed, as textwidth could be set at different times.
	vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
		desc = "Set colored columns based on textwidth",
		callback = function()
			local textwidth = vim.o.textwidth
			if textwidth > 0 then
				local colorcolumn = tostring(textwidth + 1)
				if vim.o.filetype == "gitcommit" then
					colorcolumn = colorcolumn .. ",51" -- for subject line
				end
				vim.o.colorcolumn = colorcolumn
			else
				vim.o.colorcolumn = "" -- reset to avoid showing those from other buffers (window-scoped)
			end
		end,
	})

	-- In git commits, highlight as errors subject lines longer than 50 characters
	vim.cmd.highlight("link gitcommitOverflow Error")
end

return M
