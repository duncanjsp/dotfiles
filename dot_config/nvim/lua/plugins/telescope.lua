-- Telescope: a fuzzy finder with a popover UI.
--
-- Jump to any file, search text across the project, list open buffers, search
-- the help docs -- all through a searchable popup. Uses `fd` (file listing)
-- and `ripgrep` (text search) under the hood.
--
-- Default keys (all under <leader>f -- "find"):
--   <leader>ff  find files      <leader>fg  live grep (search text in files)
--   <leader>fb  open buffers     <leader>fh  search help
--   <leader>fr  recent files
--
-- Inside the picker: type to filter, Ctrl-n/Ctrl-p (or arrows) to move,
-- <CR> to open, Ctrl-v / Ctrl-x to open in a vertical / horizontal split,
-- <Esc> (or Ctrl-c) to close.
--
-- Repo: https://github.com/nvim-telescope/telescope.nvim

return {
  "nvim-telescope/telescope.nvim",
  -- Track the default (master) branch. The tagged `0.1.x` stable branch is old
  -- enough that its previewer still calls vim.treesitter.language.ft_to_lang(),
  -- which Neovim 0.12 removed (renamed to get_lang) -- that crashes the preview.
  -- master has migrated to the new API.

  dependencies = {
    "nvim-lua/plenary.nvim",
    -- Optional native fuzzy sorter (compiled with `make`) -- faster, better ranking.
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },

  -- Load lazily on first use.
  cmd = "Telescope",
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep (search text)" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find open buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Search help" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
  },

  opts = {
    defaults = {
      -- Don't clutter results with anything inside a .git directory.
      file_ignore_patterns = { "%.git/" },
    },
    pickers = {
      find_files = {
        -- Include dotfiles in results (you edit these constantly).
        hidden = true,
      },
    },
  },

  -- We need a config function (not just opts) so we can load the fzf extension
  -- after telescope is set up.
  config = function(_, opts)
    local telescope = require("telescope")
    telescope.setup(opts)
    -- Enable the native sorter if it built successfully.
    pcall(telescope.load_extension, "fzf")
  end,
}
