return {
	"mfussenegger/nvim-dap",
	config = function()
		local dap = require("dap")
		vim.keymap.set("n", "<F5>", dap.continue)
		vim.keymap.set("n", "<F10>", dap.step_over)
		vim.keymap.set("n", "<F11>", dap.step_into)
		vim.keymap.set("n", "<F12>", dap.step_out)
		vim.keymap.set("n", "<Leader>dbb", dap.toggle_breakpoint, { desc = "[d]ebug toggle [b]reakpoint" })
		vim.keymap.set("n", "<Leader>dbc", dap.clear_breakpoints, { desc = "[d]ebug [c]lear breakpoints" })
		vim.keymap.set("n", "<Leader>dc", dap.continue, { desc = "[d]ebug [c]ontinue" })
		vim.keymap.set("n", "<Leader>dl", dap.run_last, { desc = "[d]ebug run [l]ast" })
		vim.keymap.set("n", "<Leader>dt", dap.terminate, { desc = "[d]ebug [t]erminate" })
	end,
}
