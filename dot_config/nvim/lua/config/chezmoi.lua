-- Chezmoi stores its source files under mangled names -- `dot_`, `private_`,
-- `run_onchange_before_` and friends, plus a `.tmpl` suffix -- so Neovim sees
-- `dot_zshrc.tmpl`, matches the built-in `template` filetype (which has no
-- syntax file at all) and shows a wall of grey. Two halves to fixing that:
--
--   1. Rebuild the name the file will have once chezmoi has applied it, and
--      ask Neovim about that instead.
--   2. For templates, suffix the answer: `zsh` becomes `zsh.chezmoitmpl`.
--      Neovim sources ftplugin/zsh.vim for either, so indent, folds and
--      commentstring still work, but `vim.lsp.enable()` compares `filetypes`
--      exactly -- so no server attaches to a buffer full of `{{ }}` it cannot
--      parse and would only ever report as broken. conform.lua skips the
--      suffix for the same reason.

local source_dir = vim.fs.normalize(
  vim.env.CHEZMOI_SOURCE_DIR or vim.fs.joinpath(vim.env.HOME, ".local/share/chezmoi")
)

-- Stripped from the front of each path component, repeatedly and in any order,
-- so `private_dot_config` and `run_onchange_before_10-foo.sh` both come apart.
-- `dot_` is handled separately below because it becomes a character rather
-- than disappearing.
local attributes = {
  "after_",
  "before_",
  "create_",
  "empty_",
  "exact_",
  "executable_",
  "external_",
  "literal_",
  "modify_",
  "once_",
  "onchange_",
  "private_",
  "readonly_",
  "remove_",
  "run_",
}

--- Undo one path component's chezmoi attributes.
--- @param part string
--- @return string name, boolean template
local function unmangle(part)
  local stripped = true
  while stripped do
    stripped = false
    for _, attr in ipairs(attributes) do
      if vim.startswith(part, attr) then
        part = part:sub(#attr + 1)
        stripped = true
      end
    end
  end

  local template = false
  local base = part:match("^(.+)%.tmpl$")
  if base then
    part, template = base, true
  end
  part = part:gsub("%.literal$", "")

  if vim.startswith(part, "dot_") then
    part = "." .. part:sub(5)
  end
  return part, template
end

--- What `path` will be once chezmoi has applied it.
--- @param path string absolute path inside the chezmoi source directory
--- @return string? filetype
--- @return boolean template
local function resolve(path)
  local rel = path:sub(#source_dir + 2)

  local parts, template = {}, false
  for _, part in ipairs(vim.split(rel, "/", { plain = true })) do
    -- Encrypted files are ciphertext -- named by the `encrypted_` attribute
    -- outside .chezmoitemplates and by extension within it -- and a symlink's
    -- source holds a bare target path. Neither wants the filetype its name
    -- suggests.
    if
      vim.startswith(part, "encrypted_")
      or vim.startswith(part, "symlink_")
      or part:match("%.age$")
      or part:match("%.asc$")
    then
      return nil, false
    end
    local name, is_template = unmangle(part)
    template = template or is_template
    table.insert(parts, name)
  end

  -- Templates that never say so in the name.
  if parts[1] == ".chezmoitemplates" or vim.startswith(parts[#parts], ".chezmoiignore") then
    template = true
  end

  local target = table.concat(parts, "/")
  local ft = vim.filetype.match({ filename = vim.fs.joinpath(vim.env.HOME, target) })

  -- Extensionless `config` files are the common case chezmoi leaves us with
  -- that Neovim can only otherwise resolve by sniffing the first line.
  if not ft and (parts[#parts] == "config" or parts[#parts]:match("%.conf$")) then
    ft = "conf"
  end

  return ft, template
end

vim.filetype.add({
  pattern = {
    [vim.pesc(source_dir) .. "/.*"] = {
      function(path, bufnr)
        -- Not chezmoi's, and nothing here is named for its contents.
        if path:find("/%.git/") or path:find("/%.jj/") then
          return nil
        end

        local ft, template = resolve(path)

        -- A modify_ script becomes a template by saying so in its contents
        -- rather than its name, so this one has to look inside.
        if not template and bufnr and vim.fs.basename(path):find("modify_", 1, true) then
          for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
            if line:find("chezmoi:modify-template", 1, true) then
              template = true
              break
            end
          end
        end

        if template then
          return ft and (ft .. ".chezmoitmpl") or "chezmoitmpl"
        end
        -- nil falls through to Neovim's own detection.
        return ft
      end,
      -- Patterns at priority >= 0 are tried before extensions, which is what
      -- it takes to beat the built-in `tmpl` -> `template` rule.
      { priority = 100 },
    },
  },
})

-- The filetype is not one Treesitter maps to a language, and nvim-treesitter's
-- `main` branch starts no highlighter by itself, so both are done here. gotmpl
-- is the root parser with the target language injected into the literal text
-- around each action; gotmpl's own queries carry a raised priority precisely so
-- they win wherever the two overlap.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("chezmoi_template", { clear = true }),
  pattern = { "chezmoitmpl", "*.chezmoitmpl" },
  callback = function(args)
    local base = vim.bo[args.buf].filetype:match("^(.+)%.chezmoitmpl$")
    local lang = base and vim.treesitter.language.get_lang(base)

    local injections
    if lang then
      injections = {
        gotmpl = ('((text) @injection.content (#set! injection.language "%s") (#set! injection.combined))'):format(
          lang
        ),
      }
    end

    -- Fails only on a cold machine, where config.parsers is still compiling
    -- gotmpl; the next launch has it.
    local ok = pcall(vim.treesitter.get_parser, args.buf, "gotmpl", { injections = injections })
    if ok then
      vim.treesitter.start(args.buf, "gotmpl")
    end
  end,
})
