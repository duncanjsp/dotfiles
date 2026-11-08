return {
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonLog" },
    -- Append, so a server from packages.yaml wins over Mason's copy.
    opts = { PATH = "append" },
  },

  -- Only for lspconfig-to-Mason name translation; after/lsp/ does enabling.
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = { automatic_enable = false },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason-lspconfig.nvim" },
    event = "VeryLazy",
    cmd = {
      "MasonToolsInstall",
      "MasonToolsInstallSync",
      "MasonToolsUpdate",
      "MasonToolsClean",
    },
    opts = {
      ensure_installed = {
        "bashls",
        "gopls",
        "jsonls",
        "lua_ls",
        "vtsls",
        "yamlls",
        -- Not servers: bashls calls shellcheck, conform calls shfmt.
        "shellcheck",
        "shfmt",
      },
      run_on_start = true,
      debounce_hours = 24,
    },
  },

  -- Required by after/lsp/{json,yaml}ls.lua.
  { "b0o/SchemaStore.nvim", lazy = true },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason-lspconfig.nvim",
      "b0o/SchemaStore.nvim",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- A server is enabled by having a file in after/lsp/.
      local config_dir = vim.fn.stdpath("config")
      local servers = {}
      for _, file in ipairs(vim.api.nvim_get_runtime_file("after/lsp/*.lua", true)) do
        if vim.startswith(file, config_dir) then
          table.insert(servers, vim.fn.fnamemodify(file, ":t:r"))
        end
      end
      vim.lsp.enable(servers)

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then
            return
          end
          local buf = args.buf

          if client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = buf })
          end

          local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc })
          end

          -- Unlike the `gr*` maps, `gd` isn't an LSP default.
          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
          map("<leader>ci", function()
            local on = vim.lsp.inlay_hint.is_enabled({ bufnr = buf })
            vim.lsp.inlay_hint.enable(not on, { bufnr = buf })
          end, "Toggle inlay hints")

          local ok, wk = pcall(require, "which-key")
          if ok then
            wk.add({
              buffer = buf,
              { "gr", group = "lsp" },
              { "grn", desc = "Rename symbol" },
              { "gra", desc = "Code action" },
              { "grr", desc = "References" },
              { "gri", desc = "Implementations" },
              { "grt", desc = "Type definition" },
              { "gO", desc = "Document symbols" },
              { "K", desc = "Hover documentation" },
            })
          end
        end,
      })
    end,
  },
}
