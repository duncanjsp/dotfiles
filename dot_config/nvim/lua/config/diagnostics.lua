-- Every producer -- LSP servers, linters, formatters -- publishes here, and
-- this is the one place their output is styled.
vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  -- Wait for a pause rather than reporting mid-keystroke.
  update_in_insert = false,
  virtual_text = { spacing = 2, prefix = "●" },
  float = { border = "rounded", source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚",
      [vim.diagnostic.severity.WARN] = "󰀪",
      [vim.diagnostic.severity.INFO] = "󰋽",
      [vim.diagnostic.severity.HINT] = "󰌶",
    },
  },
})
