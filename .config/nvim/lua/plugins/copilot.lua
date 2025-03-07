return {
	"zbirenbaum/copilot.lua",
	event = "InsertEnter",
	cmd = "Copilot",
	build = ":Copilot auth",
	opts = {
		suggestion = {
			auto_trigger = true,
		},
	},
	config = function(_, opts)
		require("copilot").setup(opts)
		vim.keymap.set("n", "<leader>ap", "<cmd>Copilot panel<cr>", { desc = "[A]I copilot [p]anel" })
	end,
}
