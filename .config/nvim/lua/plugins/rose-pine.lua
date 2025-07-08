return {
	"rose-pine/neovim",
	name = "rose-pine",
	config = function()
		require("rose-pine").setup({})
		vim.cmd.colorscheme("rose-pine")

		-- Update highlights from other plugins for better aesthetic
		vim.api.nvim_set_hl(0, "EdgyWinBar", { link = "Normal" })
		vim.api.nvim_set_hl(0, "EdgyNormal", { link = "Normal" })
		vim.api.nvim_set_hl(0, "TroubleNormal", { link = "Normal" })
		vim.api.nvim_set_hl(0, "TroubleNormalNC", { link = "NormalNC" })
		vim.api.nvim_set_hl(0, "CodeCompanionChatVariable", { link = "@tag.attribute" })
		vim.api.nvim_set_hl(0, "AvanteSidebarNormal", { link = "NormalNC" })
		vim.api.nvim_set_hl(0, "AvanteSidebarWinHorizontalSeparator", { link = "NormalNC" })
		vim.api.nvim_set_hl(0, "AvanteSidebarWinSeparator", { link = "WinSeparator" })
	end,
}
