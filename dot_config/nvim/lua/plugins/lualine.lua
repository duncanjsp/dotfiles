-- https://github.com/nvim-lualine/lualine.nvim
return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  config = function()
    -- jj status: nearest bookmark + revisions ahead + short change-id + edit
    -- stats; falls back to the git branch outside jj repos. Cached, refreshed
    -- on a few events rather than every redraw. Icons via nr2char to keep the
    -- source ASCII-clean.
    local SC_ICON = vim.fn.nr2char(0xe0a0)
    local AHEAD_ICON = vim.fn.nr2char(0x21e1)
    local EDIT_ICON = vim.fn.nr2char(0xf040)

    local jj = { text = "", is_repo = false }

    local function jj_refresh()
      local root = vim.fs.root(0, ".jj")
      jj.is_repo = root ~= nil
      if not root then
        jj.text = ""
        return
      end

      local function run(args)
        local cmd = { "jj", "--no-pager", "-R", root }
        vim.list_extend(cmd, args)
        local out = vim.fn.system(cmd)
        return (vim.v.shell_error == 0) and out or nil
      end

      -- Snapshots (no --ignore-working-copy) so edit counts reflect saved files.
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

      local function log1(revset, template)
        return run({ "--ignore-working-copy", "log", "--no-graph", "-r", revset, "-T", template })
      end

      local changeid = log1("@", "change_id.shortest(1)")
      changeid = changeid and vim.trim(changeid) or "?"

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

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "FocusGained", "DirChanged" }, {
      group = vim.api.nvim_create_augroup("lualine_jj", { clear = true }),
      callback = jj_refresh,
    })
    jj_refresh()

    require("lualine").setup({
      options = {
        theme = "auto",
        globalstatus = true,
      },
      sections = {
        lualine_b = {
          { jj_component },
          { "branch", cond = not_jj_repo },
          "diff",
          "diagnostics",
        },
        lualine_c = { "filename" },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    })
  end,
}
