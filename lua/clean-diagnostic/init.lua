local M = {
  sign_text = { "", "", "", "" },
  border = "rounded",
  min_severity = 4,
}

local diagnostic_severity_hl = {
  "DiagnosticError",
  "DiagnosticWarn",
  "DiagnosticInfo",
  "DiagnosticHint",
}

local diagnostic_ns_id = vim.api.nvim_create_namespace("diagnostic_ns")

function M.setup(opts)
  M = vim.tbl_deep_extend("force", M, opts or {})
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
  for i = 1, M.min_severity do
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
  vim.diagnostic.open_float({
    scope = "line",
    border = M.border,
    severity_sort = true,
    severity = { min = M.min_severity },
    format = function(diagnostic)
      return (" %s"):format(diagnostic.message)
    end,
    prefix = function(diagnostic)
      return M.sign_text[diagnostic.severity],
        diagnostic_severity_hl[diagnostic.severity]
    end,
  })
end

return M
