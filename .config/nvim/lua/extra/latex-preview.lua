-- TODO: try how the error function works
-- TODO: check if server stays alive after nvim closes, it shouldn't...
local M = {}

local data_dir = vim.fn.stdpath("data") .. "/latex-preview"

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
	vim.fn.mkdir(data_dir, "p")

	-- Initialize npm
	if vim.fn.filereadable(data_dir .. "/package.json") == 0 then
		result = vim.system({ "npm", "init", "-y" }, { cwd = data_dir }):wait()
		if result.code ~= 0 then
			error("Failed to initialize npm: " .. result.stderr)
		end
	end

	-- Check if browser-sync is already installed
	result = vim.system({ "npm", "list", "browser-sync" }, { cwd = data_dir }):wait()
	if result.code == 0 then
		return
	end

	-- Install browser-sync
	print("Installing browser-sync...")
	result = vim.system({ "npm", "install", "browser-sync" }, { cwd = data_dir }):wait()
	if result.code ~= 0 then
		error("Failed to install browser-sync: " .. result.stderr)
	else
		print("Browser-sync installed successfully")
	end
end

M.start_preview = function()
	vim.fn.mkdir(M.opts.build_dir, "p")

	local html_file = M.opts.build_dir .. "/index.html"
	-- Create HTML page wrapping the PDF
	if vim.fn.filereadable(html_file) == 0 then
		local html_content = ([[
<!DOCTYPE html>
<html>
<head>
  <title>PDF Preview</title>
</head>
<body>
  <iframe src="%s"></iframe>
</body>
</html>
]]).format(M.opts.pdf_file)

		local file = io.open(html_file, "w")
		if not file then
			error("Could not open file for writing: " .. html_file)
		end

		file:write(html_content)
		file:close()
	end

	-- Run server
	latexmk_process = vim.system({
		"latexmk",
		"-pdf",
		"-pvc",
		"-view=none",
	})
	server_process = vim.system({
		"npx",
		"browser-sync",
		"start",
		M.opts.build_dir,
		"--files",
		M.opts.pdf_file,
		"--port",
		M.opts.port,
		"--reload-debounce",
		M.opts.reload_debouce,
		"--server",
		"--no-ui",
		"--no-open",
	}, {
		cwd = data_dir,
		stdout = function(err, data)
			if err then
				print("Error: " .. err)
			else
				print(data)
			end
		end,
	})
	print("Started preview server on http://localhost:5000")
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
	print("Stopped preview server")
end

M.setup = function(opts)
	M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

	install_browser_sync()

	vim.api.nvim_create_user_command("LatexPreviewStart", M.start_preview, {})
	vim.api.nvim_create_user_command("LatexPreviewStop", M.stop_preview, {})

	vim.keymap.set("n", "<leader>lp", M.start_preview, { desc = "[L]aTeX [p]review start" })
	vim.keymap.set("n", "<leader>lP", M.start_preview, { desc = "[L]aTeX [p]review stop" })
end

return M
