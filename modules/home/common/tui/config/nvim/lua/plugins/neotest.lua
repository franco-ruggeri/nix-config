local function open_and_focus()
	vim.cmd("Neotest summary open")

	-- Focus the summary window for consistency with other UI panels
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local ft = vim.bo[buf].filetype
		if ft == "neotest-summary" then
			vim.api.nvim_set_current_win(win)
			break
		end
	end
end

return {
	"nvim-neotest/neotest",
	dependencies = {
		-- Required
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		-- Adapters
		"nvim-neotest/neotest-python", -- pytest and unittest
		-- Integrations
		"stevearc/overseer.nvim", -- for running tests in overseer
	},
	keys = {
		{ "<Leader>T", open_and_focus, desc = "[t]est list" },
	},
	config = function()
		---@diagnostic disable-next-line: missing-fields
		require("neotest").setup({
			consumers = {
				---@diagnostic disable-next-line: assign-type-mismatch
				overseer = require("neotest.consumers.overseer"),
			},
			adapters = {
				require("neotest-python"),
			},
		})
	end,
}
