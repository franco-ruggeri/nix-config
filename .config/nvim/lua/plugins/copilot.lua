local utils = require("utils")

return {
	"zbirenbaum/copilot.lua",
	enabled = utils.os.is_linux(),
	event = "InsertEnter",
	cmd = "Copilot",
	build = ":Copilot auth",
	opts = {
		suggestion = {
			auto_trigger = true,
		},
	},
}
