-- Lualine: a fast, configurable statusline (the bar at the bottom).
--
-- Shows the current mode, VCS info, diagnostics, filename, filetype (with an
-- icon), and cursor position -- themed to match the colorscheme.
--
-- This config adds a custom Jujutsu (jj) component that mirrors the user's
-- ohmyposh prompt: a source-control icon, the nearest ancestor bookmark with a
-- "⇡N" ahead counter, the short change-id, and the working-copy edit stats
-- (e.g. "  add-nvim⇡5 t   +1"). Outside a jj repo it falls back to the git
-- branch. The value is cached and only refreshed on a few events, so the
-- statusline never shells out to jj on every redraw.
--
-- Repo: https://github.com/nvim-lualine/lualine.nvim

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- icons (already installed)
  event = "VeryLazy",

  config = function()
    -- ----- Jujutsu (jj) status, cached -----
    -- Icons built from codepoints via nr2char, so no fragile Private-Use bytes
    -- live in this file. Change a number to swap a glyph (see nerdfonts.com).
    local SC_ICON = vim.fn.nr2char(0xe0a0)    -- powerline branch (source control)
    local AHEAD_ICON = vim.fn.nr2char(0x21e1) -- upwards dashed arrow (revisions ahead)
    local EDIT_ICON = vim.fn.nr2char(0xf040)  -- pencil (working copy has edits)

    local jj = { text = "", is_repo = false }

    local function jj_refresh()
      local root = vim.fs.root(0, ".jj")
      jj.is_repo = root ~= nil
      if not root then
        jj.text = ""
        return
      end

      -- Run any jj command under this repo; returns stdout, or nil on error.
      local function run(args)
        local cmd = { "jj", "--no-pager", "-R", root }
        vim.list_extend(cmd, args)
        local out = vim.fn.system(cmd)
        return (vim.v.shell_error == 0) and out or nil
      end

      -- Edits on the current revision (@). We deliberately DO snapshot here (no
      -- --ignore-working-copy) so counts reflect files you've saved, like your
      -- shell prompt does. Summary lines look like "A path" / "M path" / "D path".
      local added, modified, deleted = 0, 0, 0
      local summary = run({ "diff", "-r", "@", "--summary" })
      if summary then
        for line in summary:gmatch("[^\r\n]+") do
          local mark = line:sub(1, 1)
          if mark == "A" then
            added = added + 1
          elseif mark == "M" then
            modified = modified + 1
          elseif mark == "D" then
            deleted = deleted + 1
          end
        end
      end

      -- Metadata queries. The snapshot above already refreshed repo state, so
      -- these use --ignore-working-copy to stay fast and side-effect free.
      local function log1(revset, template)
        return run({ "--ignore-working-copy", "log", "--no-graph", "-r", revset, "-T", template })
      end

      -- Short change-id (shortest unique prefix; raise the number for more chars).
      local changeid = log1("@", "change_id.shortest(1)")
      changeid = changeid and vim.trim(changeid) or "?"

      -- Nearest ancestor bookmark, and how many revisions @ is ahead of it.
      local bm = log1("heads(::@ & bookmarks())", 'bookmarks.join(",") ++ "\n"')
      bm = bm and bm:match("[^\r\n,]+") or nil
      local ahead = 0
      if bm then
        local ahead_out = log1("heads(::@ & bookmarks())..@", '"\\n"')
        if ahead_out then
          for _ in ahead_out:gmatch("\n") do
            ahead = ahead + 1
          end
        end
      end

      -- Assemble, mirroring the ohmyposh segment:
      --   <icon> <bookmark><⇡ahead> <changeid> [<edit-icon> <stat>]
      local parts = { SC_ICON }
      if bm then
        parts[#parts + 1] = bm .. (ahead > 0 and (AHEAD_ICON .. ahead) or "")
      end
      parts[#parts + 1] = changeid
      local text = table.concat(parts, " ")

      local stats = {}
      if added > 0 then
        stats[#stats + 1] = "+" .. added
      end
      if modified > 0 then
        stats[#stats + 1] = "~" .. modified
      end
      if deleted > 0 then
        stats[#stats + 1] = "-" .. deleted
      end
      if #stats > 0 then
        text = text .. "  " .. EDIT_ICON .. " " .. table.concat(stats, " ")
      end

      jj.text = text
    end

    local function jj_component()
      return jj.text
    end

    local function not_jj_repo()
      return not jj.is_repo
    end

    -- Refresh the cached jj value on the events where it might have changed.
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "FocusGained", "DirChanged" }, {
      group = vim.api.nvim_create_augroup("lualine_jj", { clear = true }),
      callback = jj_refresh,
    })
    jj_refresh() -- prime it now so it shows immediately

    -- ----- Lualine setup -----
    require("lualine").setup({
      options = {
        theme = "auto", -- derive colors from the active colorscheme (Dracula)
        icons_enabled = true,
        globalstatus = true, -- one shared statusline across all splits
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
      },
      sections = {
        -- Section B: our jj component (jj repos), git branch (elsewhere), then diff/diagnostics.
        lualine_b = {
          { jj_component },
          { "branch", cond = not_jj_repo },
          "diff",
          "diagnostics",
        },
        -- The rest keep Lualine's sensible defaults.
        lualine_c = { "filename" },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    })
  end,
}
