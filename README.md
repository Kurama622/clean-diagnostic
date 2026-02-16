# Clean-diagnostic

## Installation

```lua
  {
    "kurama622/clean-diagnostic",
    event = "LspAttach",
    opts = {
      sign_text = { "", "", "", "" },
      border = "rounded",
      min_severity = 4,
    },
    keys = {
      {
        "<leader>sd",
        "<cmd>lua require('clean-diagnostic').show()<cr>",
        desc = "show the diagnostic of the current line",
      },
    },
  }
```
