-- conform.nvim: run external formatters (Prettier, stylua, gofmt, ...) and
-- apply their output back to the buffer -- including format-on-save.
--
-- How it works: `formatters_by_ft` maps a filetype to a list of formatters.
-- On save (BufWritePre) conform looks up the formatters for the buffer, runs
-- them (feeding the buffer via stdin), and applies a minimal diff so the cursor
-- and undo history survive. For Prettier it prefers the project's local
-- node_modules/.bin and that project's own Prettier config.
--
-- Inspect what will run for the current buffer with :ConformInfo.
--
-- Repo: https://github.com/stevearc/conform.nvim

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" }, -- load right before the first save
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
      -- Prettier langs (uses the project's local prettier + config).
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

      -- "_" runs for any filetype without a formatter above.
      ["_"] = { "trim_whitespace" },
    },

    -- Format automatically on :w. Falls back to LSP formatting if a filetype
    -- has no configured formatter (a no-op until we add LSP).
    format_on_save = {
      timeout_ms = 500,
      lsp_format = "fallback",
    },

    -- Stay quiet when a filetype's formatter isn't installed/available (e.g. a
    -- JSON file outside a project that has Prettier). Formatting still runs
    -- wherever a formatter IS found; real errors are still reported.
    notify_no_formatters = false,

    -- Note: conform's built-in stylua already passes --search-parent-directories,
    -- so it finds a project's stylua.toml first, then the global
    -- ~/.config/stylua/stylua.toml -- no extra config needed here.
  },
}
