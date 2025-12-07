return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "python",
          "lua",
          "javascript",
          "typescript",
          "yaml",
          "json",
          "rust",
          "go",
          "c",
          "cpp",
          "toml",
          "markdown",
          "markdown_inline",
          "bash",
          "regex",
          "vim",
          "vimdoc",
          "html",
          "css",
        },
        
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        
        indent = {
          enable = true,
        },
        
        -- Incremental selection for expanding regions
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
        
        -- Text objects for navigation and selection
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["al"] = "@loop.outer",
              ["il"] = "@loop.inner",
              ["ab"] = "@block.outer",
              ["ib"] = "@block.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
              ["as"] = "@statement.outer",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = "@class.outer",
              ["]o"] = "@loop.outer",
              ["]s"] = "@statement.outer",
              ["]a"] = "@parameter.inner",
              ["]b"] = "@block.outer",
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer",
              ["]O"] = "@loop.outer",
              ["]S"] = "@statement.outer",
              ["]A"] = "@parameter.outer",
              ["]B"] = "@block.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
              ["[o"] = "@loop.outer",
              ["[s"] = "@statement.outer",
              ["[a"] = "@parameter.inner",
              ["[b"] = "@block.outer",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer",
              ["[O"] = "@loop.outer",
              ["[S"] = "@statement.outer",
              ["[A"] = "@parameter.outer",
              ["[B"] = "@block.outer",
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ["<leader>a"] = "@parameter.inner",
            },
            swap_previous = {
              ["<leader>A"] = "@parameter.inner",
            },
          },
        },
      })
    end,
  },
}
