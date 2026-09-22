-- The pieces LazyVim used to enable implicitly, made explicit (same as the
-- `which-key`/`gitsigns`/`lualine`/`bufferline` one-liners in nvim.nix).
return {
  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },
  { "nvim-lualine/lualine.nvim", event = "VeryLazy", opts = {} },
  { "akinsho/bufferline.nvim", event = "VeryLazy", opts = {} },
}
