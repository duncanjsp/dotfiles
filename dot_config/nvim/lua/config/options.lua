-- Core editor settings. No plugins here -- just Neovim's built-in options.
-- `vim.opt` is the Lua interface to the classic `:set` command.

local opt = vim.opt

-- Line numbers: absolute on the current line, relative on the others.
-- Relative numbers make vertical motions easy (e.g. `5j` jumps down 5 lines).
opt.number = true
opt.relativenumber = true

-- Use the macOS system clipboard for all yank/paste, so copy/paste works
-- seamlessly with other apps.
opt.clipboard = "unnamedplus"

-- Enable the mouse in all modes (handy for the occasional click or scroll).
opt.mouse = "a"

-- Indentation: prefer real tabs, displayed 4 columns wide.
-- These are just the GLOBAL fallback. A project's `.editorconfig` (respected
-- automatically) and per-language rules override these; a formatter like
-- Prettier (added later via conform.nvim) wins for files it formats.
opt.expandtab = false -- the Tab key inserts a real tab character, not spaces
opt.tabstop = 4       -- a tab character displays as 4 columns
opt.shiftwidth = 4    -- `>>`, `<<`, and auto-indent step by 4 columns
opt.smartindent = true

-- Searching: case-insensitive UNLESS the query contains a capital letter.
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true  -- highlight all matches (we clear them with <Esc>, see keymaps)
opt.incsearch = true -- show matches incrementally as you type

-- 24-bit "true color" -- required for modern colorschemes like Dracula to
-- render with their full palette.
opt.termguicolors = true

-- Always show the sign column so the text doesn't jump sideways when signs
-- (git changes, diagnostics) appear later.
opt.signcolumn = "yes"

-- Keep 8 lines of context above/below the cursor when scrolling.
opt.scrolloff = 8

-- Persistent undo: your undo history survives closing and reopening a file.
opt.undofile = true

-- Open new splits to the right and below (feels more natural than the default).
opt.splitright = true
opt.splitbelow = true

-- Folding: use Treesitter to fold by real code structure (functions, blocks)
-- rather than by indentation. Keys: `za` toggle, `zc`/`zo` close/open,
-- `zM`/`zR` close-all/open-all. (The foldexpr calls a Treesitter function; on
-- buffers without a parser it simply yields no folds.)
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99 -- start fully unfolded (a high level means nothing is folded)
opt.foldtext = ""  -- show the folded line with its normal highlighting

-- Shorter update time -> snappier UI (also controls the which-key popup delay later).
opt.updatetime = 250

-- Don't print the mode ("-- INSERT --") in the command line; the statusline
-- we add later will show it instead.
opt.showmode = false
