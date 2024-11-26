return {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	dependencies = {
    "neovim/nvim-lspconfig",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/cmp-buffer",
	},
	config = function()
		local cmp = require("cmp")

    -- Completion in text
    cmp.setup({
      mapping = cmp.mapping.preset.insert({
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-y>"] = cmp.mapping.confirm { select = true },
        ["<C-Space>"] = cmp.mapping.complete {},
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "cmdline" },
      }, {
          { name = "buffer" },
        }
      )
    })

    -- Completion in search mode
    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'buffer' }
      }
    })

    -- Completion in command-line mode
    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = 'path' }
      }, {
          { name = 'cmdline' }
        }),
    })
  end,
}
