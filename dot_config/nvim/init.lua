-- Neovim entry point.
--
-- Load order matters: the leader key must be set BEFORE lazy.nvim loads any
-- plugins, otherwise plugin keymaps get registered under the wrong leader.

-- Use <Space> as the "leader" key -- the prefix for our custom shortcuts.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Core editor settings and base keymaps (no plugins involved).
require("config.options")
require("config.keymaps")

-- Bootstrap the plugin manager. From Step 2 onward this also auto-loads
-- every file in lua/plugins/.
require("config.lazy")
