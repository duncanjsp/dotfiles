-- Diagnostics come from shellcheck, which bashls runs when it is on PATH.
---@type vim.lsp.Config
return {
  settings = {
    bashIde = {
      shellcheckPath = "shellcheck",
    },
  },
}
