return {
	"mbbill/undotree",
	config = function()
		vim.keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<cr>", { desc = "[u]ndotree" })
	end,
}
