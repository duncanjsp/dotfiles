-- Formatting is prettier's job (see conform.lua).
local inlay_hints = {
  enumMemberValues = { enabled = true },
  functionLikeReturnTypes = { enabled = true },
  parameterNames = { enabled = "all", suppressWhenArgumentMatchesName = true },
  parameterTypes = { enabled = false },
  propertyDeclarationTypes = { enabled = true },
  variableTypes = { enabled = false, suppressWhenTypeMatchesName = true },
}

---@type vim.lsp.Config
return {
  settings = {
    javascript = { format = { enable = false }, inlayHints = inlay_hints },
    typescript = { format = { enable = false }, inlayHints = inlay_hints },
  },
}
