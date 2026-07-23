-- Neo-tree: a file/project explorer sidebar.
--
-- Toggle it with <leader>e (Space e). Use it to browse a directory tree and
-- jump between files. Inside the tree, press `?` to see Neo-tree's own key
-- mappings (open, split, rename, delete, create, refresh, etc.).
--
-- Repo: https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",

  -- lazy.nvim installs these automatically:
  dependencies = {
    "nvim-lua/plenary.nvim", -- common Lua utility functions (used by many plugins)
    "nvim-tree/nvim-web-devicons", -- filetype icons (needs the Nerd Font -- you have it)
    "MunifTanjim/nui.nvim", -- UI component library Neo-tree is built on
  },

  -- Load Neo-tree lazily -- only when you first use it, either via the key or
  -- the :Neotree command. Keeps startup fast.
  cmd = "Neotree",
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file explorer" },
  },

  -- These options are passed to require("neo-tree").setup(...).
  opts = {
    -- Close Neo-tree automatically if it's the last window left.
    close_if_last_window = true,

    filesystem = {
      -- Keep the tree focused on the file you're editing.
      follow_current_file = { enabled = true },
      -- React to files changing on disk (created/deleted/renamed elsewhere).
      use_libuv_file_watcher = true,

      filtered_items = {
        visible = true, -- still show filtered items, just dimmed...
        hide_dotfiles = false, -- ...and don't hide dotfiles (you edit these!)
        hide_gitignored = false, -- ...or git-ignored files
      },
    },

    window = {
      width = 32,
    },
  },
}
