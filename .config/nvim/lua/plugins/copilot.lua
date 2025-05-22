return {
	"zbirenbaum/copilot.lua",
	enabled = true,
	event = "InsertEnter",
	cmd = "Copilot",
	build = ":Copilot auth",
	opts = {
		suggestion = {
			auto_trigger = true,
		},
	},
}
