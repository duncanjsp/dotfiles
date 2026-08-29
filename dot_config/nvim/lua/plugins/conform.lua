-- https://github.com/stevearc/conform.nvim
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true })
      end,
      desc = "Format buffer",
    },
  },
  opts = {
    formatters_by_ft = {
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      html = { "prettier" },
      markdown = { "prettier" },
      yaml = { "prettier" },
      lua = { "stylua" },
      go = { "gofmt" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      ["_"] = { "trim_whitespace" },
    },
    -- A chezmoi template is not valid in its target language, so shfmt and
    -- friends either refuse it or mangle the `{{ }}`. See config/chezmoi.lua
    -- for where that filetype suffix comes from.
    format_on_save = function(bufnr)
      if vim.bo[bufnr].filetype:find("chezmoitmpl", 1, true) then
        return nil
      end
      return { timeout_ms = 500, lsp_format = "fallback" }
    end,
    notify_no_formatters = false,
  },
}
