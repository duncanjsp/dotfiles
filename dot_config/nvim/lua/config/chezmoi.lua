-- Detects filetypes from the name chezmoi will apply a source file as.
-- Templates get a `.chezmoitmpl` suffix: ftplugins still load, but
-- vim.lsp.enable() and conform match filetypes exactly, so nothing tries to
-- parse `{{ }}`.

local source_dir = vim.fs.normalize(
  vim.env.CHEZMOI_SOURCE_DIR or vim.fs.joinpath(vim.env.HOME, ".local/share/chezmoi")
)

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

--- @param path string absolute path inside the chezmoi source directory
--- @return string? filetype
--- @return boolean template
local function resolve(path)
  local rel = path:sub(#source_dir + 2)

  local parts, template = {}, false
  for _, part in ipairs(vim.split(rel, "/", { plain = true })) do
    -- Ciphertext and symlink targets, whatever their names suggest.
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

  -- Neovim only resolves extensionless `config` files by sniffing contents.
  if not ft and (parts[#parts] == "config" or parts[#parts]:match("%.conf$")) then
    ft = "conf"
  end

  return ft, template
end

vim.filetype.add({
  pattern = {
    [vim.pesc(source_dir) .. "/.*"] = {
      function(path, bufnr)
        if path:find("/%.git/") or path:find("/%.jj/") then
          return nil
        end

        local ft, template = resolve(path)

        -- modify_ scripts declare template-ness in their contents.
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
        return ft
      end,
      -- Priority >= 0 runs before extension rules, beating `tmpl` -> `template`.
      { priority = 100 },
    },
  },
})

-- nvim-treesitter's `main` branch starts no highlighter itself. gotmpl is the
-- root parser, with the target language injected into the text between actions.
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

    -- Fails while gotmpl is still compiling on a fresh machine.
    local ok = pcall(vim.treesitter.get_parser, args.buf, "gotmpl", { injections = injections })
    if ok then
      vim.treesitter.start(args.buf, "gotmpl")
    end
  end,
})
