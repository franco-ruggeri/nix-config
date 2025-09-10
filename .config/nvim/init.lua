require("core").setup()

-- Load local configuration if present
local path = vim.fn.getcwd() .. "/.nvim/nvim.lua"
if vim.secure.read(path) then
	dofile(path)
end
