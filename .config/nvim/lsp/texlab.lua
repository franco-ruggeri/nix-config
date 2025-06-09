return {
	settings = {
		texlab = {
			build = {
				-- texlab supports compiling the project in two ways:
				-- * With a custom LSP method.
				-- * With the onSave option.
				--
				-- Neovim's built-in LSP client does not support the custom LSP method for building.
				-- So, we use the onSave option. The project is compiled on save.
				onSave = true,
			},
		},
	},
}
