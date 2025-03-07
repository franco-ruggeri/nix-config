return {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    "zbirenbaum/copilot.lua",
    { "nvim-lua/plenary.nvim", branch = "master" }, -- required dependency
  },
  build = "make tiktoken",
  opts = {},
  keys = { -- lazy load on first toggle + define keymap
    { "<leader>ac", "<cmd>CopilotChatToggle<cr>", desc = "[A]I copilot [c]hat" },
  },
}
