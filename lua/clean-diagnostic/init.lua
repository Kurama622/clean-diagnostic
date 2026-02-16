local M = {
  sign_text = { "", "", "", "" },
  border = "rounded",
  _ = {
    winid = -1,
  },
}

local diagnostic_severity_hl = {
  "DiagnosticError",
  "DiagnosticWarn",
  "DiagnosticInfo",
  "DiagnosticHint",
}

local diagnostic_ns_id = vim.api.nvim_create_namespace("diagnostic_ns")

function M.setup(opts)
  M.sign_text = vim.tbl_deep_extend("force", M.sign_text, opts or {})
  vim.diagnostic.config({ signs = { text = M.sign_text } })
end

function M.start()
  if
    not vim.diagnostic.is_enabled({ bufnr = 0 })
    or #vim.lsp.get_clients({ bufnr = 0 }) == 0
  then
    return
  end

  -- get diagnostic count
  local t = {}
  for i = 1, 4 do
    local diag = vim.tbl_map(function(item)
      return {
        lnum = item.lnum,
        severity = item.severity,
      }
    end, vim.diagnostic.get(0, { severity = i }))

    for _, d in pairs(diag) do
      if t[d.lnum] == nil then
        t[d.lnum] = { 0, 0, 0, 0 }
      end
      t[d.lnum][d.severity] = t[d.lnum][d.severity] + 1
    end
  end

  -- clear diagnostic extmarks
  local extmarks =
    vim.api.nvim_buf_get_extmarks(0, diagnostic_ns_id, 0, -1, {})
  for _, mark in ipairs(extmarks) do
    vim.api.nvim_buf_del_extmark(0, diagnostic_ns_id, mark[1])
  end
  -- set diagnostic extmarks
  for lnum, counts in pairs(t) do
    local texts = {}
    for severity, count in pairs(counts) do
      if count > 0 then
        table.insert(texts, {
          (" %s %d"):format(M.sign_text[severity], count),
          diagnostic_severity_hl[severity],
        })
      end
    end

    pcall(vim.api.nvim_buf_set_extmark, 0, diagnostic_ns_id, lnum, -1, {
      virt_text = texts,
      virt_text_pos = "eol",
      invalidate = true,
      right_gravity = false,
    })
  end
end

function M.show()
  local diag =
    vim.diagnostic.get(0, { lnum = vim.api.nvim_win_get_cursor(0)[1] - 1 })
  local max_width = 0
  local buf = vim.api.nvim_create_buf(false, true)

  for i, d in pairs(diag) do
    local msg = ("%s %s: %s"):format(
      M.sign_text[d.severity],
      d.code,
      d.message
    )
    max_width = math.max(max_width, #msg)

    vim.api.nvim_buf_set_lines(buf, i - 1, i, false, { msg })
    vim.api.nvim_buf_set_extmark(buf, diagnostic_ns_id, i - 1, 0, {
      end_col = #msg,
      hl_group = diagnostic_severity_hl[d.severity],
    })
  end

  if max_width > 0 then
    M._.winid = vim.api.nvim_open_win(buf, false, {
      relative = "cursor",
      style = "minimal",
      width = max_width,
      height = #diag,
      bufpos = { 0, 0 },
      border = M.border,
    })

    vim.api.nvim_create_autocmd("CursorMoved", {
      pattern = "*",
      once = true,
      callback = function()
        local winid = require("clean-diagnostic")._.winid
        if vim.api.nvim_win_is_valid(winid) then
          vim.api.nvim_win_close(winid, true)
        end
      end,
    })
  end
end

return M
