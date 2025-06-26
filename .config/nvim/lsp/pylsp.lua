return {
	settings = {
		pylsp = {
			-- For Python, standard formatters and linters are available with null-ls.
			-- So, disable diagnostics and formatting plugins to avoid conflicts with them.
			plugins = {
				pyflakes = { enabled = false },
				autopep8 = { enabled = false },
				mccabe = { enabled = false },
				pycodestyle = { enabled = false },
				yapf = { enabled = false },
			},
		},
	},
}
