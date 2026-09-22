-- Bootstrap lazy.nvim, load core config, then the plugin specs.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Leaders must be set before any plugin maps are created.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Core config runs before plugins, same order as nixvim (globals/opts/keymaps/autoCmd, then plugins).
require("config.options")
require("config.keymaps")
require("config.autocmds")

require("lazy").setup({
  spec = { { import = "plugins" } },
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "catppuccin", "habamax" } },
  checker = { enabled = false },
  -- No plugin here needs luarocks; skipping the probe keeps :checkhealth
  -- clean on machines without a Lua 5.1 toolchain.
  rocks = { enabled = false },
  change_detection = { notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        "netrwPlugin",
        "netrw",
      },
    },
  },
})
