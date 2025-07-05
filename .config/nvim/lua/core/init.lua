local M = {}

M.options = require("core.options")
M.keymaps = require("core.keymaps")
M.autocmds = require("core.autocmds")
M.plugins = require("core.plugins")

M.setup = function()
	M.options.setup()
	M.keymaps.setup()
	M.autocmds.setup()
	M.plugins.setup()
end

return M
