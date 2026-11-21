-- Rex config.
--
-- Rex's own cmd shortcuts (cmd+d split, cmd+t tab, cmd+1..9, cmd+k sessions,
-- alt+cmd+arrows focus, ...) are kept as they are; this file adds nothing on cmd.
--
-- Everything below sits behind one prefix, ctrl+a, and uses only ctrl and plain
-- keys: no cmd/super (Linux window managers take super) and no alt (the shell
-- uses it). The keys follow tmux and ~/.config/tmux/tmux.conf, so the same
-- fingers work in tmux on NixOS. This file is valid on a Linux Rex server too.

-- ctrl+a twice sends ctrl+a to the program (start of line in the shell).
rex.bind("ctrl+a>ctrl+a", "pane.send_key", { key = "ctrl+a" })

-- Panes
rex.bind("ctrl+a>shift+\\", "pane.split", { direction = "right" })  -- |
rex.bind("ctrl+a>-", "pane.split", { direction = "down" })
rex.bind("ctrl+a>h", "pane.focus", { direction = "left" })
rex.bind("ctrl+a>j", "pane.focus", { direction = "down" })
rex.bind("ctrl+a>k", "pane.focus", { direction = "up" })
rex.bind("ctrl+a>l", "pane.focus", { direction = "right" })
rex.bind("ctrl+a>;", "pane.focus_recent.in_tab")
rex.bind("ctrl+a>o", "pane.focus_next")
rex.bind("ctrl+a>z", "pane.zoom")
rex.bind("ctrl+a>x", "pane.close")
rex.bind("ctrl+a>space", "pane.new_floating")  -- your tmux popup on Space
rex.bind("ctrl+a>[", "pane.copy_mode.enter")

-- Tabs (tmux windows)
rex.bind("ctrl+a>c", "client.tab.new")
rex.bind("ctrl+a>n", "client.tab.next")
rex.bind("ctrl+a>p", "client.tab.previous")
rex.bind("ctrl+a>,", "client.tab.rename")

-- Sessions and navigation
rex.bind("ctrl+a>s", "session.switch")
rex.bind("ctrl+a>w", "pane.go_to")
rex.bind("ctrl+a>shift+;", "client.palette.toggle")  -- :
rex.bind("ctrl+a>shift+r", "client.config.reload")

-- Resize mode: ctrl+a then r, then h/j/k/l (shift for fine steps).
-- Enter or escape leaves; other keys do nothing while it is on.
rex.mode("resize", { exclusive = true })
rex.bind("ctrl+a>r", "client.mode.enter", { name = "resize" })
rex.bind("resize/enter", "client.mode.exit")
rex.bind("resize/escape", "client.mode.exit")
rex.bind("resize/h", "pane.resize", { amount = 5, direction = "left" })
rex.bind("resize/j", "pane.resize", { amount = 5, direction = "down" })
rex.bind("resize/k", "pane.resize", { amount = 5, direction = "up" })
rex.bind("resize/l", "pane.resize", { amount = 5, direction = "right" })
rex.bind("resize/shift+h", "pane.resize", { amount = 1, direction = "left" })
rex.bind("resize/shift+j", "pane.resize", { amount = 1, direction = "down" })
rex.bind("resize/shift+k", "pane.resize", { amount = 1, direction = "up" })
rex.bind("resize/shift+l", "pane.resize", { amount = 1, direction = "right" })

-- Add-ons installed outside dotfiles. On a fresh machine they may be missing,
-- so load each one on its own and say so, instead of failing the whole config.
local function load_addon(name, load)
  local ok, err = pcall(load)
  if not ok then print("init.lua: skipped " .. name .. ": " .. tostring(err)) end
end

-- rex-durable: command palette actions. rex_durable.lua is written next to
-- this file by github.com/fazxes/rex-durable's install.sh.
load_addon("rex-durable", function() require("rex_durable") end)

-- nurx: picker for `nurx` in nushell. Clone github.com/fdncred/nu-rex-integration
-- to ~/Developer/tools.
load_addon("nurx", function()
  dofile(os.getenv("HOME") .. "/Developer/tools/nu-rex-integration/nurx.lua")
end)
