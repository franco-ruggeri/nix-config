-- TODO: check if server stays alive after nvim closes, it shouldn't...
-- TODO: check how other plugins log
local M = {}

local data_path = vim.fn.stdpath("data") .. "/latex-preview"

M.opts = {
	build_dir = "build",
	pdf_file = "main.pdf",
	port = "5000",
	reload_debouce = "1000",
}

local latexmk_process = nil
local server_process = nil

local function install_browser_sync()
	local result = nil

	-- Ensure the data directory exists
	vim.fn.mkdir(data_path, "p")

	-- Initialize npm
	if vim.fn.filereadable(data_path .. "/package.json") == 0 then
		result = vim.system({ "npm", "init", "-y" }, { cwd = data_path }):wait()
		if result.code ~= 0 then
			error("Failed to initialize npm: " .. result.stderr)
		end
	end

	-- Check if browser-sync is already installed
	result = vim.system({ "npm", "list", "browser-sync" }, { cwd = data_path }):wait()
	if result.code == 0 then
		return
	end

	-- Install browser-sync
	print("Installing browser-sync...")
	result = vim.system({ "npm", "install", "browser-sync" }, { cwd = data_path }):wait()
	if result.code ~= 0 then
		error("Failed to install browser-sync: " .. result.stderr)
	else
		print("Browser-sync installed successfully")
	end
end

M.start_preview = function()
	-- Start latexmk in continuous mode
	latexmk_process = vim.system({
		"latexmk",
		"-pdf",
		"-pvc",
		"-view=none",
	})

	-- Get path to serve
	local lsp_clients = vim.lsp.get_clients({ name = "texlab" })
	if #lsp_clients == 0 then
		error("No texlab LSP client found.")
	end
	local server_path = lsp_clients[1].config.root_dir .. "/" .. M.opts.build_dir

	-- Start browser-sync server
	vim.fn.mkdir(server_path, "p")
	server_process = vim.system({
		"npx",
		"browser-sync",
		"start",
		"--server",
		server_path,
		"--files",
		M.opts.pdf_file,
		"--port",
		M.opts.port,
		"--reload-debounce",
		M.opts.reload_debouce,
		"--watch",
		"--no-ui",
		"--no-open",
	}, {
		cwd = data_path,
		stdout = function(err, data)
			-- TODO: remove this once it works
			if err then
				print("Error: " .. err)
			else
				print(data)
			end
		end,
	})
	print("Started LaTeX preview on http://localhost:" .. M.opts.port)

	-- Create HTML page wrapping the PDF
	local html_file = M.opts.build_dir .. "/index.html"
	if vim.fn.filereadable(html_file) == 0 then
		local html_content = string.format(
			[[
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>PDF Preview</title>
  <style>
    html, body { margin: 0; height: 100%%; overflow: hidden; }
    iframe { width: 100%%; height: 100%%; border: none; }
  </style>
</head>
<body>
  <iframe src="%s"></iframe>
</body>
</html>
]],
			M.opts.pdf_file
		)

		local file = io.open(html_file, "w")
		if not file then
			error("Could not open file for writing: " .. html_file)
		end
		file:write(html_content)
		file:close()
	end
end

M.stop_preview = function()
	if latexmk_process then
		latexmk_process:kill()
		latexmk_process = nil
	else
	end
	if server_process then
		server_process:kill()
		server_process = nil
	end
	print("Stopped LaTeX preview")
end

M.setup = function(opts)
	M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

	install_browser_sync()

	vim.api.nvim_create_user_command("LatexPreviewStart", M.start_preview, {})
	vim.api.nvim_create_user_command("LatexPreviewStop", M.stop_preview, {})

	vim.keymap.set("n", "<leader>lp", "<Cmd>LatexPreviewStart<CR>", { desc = "[L]aTeX [p]review start" })
	vim.keymap.set("n", "<leader>lP", "<Cmd>LatexPreviewStop<CR>", { desc = "[L]aTeX [p]review stop" })
end

return M
