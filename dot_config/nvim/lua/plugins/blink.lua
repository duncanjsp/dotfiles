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
