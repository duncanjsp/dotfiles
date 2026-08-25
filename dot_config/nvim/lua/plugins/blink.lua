-- https://github.com/Saghen/blink.cmp
-- Neovim's built-in completion auto-triggers only on a server's declared
-- trigger characters -- "." for gopls -- so typing a bare function name never
-- opened a menu. blink triggers on word characters, ranks fuzzily, and falls
-- back to buffer words where no server is attached.
return {
  "saghen/blink.cmp",
  version = "1.*",
  event = "InsertEnter",
  opts = {
    -- Tab accepts, so Enter always means newline.
    keymap = { preset = "super-tab" },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      list = { selection = { preselect = true, auto_insert = false } },
    },
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
    signature = { enabled = true },
  },
}
