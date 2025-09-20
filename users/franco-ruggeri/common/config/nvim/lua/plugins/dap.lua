return {
	"mfussenegger/nvim-dap",
	config = function()
		local dap = require("dap")
		vim.keymap.set("n", "<F5>", dap.continue)
		vim.keymap.set("n", "<F10>", dap.step_over)
		vim.keymap.set("n", "<F11>", dap.step_into)
		vim.keymap.set("n", "<F12>", dap.step_out)
		vim.keymap.set("n", "<Leader>db", dap.toggle_breakpoint, { desc = "[d]ebug [b]reakpoint toggle" })
		vim.keymap.set("n", "<Leader>dB", dap.clear_breakpoints, { desc = "[d]ebug [b]reakpoint clear" })
		vim.keymap.set("n", "<Leader>dr", dap.continue, { desc = "[d]ebug [r]un continue" })
		vim.keymap.set("n", "<Leader>dR", dap.run_last, { desc = "[d]ebug [r]un last" })
	end,
}
