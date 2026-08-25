-- SchemaStore.nvim supplies the catalogue, so yamlls' own fetcher is off to
-- stop the two disagreeing about which schema applies.
---@type vim.lsp.Config
return {
  settings = {
    yaml = {
      schemaStore = { enable = false, url = "" },
      schemas = require("schemastore").yaml.schemas(),
    },
  },
}
