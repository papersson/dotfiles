# Set up my agent toolchain on this machine

Paste this whole file into Claude Code on the machine to set up. Fetch it with:
`curl -fsSL https://raw.githubusercontent.com/papersson/dotfiles/main/setup/agent-toolchain.md`

---

You're setting up my agent toolchain on this machine, most likely my **work MacBook**. On my
personal Mac it's already set up and proven to work. You weren't there, so everything you need is
below. Read it all before you change anything.

## What to end up with

1. **atuin 18.25 or newer**, recording shell history and every Claude Code and Codex thread on
   this machine, with its daemon running from login and the threads already on this machine
   imported.
2. **atuin's MCP server** registered for Claude Code (and for Codex, if Codex is installed), so
   agents can search past threads.
3. **A Rex action, "Resume Agent Thread"**, that opens atuin's thread picker in a new Rex tab.
   Bind it to `ctrl+a` then `t` only if this machine's Rex config already uses a `ctrl+a` prefix
   (see step 5).
4. **A short "Agent toolchain" section in `~/.claude/CLAUDE.md`**, covering only the tools that
   are actually installed here.
5. **worklog 0.5.0** (the papershop plugin), which also reads atuin threads when atuin is on
   PATH.

Rex is already installed. Install everything else yourself as described below.

**Sync stays off.** atuin can sync threads to a server, but threads hold tool output, and on a
work laptop that means my employer's code and data. My own sync server runs on my personal
home server and is reachable only over my personal tailnet. Don't log in to any sync server,
don't join a tailnet, and don't copy keys or passwords from anywhere. Step 8 says what to tell me
about sync.

## How to work

- **Detect first, then change, then prove.** Every step starts by checking whether it's already
  done, and skips if so. Running this whole prompt a second time must change nothing. In
  particular: no second MCP entry, no second Rex binding, no second CLAUDE.md section.
- **Back up any existing file before you edit it, or before a tool you run edits it.** Copy it to
  `~/.agent-toolchain-backup/<date>/`, keeping its path, and list the backups in the final report.
  Do this once, up front (step 0), for every file this prompt or its tools may touch:
  `~/.zshrc`, `~/.zprofile`, `~/.bashrc`, `~/.bash_profile`, `~/.profile`,
  `~/.config/fish/config.fish`, atuin's config, `~/.claude.json`, `~/.claude/settings.json`,
  `~/.claude/CLAUDE.md`, `~/.codex/config.toml`, `~/.config/rex/init.lua`, and nushell's
  `config.nu`. Copy only the ones that exist. `~/.claude.json` holds login tokens, so make the
  backup directory `chmod 700`.
- **Your Bash calls don't keep shell variables.** Where this prompt says `ATUIN` or `AGENTS`,
  substitute the literal value you found. `ATUIN` is the absolute path of the atuin binary from
  step 1. Every atuin command in steps 2 to 7 runs that path, not a bare `atuin`, because an old
  atuin earlier on PATH would otherwise run instead.
- **Respect policy.** If an MDM or managed Claude Code setting blocks something, skip that part,
  say so in the report, and don't work around it.
- **Stop and ask me only:** before anything that needs admin rights (sudo); when a managed policy
  blocks a step; and if you're not in a GUI login session (step 0). Do everything else without
  asking.
- **A dotfiles repo may manage some of these files.** If `~/.claude/CLAUDE.md`,
  `~/.config/atuin/config.toml` or `~/.config/rex/init.lua` is a symlink into a git repo, edit the
  file in the repo (writing through the symlink is fine). Then commit just those files, staging
  each one by explicit path, with a short message. Don't push.

## Step 0: survey and back up (no other changes yet)

Make the backups listed under "How to work". Then report a short table covering:

