vim.api.nvim_create_autocmd(
  { "LspAttach", "BufEnter", "DiagnosticChanged" },
  {
    pattern = "*",
    callback = require("clean-diagnostic").start,
  }
)
