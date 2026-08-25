-- https://github.com/folke/lazydev.nvim
-- Teaches lua_ls about the Neovim API and the loaded plugins, so editing this
-- config gets completion and hover for `vim.*` instead of undefined-global
-- warnings.
return {
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
  },
}
