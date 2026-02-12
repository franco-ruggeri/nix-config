return {
	"zbirenbaum/copilot.lua",
	event = "InsertEnter",
	cmd = "Copilot",
	opts = {
		suggestion = {
			auto_trigger = true,
		},
		filetypes = {
			-- Avoid errors in DAP REPL buffers.
			-- See https://github.com/rcarriga/nvim-dap-ui/issues/102
			["dap-repl"] = false,
		},
	},
}
