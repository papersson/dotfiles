-- Mirrors `autoCmd` plus the ColorScheme hook from `extraConfigLua` in nvim.nix.

-- Wrap text in markdown files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  command = "setlocal wrap linebreak",
})

-- Catppuccin's transparent_background covers Normal but leaves NormalNC
-- opaque, so an unfocused split renders as a dark rectangle against the
-- terminal background. Force it transparent on every colorscheme load
-- (pattern = "*" so this survives a future colorscheme change too).
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
  end,
})
