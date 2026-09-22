-- Mirrors the top-level `keymaps` list in nvim.nix. Plugin-internal maps that
-- call Lua functions (flash, telescope pickers, LSP) live next to their plugin.

local map = vim.keymap.set

-- Quick escape
map("i", "jj", "<Esc>", { noremap = true, silent = true })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Buffer navigation
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bd<cr>", { desc = "Delete buffer" })
map("n", "<leader>bD", "<cmd>bd!<cr>", { desc = "Force delete buffer" })

-- Quickfix navigation
map("n", "[q", "<cmd>cprev<cr>", { desc = "Previous quickfix" })
map("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix" })
map("n", "<leader>co", "<cmd>copen<cr>", { desc = "Open quickfix" })
map("n", "<leader>cc", "<cmd>cclose<cr>", { desc = "Close quickfix" })

-- Location list navigation
map("n", "[l", "<cmd>lprev<cr>", { desc = "Previous location" })
map("n", "]l", "<cmd>lnext<cr>", { desc = "Next location" })
map("n", "<leader>lo", "<cmd>lopen<cr>", { desc = "Open location list" })
map("n", "<leader>lc", "<cmd>lclose<cr>", { desc = "Close location list" })

-- Search and replace
map("n", "<leader>rw", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word under cursor" })
map("v", "<leader>r", [[:s/]], { desc = "Replace in selection" })

-- Keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up" })
map("n", "n", "nzzzv", { desc = "Next search result" })
map("n", "N", "Nzzzv", { desc = "Previous search result" })

-- Better indenting (stay in visual mode)
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Move lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Jump list
map("n", "<leader>jo", "<C-o>", { desc = "Jump back" })
map("n", "<leader>ji", "<C-i>", { desc = "Jump forward" })

-- Marks
map("n", "<leader>ml", "<cmd>marks<cr>", { desc = "List marks" })
map("n", "<leader>md", "<cmd>delmarks a-z<cr>", { desc = "Delete all marks" })

-- Markdown preview (glow.nvim renders the buffer in a floating window)
map("n", "<leader>mp", "<cmd>Glow<cr>", { desc = "Markdown preview (glow)" })

-- Tags (requires ctags)
map("n", "<leader>tj", "<C-]>", { desc = "Jump to tag" })
map("n", "<leader>tb", "<C-t>", { desc = "Jump back from tag" })
map("n", "<leader>ts", "g]", { desc = "List matching tags" })

-- Macro helpers
map("n", "Q", "@q", { desc = "Play macro q" })
map("v", "Q", ":norm @q<cr>", { desc = "Play macro q on selection" })

-- Clear search highlighting
map("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- System clipboard
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to clipboard" })
map({ "n", "v" }, "<leader>p", [["+p]], { desc = "Paste from clipboard" })
map({ "n", "v" }, "<leader>P", [["+P]], { desc = "Paste before from clipboard" })

-- Save / quit
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
map("n", "<leader>W", "<cmd>wa<cr>", { desc = "Save all files" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa<cr>", { desc = "Quit all" })

-- Split management
map("n", "<leader>sv", "<C-w>v", { desc = "Split vertical" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split horizontal" })
map("n", "<leader>se", "<C-w>=", { desc = "Equal splits" })
map("n", "<leader>sx", "<cmd>close<cr>", { desc = "Close split" })

-- Neo-tree
map("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Toggle Neo-tree" })
map("n", "<leader>E", "<cmd>Neotree reveal<cr>", { desc = "Reveal file in Neo-tree" })
map("n", "-", "<cmd>Neotree float<cr>", { desc = "Neo-tree float" })

-- Fugitive
map("n", "<leader>gg", "<cmd>Git<cr>", { desc = "Git status" })
map("n", "<leader>gb", "<cmd>Git blame<cr>", { desc = "Git blame" })
map("n", "<leader>gd", "<cmd>Gdiff<cr>", { desc = "Git diff" })
map("n", "<leader>gl", "<cmd>Git log<cr>", { desc = "Git log" })
map("n", "<leader>gp", "<cmd>Git push<cr>", { desc = "Git push" })
map("n", "<leader>gP", "<cmd>Git pull<cr>", { desc = "Git pull" })
