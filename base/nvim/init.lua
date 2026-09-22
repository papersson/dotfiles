-- Entry point. Everything lives under lua/config (core) and lua/plugins (specs).
-- This tree is the Lua mirror of nixos-config/home/patrikpersson/nvim.nix;
-- when one changes, change the other.
require("config.lazy")
