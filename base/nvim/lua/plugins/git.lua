return {
  -- Keymaps (<leader>g*) live in config/keymaps.lua.
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiff", "Gvdiffsplit", "Gread", "Gwrite" },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
}
