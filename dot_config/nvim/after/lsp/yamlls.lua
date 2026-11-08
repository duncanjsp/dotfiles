-- Off so SchemaStore.nvim is the only schema source.
---@type vim.lsp.Config
return {
  settings = {
    yaml = {
      schemaStore = { enable = false, url = "" },
      schemas = require("schemastore").yaml.schemas(),
    },
  },
}
