require("core").setup()

-- Load local config from .personal/.nvim.lua (project overlay)
local path = vim.fn.getcwd() .. "/.personal/.nvim.lua"
if vim.secure.read(path) then
	dofile(path)
end
