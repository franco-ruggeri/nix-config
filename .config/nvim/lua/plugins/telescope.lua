return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    -- Required dependency
    "nvim-lua/plenary.nvim",
    -- Icons
    "nvim-tree/nvim-web-devicons",
    -- Improve sorting performance
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
    },
  },
  config = function()
    require("telescope").setup({})

    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[f]ind - [f]ile" })
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[f]ind - [g]rep" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[f]ind - [b]uffer" })
  end,
}
