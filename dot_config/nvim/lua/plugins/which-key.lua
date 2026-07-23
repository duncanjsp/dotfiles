-- https://github.com/folke/which-key.nvim
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = true })
      end,
      desc = "Cheat sheet (all keymaps)",
    },
  },
  config = function()
    local wk = require("which-key")
    wk.setup({
      preset = "modern",
      delay = 200,
    })

    -- Group labels + docs for built-ins so they show in the cheat sheet.
    wk.add({
      { "<leader>f", group = "find" },
      { "<C-w>o", desc = "Close other windows" },
      { "<C-w>=", desc = "Equalize split sizes" },
      { "<C-w>v", desc = "Split window vertically" },
      { "<C-w>s", desc = "Split window horizontally" },
      { "za", desc = "Toggle fold" },
      { "zR", desc = "Open all folds" },
      { "zM", desc = "Close all folds" },
    })
  end,
}
