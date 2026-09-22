-- Linter dispatch. linters_by_ft is empty on purpose; add entries when a
-- project needs one. Runs on every write, like nixvim's default autocmd.
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("lint").linters_by_ft = {}
    vim.api.nvim_create_autocmd("BufWritePost", {
      callback = function()
        require("lint").try_lint()
      end,
    })
  end,
}
