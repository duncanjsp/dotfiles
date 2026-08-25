-- Formatting is stylua's job (see conform.lua); lazydev.nvim supplies the
-- Neovim API library, so there is no workspace config to do here.
---@type vim.lsp.Config
return {
  settings = {
    Lua = {
      format = { enable = false },
      hint = {
        enable = true,
        arrayIndex = "Disable",
        paramName = "Literal",
        setType = true,
      },
    },
  },
}
