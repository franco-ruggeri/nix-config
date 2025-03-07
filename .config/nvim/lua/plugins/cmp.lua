return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "neovim/nvim-lspconfig",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/cmp-buffer",
  },
  config = function()
    local cmp = require("cmp")

    -- Global settings
    cmp.setup({
      mapping = cmp.mapping.preset.insert(),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "path" },
      }, {
        { name = "buffer" },
      }),
    })

    -- Settings in search mode
    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })

    -- Settings in command-line mode
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "path" },
      }, {
        { name = "cmdline" },
      }),
    })
  end,
}
