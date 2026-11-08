local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.clipboard = "unnamedplus"
opt.mouse = "a"

-- Fallback only; .editorconfig and formatters override.
opt.expandtab = false
opt.tabstop = 4
opt.shiftwidth = 4
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

opt.termguicolors = true
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.undofile = true
opt.splitright = true
opt.splitbelow = true
opt.updatetime = 250
opt.showmode = false

-- Built-in completion only (<C-x><C-f>, cmdline); blink.cmp draws LSP's.
opt.completeopt = { "menu", "menuone", "noselect", "popup", "fuzzy" }

opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldtext = ""
