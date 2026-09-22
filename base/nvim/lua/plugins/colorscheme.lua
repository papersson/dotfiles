-- Catppuccin Mocha. Matches the Ghostty terminal theme so nvim reads as a
-- continuation of the terminal. transparent_background lets the terminal
-- background show through (no-op on the Mac's opaque Ghostty, a glassy
-- bleed on the NixOS 0.85-opacity one). no_italic keeps the old
-- gruvbox-era preference of no italics anywhere.
return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  lazy = false,
  opts = {
    flavour = "mocha",
    transparent_background = true,
    no_italic = true,
    term_colors = true,
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin")
  end,
}
