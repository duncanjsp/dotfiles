-- which-key: shows a popup of available keybindings as you type a prefix.
-- Press <leader> (Space) and pause -- a menu lists what you can do next,
-- using the `desc` from every mapping we've defined. Also powers a curated
-- cheat sheet on <leader>? for the keys you can never remember.
--
-- Repo: https://github.com/folke/which-key.nvim

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

    -- Group labels + curated documentation. A `group` names a prefix (so
    -- <leader>f shows as "+find"); entries with only a `desc` document existing
    -- keys -- including non-leader built-ins you forget -- so they appear in
    -- the <leader>? cheat sheet.
    wk.add({
      { "<leader>f", group = "find" },

      -- Windows / splits
      { "<C-w>o", desc = "Close other windows" },
      { "<C-w>=", desc = "Equalize split sizes" },
      { "<C-w>v", desc = "Split window vertically" },
      { "<C-w>s", desc = "Split window horizontally" },

      -- Folding (Treesitter)
      { "za", desc = "Toggle fold" },
      { "zR", desc = "Open all folds" },
      { "zM", desc = "Close all folds" },
    })
  end,
}
