-- LSP client. No Mason: binaries resolve from PATH, matching the NixOS side
-- where they come from nixpkgs. On this Mac:
--   Homebrew (Brewfile): lua-language-server, bash-language-server,
--                        typescript-language-server, pyright, zls
--   nix profile:         nil   (`nix profile install nixpkgs#nil`)
--   rustup:              rust-analyzer
--   project devShell:    metals, elixir-ls, ocamllsp — deliberately not
--                        installed globally (see "Every project ships its
--                        own devShell" in the global CLAUDE.md). ocamllsp in
--                        particular must be built with the project's exact
--                        OCaml compiler. Servers whose binary is absent are
--                        skipped silently by vim.lsp.enable.
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "hrsh7th/cmp-nvim-lsp" },
  config = function()
    vim.lsp.config("*", {
      capabilities = require("cmp_nvim_lsp").default_capabilities(),
    })

    -- lspconfig ships no default cmd for elixirls; Homebrew/devShell both
    -- expose it as `elixir-ls`.
    vim.lsp.config("elixirls", { cmd = { "elixir-ls" } })

    vim.lsp.enable({
      "nil_ls", -- Nix
      "lua_ls", -- Lua (this config)
      "bashls", -- shell scripts
      "pyright", -- Python
      "rust_analyzer", -- Rust
      "zls", -- Zig
      "ts_ls", -- TypeScript/JavaScript
      "metals", -- Scala 3
      "elixirls", -- Elixir
      "ocamllsp", -- OCaml
    })

    -- Buffer-local maps on attach, same set as `plugins.lsp.keymaps` in
    -- nvim.nix. Buffer-local so the LSP `gd` overrides telescope's global
    -- tags `gd` only where a server is attached.
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(ev)
        local function map(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
        end
        map("K", vim.lsp.buf.hover, "Hover")
        map("gd", vim.lsp.buf.definition, "Go to definition")
        map("gD", vim.lsp.buf.declaration, "Go to declaration")
        map("gi", vim.lsp.buf.implementation, "Go to implementation")
        map("gt", vim.lsp.buf.type_definition, "Go to type definition")
        map("<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("<leader>rn", vim.lsp.buf.rename, "Rename")
        map("<leader>cf", vim.lsp.buf.format, "Format")
        map("[d", function()
          vim.diagnostic.jump({ count = -1, float = true })
        end, "Previous diagnostic")
        map("]d", function()
          vim.diagnostic.jump({ count = 1, float = true })
        end, "Next diagnostic")
        map("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
      end,
    })
  end,
}
