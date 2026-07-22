-- Bootstrap lazy.nvim, the plugin manager.
--
-- On the very first launch this git-clones lazy.nvim into Neovim's data
-- directory (~/.local/share/nvim/lazy/). On every launch after that, the
-- clone already exists and this block is skipped.
--
-- Note: installed plugins live under ~/.local/share/nvim/ (XDG_DATA_HOME),
-- NOT in this config directory -- so they are not managed by Chezmoi and are
-- simply re-fetched on first launch on any machine.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Configure lazy.nvim.
--
-- `spec` lists the plugins to manage. It's empty for now (Step 1) so Neovim
-- opens with a working editor and the plugin manager, but zero plugins.
-- In Step 2 we switch this to `{ { import = "plugins" } }`, which tells lazy
-- to load every file in lua/plugins/ -- after that, adding a plugin is just
-- dropping a new file in that folder.
require("lazy").setup({
  spec = {},
  -- Don't auto-check for plugin updates on startup; run `:Lazy update` yourself.
  checker = { enabled = false },
  change_detection = { notify = false },
})
