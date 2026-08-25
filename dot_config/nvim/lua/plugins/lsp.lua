-- https://github.com/neovim/nvim-lspconfig
-- Neovim ships the LSP client and the `gr*` keymaps itself. These plugins only
-- supply per-server config and the binaries to run; the completion menu is
-- blink.cmp's (see blink.lua).
return {
  -- https://github.com/mason-org/mason.nvim
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonLog" },
    -- Append, so a server installed by packages.yaml wins over Mason's copy.
    opts = { PATH = "append" },
  },

  -- https://github.com/mason-org/mason-lspconfig.nvim
  -- Only here to translate lspconfig server names to Mason package names;
  -- enabling is done from after/lsp/ below.
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = { automatic_enable = false },
  },

  -- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
  -- Turns Mason from imperative into a list: anything missing is installed,
  -- and :MasonToolsClean removes anything not named here.
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
        -- Not servers: bashls runs shellcheck when it is on PATH, and conform
        -- formats sh with shfmt.
        "shellcheck",
        "shfmt",
      },
      run_on_start = true,
      -- Don't re-check the registry on every launch.
      debounce_hours = 24,
    },
  },

  -- https://github.com/b0o/SchemaStore.nvim
  -- Loaded on demand by after/lsp/{json,yaml}ls.lua.
  { "b0o/SchemaStore.nvim", lazy = true },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason-lspconfig.nvim",
      "b0o/SchemaStore.nvim",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- A file in after/lsp/ is the switch: present means enabled. Neovim
      -- discovers lsp/<name>.lua anywhere on the runtimepath and merges them,
      -- so ours lands on top of the base config nvim-lspconfig ships.
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

          -- `gd` is Vim's own local-declaration search, not an LSP default;
          -- the rest of the `gr*` family already is.
          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
          map("<leader>ci", function()
            local on = vim.lsp.inlay_hint.is_enabled({ bufnr = buf })
            vim.lsp.inlay_hint.enable(not on, { bufnr = buf })
          end, "Toggle inlay hints")

          -- Document the built-ins buffer-locally, so which-key only offers
          -- them where a server is attached to answer.
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