- macOS version and CPU (`sw_vers`, `uname -m`).
- Your login shell (`dscl /Search -read "/Users/$USER" UserShell`, falling back to `$SHELL`; on a
  directory-bound corporate Mac the user isn't in the local node), and whether zsh, bash and
  nushell (`nu`) are installed. A shell is "in use" if it's the login shell or its rc file
  (`~/.zshrc`, `~/.bashrc`) has content beyond comments.
- Whether you're in a GUI login session: `launchctl print gui/$(id -u) >/dev/null` succeeds. Over
  SSH it fails, and step 3 can't load a LaunchAgent; if so, stop and ask me to run this prompt
  from a terminal on the Mac itself.
- Homebrew: present (`command -v brew`), and whether its prefix is writable by you.
- Any atuin already installed: its path and version. Run `which -a atuin`, because an old atuin
  earlier on PATH would shadow a new one.
- Claude Code (`claude --version`), Codex (`command -v codex`), agy (`command -v agy`),
  Rex (`rex --version`), and uv (`command -v uv`).
- Managed Claude Code policy: does `/Library/Application Support/ClaudeCode/managed-settings.json`
  exist? Report any keys in it that could block this setup: `allowedMcpServers`,
  `deniedMcpServers`, `strictKnownMarketplaces` (may block the papershop marketplace in step 6),
  `allowManagedHooksOnly` (blocks worklog's SessionStart hook), and anything else about plugins,
  hooks or MCP. Policy can also arrive as an MDM profile: check
  `defaults read com.anthropic.claudecode 2>/dev/null` and `profiles show -type configuration 2>/dev/null | grep -i -E 'claude|anthropic|background'`.
- Whether MDM manages login items and background tasks (the same `profiles` output; look for
  "Background" or "ServiceManagement"). A blocked LaunchAgent shows up in step 3.
- Whether `~/.claude/CLAUDE.md`, `~/.config/atuin/config.toml` and `~/.config/rex/init.lua`
  exist, and whether each is a symlink (`readlink`).
- Proxy variables (`HTTPS_PROXY`, `https_proxy`): say set or unset; never print their values.

Write down the agent list for later: `claude-code`, plus `codex` if Codex is installed. Call it
`AGENTS`, for example `claude-code,codex`.

## Step 1: install atuin 18.25+

- If atuin ≥ 18.25 is already first on PATH, skip this step.
- If Homebrew is present and writable, run `brew install atuin`, or `brew upgrade atuin` if it's
  already installed from brew.
- If there's no usable Homebrew, use atuin's release installer, which installs into
  `~/.atuin/bin`, adds that directory to PATH in your shell rc files (that's why step 0 backed
  them up), and needs no admin rights:
  `curl --proto '=https' --tlsv1.2 -LsSf https://github.com/atuinsh/atuin/releases/latest/download/atuin-installer.sh | sh`
  Don't use the `setup.atuin.sh` one-liner: depending on its version, it also runs atuin's
  interactive setup and installs agent hooks, which I don't want.
- Then find the new binary's absolute path: `$(brew --prefix)/bin/atuin` for Homebrew
  (`/opt/homebrew` on Apple Silicon, `/usr/local` on Intel), or `~/.atuin/bin/atuin`. Run it with
  `--version` and check that it says 18.25 or newer. That absolute path is `ATUIN` from here on.
  If `which -a atuin` still lists an older atuin first, report where it is; don't delete it
  without asking.

## Step 2: configure atuin with its own setup

**Already done?** Skip the setup command below if all of these hold:

- atuin's config (`ATUIN info` shows its path) has `[threads] enabled = true` and
  `[daemon] enabled = true`;
- `claude mcp get atuin` succeeds;
- if Codex is installed, `~/.codex/config.toml` has `[mcp_servers.atuin]`;
- the rc file of each shell in use contains `atuin init`.

Running setup again would rewrite these files for no gain. When Codex adds the MCP entry, it
rewrites its whole config file (step 0 backed it up). Otherwise run, with `ATUIN` and `AGENTS`
written out:

```sh
ATUIN setup --only --threads --daemon --mcp --agents AGENTS \
  --shell-history --shells zsh --ctrl-r --no-up-arrow
```

- Use `--shells` for this machine's shells (zsh, and bash if it's in use). setup doesn't support
  nushell; step 2b covers that.
- I want ctrl+r to open atuin's search, while the up arrow keeps the shell's own history.
- This command imports the shell history and agent threads already on this machine. That can take
  a minute or two.
- Here's what it should change, so you can check that it did:
  - In atuin's config file: `search_mode = "daemon-fuzzy"`, `bind_up_arrow = false`, `[daemon]`
    with `enabled = true` and `autostart = true`, and `[threads]` with `enabled = true`. Find the
    file with `ATUIN info` (the "client config" line). On a machine with no atuin config yet,
    setup creates `~/.atuin/config.toml`, not `~/.config/atuin/config.toml`.
  - An `atuin` MCP entry in `~/.claude.json`, and under `[mcp_servers.atuin]` in
    `~/.codex/config.toml` if Codex is installed.
  - A shell hook (`eval "$(atuin init zsh ...)"`) in the shell rc, if one wasn't there already.
- It installs **no** agent hooks: the daemon captures threads by reading the agents' transcript
  files itself. If `~/.claude/settings.json` gained an atuin hook, report it.
- If the config was a symlink, it must still be one afterwards; check with `readlink`.
- If the managed policy blocked the MCP part, report it and continue.
- Then import explicitly, so the threads are certainly there. Run
  `ATUIN threads import --harness claude-code`, and also `ATUIN threads import --harness codex`
  if Codex is installed. Each prints `imported N … skipped M`. A second run imports 0 and changes
  nothing.
- `ATUIN mcp` must be the command registered for both agents. If setup registered a different
  atuin (an older one first on PATH), fix the entry to point at `ATUIN`.

### Step 2b: nushell (only if nu is installed and has a config)

setup doesn't hook nushell. Write the output of `ATUIN init nu --disable-up-arrow` to
`~/.config/nushell/atuin.nu` (use the autoload directory instead if this config uses one). Source
it from `config.nu` if it isn't sourced already. Then start a new nushell
(`nu -c 'print ok'` with the normal config) and check that it loads without errors. Regenerate
this file whenever atuin is upgraded; a nushell upgrade broke it once.

## Step 3: keep the daemon up from login (launchd)

`daemon.autostart` only starts the daemon when an atuin command runs in a shell, so threads from
the Claude and ChatGPT desktop apps would go unrecorded until I next opened a terminal. A launchd
agent fixes that. Write `~/Library/LaunchAgents/sh.atuin.daemon.plist`, with `ATUIN_PATH`
replaced by the absolute path from step 1. Write a real file, not a symlink: launchd can skip
symlinked plists.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>sh.atuin.daemon</string>
  <key>ProgramArguments</key>
  <array>
    <string>ATUIN_PATH</string>
    <string>daemon</string>
    <string>start</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <dict>
    <key>SuccessfulExit</key>
    <false/>
  </dict>
  <key>ThrottleInterval</key>
  <integer>30</integer>
  <key>ProcessType</key>
  <string>Background</string>
  <key>StandardOutPath</key>
  <string>/tmp/atuin-daemon.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/atuin-daemon.log</string>
</dict>
</plist>
```

- Run `plutil -lint` on it.
- **Already done?** If the plist on disk already says exactly this (same `ATUIN`) and
  `launchctl print gui/$(id -u)/sh.atuin.daemon` shows `state = running`, leave it alone and go to
  the proof.
- Otherwise:
  1. Unload any old copy: `launchctl bootout gui/$(id -u)/sh.atuin.daemon 2>/dev/null`. Then wait
     until `launchctl print gui/$(id -u)/sh.atuin.daemon` fails (poll up to 10 s). A bootstrap
     sent too soon fails with `5: Input/output error`.
  2. If a daemon is running outside launchd (`ATUIN daemon status` shows one), stop it with
     `ATUIN daemon stop`.
  3. Load the agent: `launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/sh.atuin.daemon.plist`.
  4. If it fails, or the job never reaches `running`, report the error. MDM may block background
     items; that counts as policy, so don't work around it. Without the agent, the daemon still
     starts from the shell hook (`daemon.autostart`), so capture works whenever a terminal is
     open. Say that in the report.
- **Proof** (run no other atuin command while this runs; any atuin command can start its own
  daemon through `autostart` and fake a pass):
  1. Read the launchd PID: the `pid =` line of `launchctl print gui/$(id -u)/sh.atuin.daemon`.
  2. `kill -9` it, then poll that same `launchctl print` (not atuin) for up to 40 s, until it
     shows a new `pid` and `state = running`.
  3. Only then, `ATUIN daemon status` must report that same new PID.
- On Linux, use a systemd user service instead: `ExecStart=<atuin> daemon start`,
  `Restart=on-failure`, `WantedBy=default.target`, enabled with
  `systemctl --user enable --now`.

## Step 4: prove that capture and MCP work

- In a new empty temp directory, run
  `claude -p "Reply with exactly: atuin-probe-<random 4 digits>" --model haiku`. Within 15
  seconds, `ATUIN threads search atuin-probe-<digits> --style plain` must find it, without any
  import.
- `claude mcp list` must show `atuin: … ✔ Connected`, unless policy blocked it in step 2.
- If Codex is installed, `codex mcp list` (or the `[mcp_servers.atuin]` table in
  `~/.codex/config.toml`) must show atuin.

## Step 5: the Rex action

The Rex server runs with a minimal PATH that has no Homebrew in it. So the action types
`atuin resume; exit` into a normal login shell, which has the full environment, rather than
running atuin as the new pane's command. That also gives the agent that atuin starts the right
environment.

0. Run `rex skill status`. If Rex's skill or session hook is missing for Claude Code (or for
   Codex, if it's installed), run `rex skill setup`. It installs both, and they teach agents
   how to drive Rex.
1. Rex loads `~/.config/rex/init.lua`, and `require` looks in `~/.config/rex/`, the directory of
   the path Rex loads, not of a symlink's target. So the action must be reachable as
   `~/.config/rex/atuin_resume.lua`.
   - If `init.lua` is a symlink into a dotfiles repo, write the file next to the link's target in
     the repo, and make `~/.config/rex/atuin_resume.lua` a symlink to it.
   - Otherwise write it straight to `~/.config/rex/atuin_resume.lua`.

   Either way, step 4 below loads it through `~/.config/rex/atuin_resume.lua`. Here's the file:

   ```lua
   -- Agent threads: opens atuin's picker over every captured Claude Code and
   -- Codex thread in a new tab. Choosing one resumes it there (atuin cds to the
   -- thread's directory first); esc closes the tab. The picker is typed into a
   -- login shell rather than run as the block's command: the Rex server's PATH
   -- has no Homebrew, and the agent atuin starts needs the shell's full
   -- environment anyway.
   rex.action{
     name = "atuin_resume",
     title = "Resume Agent Thread",
     description = "Pick a captured Claude Code or Codex thread with atuin and resume it in a new tab",
     category = "Agents",
     keywords = "atuin threads claude codex resume fork",
     run = function(ctx)
       local result, err = rex.session.new_window{
         session_id = ctx.session_id,
         window_label = "threads",
         layout = rex.layout.block{
           flavor = "com.superlogical.terminal.shell",
           options = { initial_input = "atuin resume; exit\n" },
         },
       }
       if err then error(err) end
       return result
     end,
   }
   ```

2. Load it from `~/.config/rex/init.lua` with a `require("atuin_resume")` line, unless one is
   already there. If there's no `init.lua`, create it with just that line. That's safe: `init.lua`
   only adds to Rex's built-in shortcuts and doesn't replace them.
3. **The key binding.** Look at the existing `init.lua` first.
   - If it already binds keys behind a `ctrl+a>` prefix (lines like `rex.bind("ctrl+a>…`), and
     nothing binds `"ctrl+a>t"` yet (grep for it), add
     `rex.bind("ctrl+a>t", "atuin_resume")` after the `require` line.
   - If it doesn't use a `ctrl+a` prefix, **bind no key.** Binding a `ctrl+a>` sequence would
     take `ctrl+a` away from the shell, where it moves to the start of the line. The action is
     still in Rex's command palette as "Resume Agent Thread". Say so in the report, and suggest a
     free key I could add.
4. Try it before reloading: inside a Rex pane (`REX_SESSION` is set),
   `rex do -s "$REX_SESSION" ~/.config/rex/atuin_resume.lua --action atuin_resume --json` must
   return JSON with a `window_id` and `block_ids`. Use `block_ids[0]` as `<block>`. Within 3
   seconds, `rex capture -s "$REX_SESSION" -b <block> --trim` must show `Atuin v` and the thread
   list.
   Then press escape in that pane (`rex send-key -s "$REX_SESSION" -b <block> escape`), and the
   tab closes itself. If it's still open after 3 seconds, press escape once more: right after an
   upgrade, atuin may show a one-time "what's new" note that takes the first keypress.
   - If you're not running inside Rex, skip this test and tell me to try the action myself.
5. Run `rex config reload`. Then `rex actions | grep atuin_resume` must list it.

## Step 6: worklog 0.5.0 or newer

- If the plugin is installed (`claude plugin list` shows `worklog@papershop`), update it:
  `claude plugin marketplace update papershop`, then `claude plugin update worklog@papershop`.
- If it isn't installed:
  `claude plugin marketplace add papersson/papershop`, then
  `claude plugin install worklog@papershop`.
- If policy blocks the marketplace or the plugin, skip this step and leave worklog out of the
  CLAUDE.md section.
- Find the installed version (`claude plugin list` shows it; call it `V`, 0.5.0 or newer). Its
  files are in `~/.claude/plugins/cache/papershop/worklog/V/`.
- The `worklog` command is a shim at `~/.local/bin/worklog`, and the plugin's SessionStart hook
  rewrites it only when the next session starts. Rewrite it now:
  `CLAUDE_PLUGIN_ROOT=~/.claude/plugins/cache/papershop/worklog/V bash ~/.claude/plugins/cache/papershop/worklog/V/bootstrap.sh ensure`.
  This also installs uv if it's missing, and uv's installer may add itself to the rc files, which
  step 0 backed up. Afterwards, `tail -1 ~/.local/bin/worklog` must name version `V`.
- If policy blocks hooks (`allowManagedHooksOnly`), the shim won't be refreshed when the plugin
  updates later. Say so in the report.
- Run `~/.local/bin/worklog index` by its full path, in case `~/.local/bin` isn't on PATH; if it
  isn't, say so in the report. The first run can take several minutes on a long history. It must
  end with `atuin=<N> thread(s)`: N > 0 if Codex threads exist, and `atuin=0` is fine with only
  Claude Code, whose local transcripts are read directly.

## Step 7: the CLAUDE.md section (last, so it lists only what works)

Add the section between markers, so a second run can find it and replace it rather than add a
second copy. If `~/.claude/CLAUDE.md` holds the employer's or anyone else's content, append the
section at the end and change nothing else.

```markdown
<!-- agent-toolchain:start -->
## Agent toolchain

- **Rex** is the terminal.REX_GUIDE "Resume Agent Thread" in its command palette (KEY_LINE) opens atuin's thread picker in a new tab.
- **atuin** holds shell history and every AGENT_NAMES thread on this machine: those whose transcripts were still here at setup, and every one since. DAEMON_LINE Nothing syncs off this machine.
  - To find earlier work by any agent, use the atuin MCP tools (`atuin_threads_search`, then `atuin_threads_read`) or `atuin threads search <words> [--harness codex] --style json` instead of grepping `~/.claude/projects`. Each result's `session.atuin_id` is the thread id; its last 8 characters are enough.
  - To hand a thread to another agent: `atuin resume <id> --in <agent> --print`, with `<agent>` one of AGENT_VALUES. It writes the thread out as a new session of that agent and prints the command that resumes it. `--fork` instead makes a new session of the thread's own agent with the same history.
WORKLOG_LINE
<!-- agent-toolchain:end -->
```

Fill in the placeholders:

- `KEY_LINE`: "or ctrl+a then t" if you bound the key, otherwise remove it, including the
  brackets.
- `AGENT_NAMES`: "Claude Code and Codex", or "Claude Code" if Codex isn't installed.
- `DAEMON_LINE`: "The `sh.atuin.daemon` launchd agent keeps capturing from login." if step 3's
  agent runs; otherwise "Capture runs while a terminal has started the daemon.".
- `AGENT_VALUES`: the installed agents, written as `claude-code`, `codex`.
- `REX_GUIDE`: " Its `rex` skill and session hook say how to drive it." if `rex skill status`
  shows them installed; otherwise " `rex __internal skill` prints its guide.".
- `WORKLOG_LINE`: "- **worklog** (skill) turns that history into reports, runbooks and CLAUDE.md
  rules." if step 6 worked; otherwise remove the line.

If Codex or agy is installed, add a bullet with one working one-shot command for each, for a
second opinion from another model family. Run each command once to prove it works:

- Codex: `echo "<prompt>" | codex exec --skip-git-repo-check --ephemeral -s read-only -o out.md -`
- agy: `agy -p "<prompt>" --model <model> --print-timeout 0`, where `<model>` is the first model
  in `agy models` whose name ends in `-high`, or the first one listed if none does.

Leave out anything that isn't installed.

**Cold-read test:** give a fresh subagent only the rendered `~/.claude/CLAUDE.md`, and ask it: "How
do I find what I did in Codex last week, and hand that thread to Claude Code?" (If Codex isn't
installed, ask about "last week's Claude Code session about X".) It must answer with
`atuin threads search … --harness codex` or the MCP tools, and with
`atuin resume <id> --in claude-code`. If it guesses anything, fix the section and ask again.

## Step 8: report (one screen)

1. **A table:** each piece, its version, and the proof you ran (command → result).
2. **What you skipped,** and why: policy, not installed, no `ctrl+a` prefix.
3. **What changed on disk:** the files you created and the files you edited, with their backup
   paths, plus any dotfiles commits.
4. **Sync, in one paragraph and without choosing for me.** On this machine, capture stays local.
   The options for later are:
   - stay local;
   - a separate account on my personal atuin server (which needs this machine on my personal
     tailnet; my employer's policy decides whether that's allowed);
   - a sync server my employer approves.

Then run the whole prompt's detection once more and confirm that a second run would change
nothing.
