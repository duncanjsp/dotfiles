-- Dracula colorscheme -- matches the Dracula Pro theme you use in Zed.
-- Repo: https://github.com/Mofiqul/dracula.nvim (a Lua port with good
-- highlighting support for the plugins we'll add later).
--
-- This file returns a "plugin spec": a table lazy.nvim understands. The first
-- string is the GitHub "owner/repo" to install.

return {
  "Mofiqul/dracula.nvim",

  -- A colorscheme should load during startup (not lazily) and BEFORE other
  -- plugins, so their highlight groups get the right colors from the start.
  lazy = false,
  priority = 1000,

  -- `config` runs after the plugin is installed/loaded. Here we apply the theme.
  config = function()
    require("dracula").setup({
      -- Options can be added later, e.g.:
      --   italic_comment = true,
      --   transparent_bg = false,
    })
    vim.cmd.colorscheme("dracula")
  end,
}
