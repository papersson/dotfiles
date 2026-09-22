# CLAUDE.md - Core Universal Context
- Use `agent-browser --help` to verify any visual work you are doing.

## General Agentic Patterns

### Context Retrieval
**The most critical step** - gathering sufficient context before acting determines success or failure.

#### Search Strategy
- Start broad, then narrow: `rg "pattern"` → `rg -A5 -B5 "pattern"` → read full files
- Use iterative refinement: each search informs the next query
- Combine multiple search tools: filesystem structure (`find`), content (`rg`), code structure (`ast-grep`)
- When a file is clearly relevant, read all of it rather than excerpts
- Delegate broad searches (many files, unclear scope, architecture questions) to a search subagent that returns a structured summary of key files and patterns

### Context Engineering

Load what the task needs, not what might be useful. Search to find the right files, then read those. Delegate noisy exploration (wide greps, dependency traces, verbose output) to a subagent and keep its summary. Prefer diffs to whole-file rewrites, and summarize test and lint output rather than pasting raw logs. Keep this file for universal preferences and put domain knowledge in skills.

## Shell Preference: Nushell

**Strongly prefer Nushell over Bash** when running shell commands. This helps me learn Nushell idioms.

**Nushell advantages to leverage:**
- Structured data: `ls | where size > 1mb | sort-by modified`
- Built-in parsing: `open file.json | get key.nested`
- Pipelines with tables: `ps | where cpu > 10`
- Type-aware: `ls | get name` returns list of strings

**Prefer Nushell equivalents:**
| Bash | Nushell |
|------|---------|
| `cat file.json \| jq '.key'` | `open file.json \| get key` |
| `ls -la \| grep pattern` | `ls -a \| where name =~ pattern` |
| `find . -name "*.rs"` | `glob **/*.rs` |
| `wc -l file` | `open file \| lines \| length` |
| `head -n 10 file` | `open file \| lines \| first 10` |
| `echo $VAR` | `$env.VAR` |

**When Bash is acceptable:** Complex shell scripts, tools that require POSIX, or when Nushell syntax is unclear.

**Leverage CLI structured output:** Many modern CLIs support `--json`. Pipe to Nu instead of jq:
```nu
gh api user | from json | select login name          # GitHub CLI
gh pr list --json number,title,state | from json     # PR list
kubectl get pods -o json | from json | get items     # Kubernetes
docker ps --format '{{json .}}' | lines | each { from json }
```

Key tools with JSON output: `gh`, `kubectl`, `docker`, `aws`, `gcloud`, `npm`, `cargo --message-format=json`, `brew --json=v2`

## Generic Coding Tasks

### Code Search Hierarchy
**PREFER ast-grep for structural searches:**
```bash
# BEST: Finding actual function calls (not comments/strings)
ast-grep --pattern 'getUserById($$$)' 

# GOOD: Quick text search
rg "getUserById"

# AVOID: Will match comments/strings incorrectly
grep -r "getUserById"
```

**When to use each:**
- `ast-grep`: Finding/refactoring code patterns, understanding code structure
- `ripgrep`: Quick text search, log analysis, finding TODOs
- `find`: Locating files by name/type/date
- `grep`: Only when others unavailable

### Establishing Feedback Loops
**Never assume code works - always verify:**

1. **Testing** (universal)
   - Run existing tests after changes
   - Write tests for new functionality
   - Use test failures to guide fixes

2. **Type Checking** (when available)
   - TypeScript: `tsc --noEmit`
   - Python: `mypy`, `pyright`
   - Rust: `cargo check`

3. **Linting/Formatting**
   - Catch issues early
   - Maintain consistency
   - Often reveals logical errors

4. **Incremental Validation**
   - Test smallest unit first
   - Build up to integration
   - Verify each layer works

**Project-specific verification should be documented in local CLAUDE.md**

## Core Principles

### Communication
- Be direct and concise
- Lead with most important info
- Explicitly state uncertainty
- No unnecessary preambles
- Avoid negative parallelisms ("not just X, but Y"). ✗ "You're not just adding features, you're invalidating theory" ✓ "You're adding features and invalidating theory"

#### Avoid AI Writing Patterns
- **No empty emphasis**: Skip "plays a vital/crucial role", "stands as a testament", "watershed moment"
- **No promotional language**: Avoid "breathtaking", "nestled", "captivates", "rich heritage"
- **No excessive connectives**: Vary transitions. Not every paragraph needs "Moreover", "Furthermore", "Additionally"
- **No collaborative servility**: Never write "I hope this helps", "Certainly!", "Let me explain"
- **No meta-disclaimers**: Don't mention being an AI or knowledge cutoffs. Do say plainly when something could not be done or verified
- **Plain formatting**: Use bold/italic sparingly for actual emphasis, not decoration

