# Clean-diagnostic

![clean-diagnostic](https://github.com/user-attachments/assets/821249a5-13d5-4d09-88f7-84a2713c8563)

## Installation

```lua
  {
    "kurama622/clean-diagnostic",
    event = "LspAttach",
    opts = {
      sign_text = { "", "", "", "" },
      border = "rounded",
      min_severity = 4,
      max_width = 78,
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
