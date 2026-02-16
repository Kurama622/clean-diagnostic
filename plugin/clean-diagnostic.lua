vim.api.nvim_create_autocmd(
  { "LspAttach", "BufEnter", "DiagnosticChanged" },
  {
    pattern = "*",
    callback = require("clean-diagnostic").start,
  }
)

vim.api.nvim_create_autocmd("CursorMoved", {
  pattern = "*",
  callback = function()
    local winid = require("clean-diagnostic")._.winid
    if vim.api.nvim_win_is_valid(winid) then
      vim.api.nvim_win_close(winid, true)
    end
  end,
})
