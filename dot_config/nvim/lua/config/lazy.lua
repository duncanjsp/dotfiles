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
-- `import = "plugins"` tells lazy to load every *.lua file in lua/plugins/ and
-- treat each one as a plugin spec. From here on, adding a plugin is simply
-- dropping a new commented file into that folder -- no wiring needed.
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  -- Don't auto-check for plugin updates on startup; run `:Lazy update` yourself.
  checker = { enabled = false },
  change_detection = { notify = false },
})
