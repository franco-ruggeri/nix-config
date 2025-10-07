require("core").setup()

-- Load local config from project overlay
-- See https://github.com/franco-ruggeri/project-overlays
local path = vim.fn.getcwd() .. "/.personal/nvim.lua"
if vim.secure.read(path) then
	dofile(path)
end
