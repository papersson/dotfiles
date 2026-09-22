-- Rendered markdown (tables, headings, code blocks) in a floating window,
-- separate from the editing buffer. Terminal-only, so the same config works
-- over SSH. glow itself comes from Homebrew; bin/glow-forced-color wraps it
-- so colour survives the pty-less spawn.
return {
  "ellisonleao/glow.nvim",
  cmd = "Glow",
  opts = {
    glow_path = vim.fn.stdpath("config") .. "/bin/glow-forced-color",
    border = "rounded",
    width_ratio = 0.85,
    height_ratio = 0.85,
  },
}
