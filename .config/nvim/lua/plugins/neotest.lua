local function open_and_focus()
	vim.cmd("Neotest summary open")

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
		"nvim-neotest/neotest-python",
	},
	keys = {
		{ "<leader>te", open_and_focus, desc = "[te]st list" },
	},
	config = function()
		---@diagnostic disable-next-line: missing-fields
		require("neotest").setup({
			adapters = {
				require("neotest-python"),
			},
		})
	end,
}
