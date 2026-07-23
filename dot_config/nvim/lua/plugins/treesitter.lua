-- https://github.com/nvim-treesitter/nvim-treesitter
-- `main` branch: `master` is archived and crashes on Neovim 0.12 parsing
-- injections. Requires the tree-sitter CLI to build parsers.
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",

  config = function()
    local ts = require("nvim-treesitter")

    ts.install({
      "lua",
      "vim",
      "vimdoc",
      "query",
      "bash",
      "json",
      "yaml",
      "toml",
      "markdown",
      "markdown_inline",
    })

    -- On `main`, highlighting is started manually per buffer.
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_highlight", { clear = true }),
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
        if not lang then
          return
        end

        local installed = ts.get_installed and ts.get_installed() or {}
        if not vim.tbl_contains(installed, lang) then
          local available = ts.get_available and ts.get_available() or {}
          if vim.tbl_contains(available, lang) then
            pcall(function()
              ts.install({ lang })
            end)
          end
          return
        end

        pcall(vim.treesitter.start, args.buf, lang)
      end,
    })
  end,
}
