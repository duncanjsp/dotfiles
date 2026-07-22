-- Treesitter: structural syntax highlighting + folding.
--
-- Treesitter parses each file into a real syntax tree, so highlighting knows
-- what's a function, string, keyword, etc. Each language needs a small parser,
-- compiled locally by your C compiler (clang).
--
-- We use the `main` branch (the current, actively-developed rewrite). The old
-- `master` branch is archived and crashes on Neovim 0.12 when parsing language
-- INJECTIONS -- e.g. a ```lua code block embedded inside a Markdown file.
--
-- Repo: https://github.com/nvim-treesitter/nvim-treesitter (main branch)

return {
  "nvim-treesitter/nvim-treesitter",

  -- The `main` branch is a different API from most older tutorials: highlighting
  -- is started manually (see the autocmd below) rather than via a `highlight`
  -- option, and parsers are installed through `require("nvim-treesitter").install`.
  branch = "main",

  -- Load at startup and rebuild/refresh parsers on install or update.
  lazy = false,
  build = ":TSUpdate",

  config = function()
    local ts = require("nvim-treesitter")

    -- Parsers to install up front. Others install on demand (see autocmd).
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

    -- On the `main` branch we start highlighting ourselves whenever a buffer's
    -- language has a parser. This also auto-installs a missing parser the first
    -- time you open a new filetype (highlighting kicks in on the next open).
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_highlight", { clear = true }),
      callback = function(args)
        local buf = args.buf
        local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
        if not lang then
          return
        end

        -- Auto-install on demand if this parser isn't present yet -- but only if
        -- a parser actually exists for this language. Without this guard, opening
        -- a parser-less filetype (e.g. "text") makes nvim-treesitter warn:
        -- "skipping unsupported language: text".
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

        -- Start Treesitter highlighting for this buffer (folding uses the
        -- foldexpr already set in options.lua).
        pcall(vim.treesitter.start, buf, lang)
      end,
    })
  end,
}
