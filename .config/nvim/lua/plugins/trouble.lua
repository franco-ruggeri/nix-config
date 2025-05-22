return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  keys = {
    { "<leader>ldd", "<cmd>Trouble diagnostics toggle<cr>", desc = "[L]SP [d]iagnostics toggle" },
  },
  config = function()
    require("trouble").setup()
    vim.keymap.set(
      "n",
      "<M-n>",
      "<cmd>Trouble diagnostics next<cr><cmd>Trouble diagnostics jump<cr>",
      { desc = "Quickfix list next" }
    )
    vim.keymap.set(
      "n",
      "<M-p>",
      "<cmd>Trouble diagnostics prev<cr><cmd>Trouble diagnostics jump<cr>",
      { desc = "Quickfix list previous" }
    )
  end,
}
