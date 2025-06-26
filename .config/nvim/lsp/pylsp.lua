return {
	settings = {
		pylsp = {
			plugins = {
				autopep8 = { enabled = false }, -- formatting via null-ls
				pycodestyle = { enabled = false },  -- linting via null-ls
			},
		},
	},
}
