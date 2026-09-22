-- Formatter dispatch. Formatters resolve from PATH: stylua/nixfmt/prettier/
-- ruff via Homebrew (Brewfile), rustfmt/zig from their toolchains, `mix`
-- from the project's devShell.
return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      nix = { "nixfmt" },
      lua = { "stylua" },
      python = { "ruff_format" },
      rust = { "rustfmt" },
      zig = { "zigfmt" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      -- `mix format` reads the project's .formatter.exs and runs from the
      -- mix.exs root, so it formats with the project's own rules.
      elixir = { "mix" },
    },
  },
}