### Error Handling
- Fail fast with clear messages
- Check preconditions
- Never swallow errors silently

## Python Development

### UV Best Practices

**Workflow:**
```bash
uv init --package my-tool     # Creates structure + venv
uv sync                       # Install deps + project
uv add package                # Add dependency
uv add --dev pytest           # Add dev dependency
uv run my-cli --help          # Verify entry point works
```

Commit `uv.lock` and `.python-version` to git.

**Structure:** keep the src layout `uv init --package` generates: `src/my_package/__init__.py`, no `src/__init__.py`, and no `packages = ["src"]` override. Hatch finds `src/my_package` by itself, and `packages = ["src"]` ships a top-level package named `src`, so `my_package` can't be imported and the entry point fails.

```toml
[project.scripts]
my-cli = "my_package.cli.main:function"   # import path : function
```

**Avoid:**
```python
sys.path.insert(0, "src")  # ❌ Breaks after install
```

```toml
[project.scripts]
cli = "cli:main"  # ❌ Root scripts don't work after install
```

**Common Errors:**

| Error | Fix |
|-------|-----|
| `Unable to determine files to ship` | The package dir name must match the project name; otherwise set `packages = ["src/my_package"]` |
| `No module named 'my_package'` | Check `src/my_package/__init__.py` exists and no `packages = ["src"]` override is set |
| `command not found` | Check entry point uses `pkg.module:func` format, verify with `--help` |

## Verification

**Verify before you trust.** For any agentic work, define the check before doing the work: write the prompt, command, or test that would prove the task is done, and treat passing it as the goal. The work is finished when the check passes, not when you stop. Climb the signal hierarchy and use the highest rung with ground truth: a deterministic signal (tests, types, lint, build, a tool you can drive) over a domain verification skill, over an adversarial rubric, over asking a human. Prefer a tool call to an LLM judge whenever ground truth exists. Be honest when something is only softly verifiable, like taste: use a rubric, never fake a green check. A backgrounded agent that hits a decision it cannot make from the brief returns the decision to the human rather than guessing.

## Shared working trees

Multiple agents — and the user — may be working in the same repository at the same time, so the working tree can shift under you mid-task.

- **Commit only what you changed.** Stage by explicit path (`git add path/to/file`); never `git add -A` or `git add .` — that sweeps up another agent's or the user's in-progress work.
- **Re-check `git status` and `git diff` right before committing** — the tree may differ from when you started.
- **Don't revert, reformat, or "tidy" changes you didn't make** — assume they're intentional, even if entangled in a file you also touched.
- **Commit your own work once a logical unit is done** rather than leaving it piled in the working tree for someone else to untangle. Commit, don't push — leave pushing to the user unless a repo's own CLAUDE.md says otherwise.

## CLAUDE.md hierarchy

CLAUDE.md files cascade by filesystem location. `~/.claude/CLAUDE.md` (this file) loads in every session; a project's root `CLAUDE.md` loads when cwd is inside that project; a subdirectory's `CLAUDE.md` loads when cwd is under it. Children **supplement**, not replace, parents — everything compounds into the same context.

Use this deliberately. Place each fact at the **narrowest scope where it's still true**:

- Universal preferences, machine-level workflow → global (this file).
- Repo layout, repo-wide conventions, repo-specific file locations → project root CLAUDE.md.
- Subsystem-specific rules (a `secrets/CLAUDE.md` warning about encryption discipline, a `modules/CLAUDE.md` codifying module patterns, a `migrations/CLAUDE.md` for schema-change conventions) → subdirectory CLAUDE.md.

Avoid two failure modes:
- **Duplication**: a fact in a parent is already loaded; restating it in a child creates drift risk when one copy gets updated and the other doesn't.
- **Scope bleed**: a fact in a child is *not* loaded outside that subtree — cross-cutting rules placed there go silent the moment you `cd` away.

When introducing a new rule, ask: "from which directory will future-me be working when this rule applies?" That directory's CLAUDE.md is where it goes. If a project grows a subsystem with its own non-obvious conventions, that's a signal to create a CLAUDE.md inside it rather than expand the root file.

## Drafts and ideas

Undecided design notes — ideas being weighed, proposals not yet adopted — live in `~/drafts/`, one file per idea. This is deliberately *outside* the CLAUDE.md scope hierarchy above: that hierarchy is for decided rules that should load as context within a scope, whereas a draft is not-yet-context, and often not yet sure which scope it belongs to. Keeping drafts out of project trees also stops an agent from reading a maybe as guidance.

When a draft is adopted or rejected, fold the outcome into the CLAUDE.md at the right scope and delete the draft. `~/drafts/` holds only live, undecided thinking.
