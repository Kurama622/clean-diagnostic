# Clean-diagnostic

Specific information will be displayed in the floating window when you request to show diagnostic details; at other times, only counts will be displayed.

![clean-diagnostic](https://github.com/user-attachments/assets/821249a5-13d5-4d09-88f7-84a2713c8563)

## Installation

```lua
  {
    "kurama622/clean-diagnostic",
    event = "LspAttach",
    opts = {
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

## Other configuration items

- icons

Prefix icon for diagnostic messages.

```lua
icons = { "", "", "", "" }
```

- show_diagnostic_count

Default value is true

```lua
show_diagnostic_count = true
```


- always_show_message

Automatically show diagnostic messages on the right side(`eol_right_align`).

Default value is false

```lua
always_show_message = false,
```
