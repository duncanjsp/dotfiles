-- Base keymaps (editor-only).
--
-- Plugin-specific shortcuts (file tree, fuzzy finder, ...) live inside each
-- plugin's own file, so everything about a plugin stays in one place.
--
-- `vim.keymap.set(mode, lhs, rhs, opts)` defines a mapping. The `desc` field
-- is the human-readable label that will show up in the which-key popup later.

local map = vim.keymap.set

-- Exit insert mode with `jk` -- faster than reaching for the Esc key.
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Press <Esc> in normal mode to clear the leftover search highlighting.
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Save the current file.
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save file" })

-- Move between window splits with Ctrl + h/j/k/l (instead of <C-w> then h/j/k/l).
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
