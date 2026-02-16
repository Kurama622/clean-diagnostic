# clean-diagnostic

## installation

```lua
  {
    "kurama622/clean-diagnostic",
    event = "LspAttach",
    opts = {
      sign_text = { "", "", "", "" },
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
