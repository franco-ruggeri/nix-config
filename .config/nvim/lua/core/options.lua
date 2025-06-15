local M = {}

M.setup = function()
	-- Share unnamed register ("_ register) with clipboard ("* and "+ registers).
	-- This enables copy/paste between neovim and other applications.
	-- Schedule it after `UiEnter` because it can increase startup time.
	vim.schedule(function()
		vim.opt.clipboard = "unnamedplus"
	end)

	-- Use tmux clipboard, as it works both locally and over SSH connections
	vim.g.clipboard = "tmux"

	-- Show relative line numbers
	vim.opt.number = true
	vim.opt.relativenumber = true

	-- Save undo history (kept if you close and re-open a file)
	vim.opt.undofile = true

	-- Case-insensitive search unless the pattern contains capital letters
	vim.opt.ignorecase = true
	vim.opt.smartcase = true

	-- Keep minimum number of lines above and below the cursor line
	vim.opt.scrolloff = 10

	-- Keep signcolumn on by default
	vim.opt.signcolumn = "yes"

	-- Set indentation
	vim.opt.tabstop = 2
	vim.opt.softtabstop = 2
	vim.opt.shiftwidth = 2
	vim.opt.expandtab = true
	vim.opt.smartindent = true

	-- Indent wrapped lines (long lines that don't fit the screen)
	vim.opt.breakindent = true

	-- Set default split behavior to right/below
	vim.opt.splitright = true
	vim.opt.splitbelow = true

	-- Enable local config
	vim.opt.exrc = true

	-- Open buffers without folding
	vim.opt.foldenable = false
end

return M
