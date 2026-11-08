-- conform formats with stylua.
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
