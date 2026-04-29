local M = {
  icons = nil,
  border = "rounded",
  min_severity = 4,
  max_width = nil,
  show_diagnostic_count = true,
  always_show_message = false,
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
  local signs = vim.diagnostic.config().signs
  M.sign_text = type(signs) == "table" and signs.text
    or { "", "", "", "" }

  if M.always_show_message then
    M.update_diagnostic_config()
  end
end

function M.start()
  if
    not vim.diagnostic.is_enabled({ bufnr = 0 })
    or #vim.lsp.get_clients({ bufnr = 0 }) == 0
    or M.show_diagnostic_count == false
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
      priority = 1000,
    })
  end
end

function M.show()
  vim.diagnostic.open_float({
    scope = "line",
    border = M.border,
    severity_sort = true,
    max_width = M.max_width,
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

function M.update_diagnostic_config()
  local cfg = vim.diagnostic.config()
  cfg = vim.tbl_deep_extend("force", cfg, {
    virtual_text = {
      virt_text_pos = "eol_right_align",
    },
    severity_sort = true,
  })
  assert(cfg)

  if cfg.virtual_text == false then
    cfg.virtual_text = {}
  end

  if type(M.icons) == "table" then
    cfg.virtual_text.prefix = function(diagnostic)
      local icons = {
        [vim.diagnostic.severity.ERROR] = M.icons[1],
        [vim.diagnostic.severity.WARN] = M.icons[2],
        [vim.diagnostic.severity.INFO] = M.icons[3],
        [vim.diagnostic.severity.HINT] = M.icons[4],
      }
      return icons[diagnostic.severity]
    end
  end
  vim.diagnostic.config(cfg)
end

return M
