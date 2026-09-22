# CLAUDE.md — Neovim config

Plain lazy.nvim config (no LazyVim, no Mason). It is the Lua mirror of the
declarative nixvim setup in `nixos-config/home/patrikpersson/nvim.nix`; the
two are meant to behave identically. When one changes, port the change to
the other in the same sitting.

## Layout

```
init.lua                 # requires config.lazy
lua/config/lazy.lua      # bootstrap lazy.nvim, leaders, loads the three below, then plugins
lua/config/options.lua   # vim.opt.*            (nvim.nix: opts)
lua/config/keymaps.lua   # global keymaps        (nvim.nix: keymaps)
lua/config/autocmds.lua  # markdown wrap, NormalNC transparency (nvim.nix: autoCmd + extraConfigLua)
lua/plugins/*.lua        # one spec per plugin   (nvim.nix: plugins.*)
bin/glow-forced-color    # glow wrapper that keeps colour when spawned without a pty
stylua.toml              # 2-space indent for the Lua here
```

Plugins: catppuccin (mocha, transparent), flash, fugitive, gitsigns, glow,
mini.surround, neo-tree, telescope + fzf-native, treesitter + textobjects,
which-key, lualine, bufferline, nvim-cmp + luasnip, conform, nvim-lint,
nvim-lspconfig.

## Where binaries come from

Nothing is downloaded by the editor. Everything resolves from PATH:

- Homebrew (see `Brewfile`): neovim, ripgrep, glow, lua-language-server,
  bash-language-server, typescript-language-server, pyright, zls, stylua,
  nixfmt, prettier, ruff.
- Nix profile: `nil` (`nix profile install nixpkgs#nil`).
- rustup: rust-analyzer, rustfmt.
- Project devShell (direnv): metals, elixir-ls, ocamllsp, mix. Not installed
  globally on purpose; `vim.lsp.enable` skips a server whose binary is absent.

## Verify after a change

```
nvim --headless "+Lazy! sync" +qa          # install/update plugins, build fzf-native
nvim --headless "+TSUpdateSync" +qa        # compile any new parsers
nvim --headless "+checkhealth" "+w! /tmp/health.txt" +qa && grep -i error /tmp/health.txt
```

Then interactively: `<leader>ff` lists files, `<leader>e` toggles neo-tree,
`jj` escapes insert, open a `.lua` file and `K` shows a hover. `:Lazy` should
exist, `:Mason` should not.

## Keymap conventions

Leader is `<space>`. Prefixes: `<leader>f*` telescope, `<leader>g*` git,
`<leader>c*` code/quickfix, `<leader>s*` splits, `<leader>b*` buffers.
Every map carries a `desc` so which-key stays useful; keep that when adding.
`gd` is telescope tags globally and LSP definition buffer-locally once a
server attaches.
