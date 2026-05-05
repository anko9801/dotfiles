# autoimprove

Autonomous improvement loop for dotfiles, inspired by [karpathy/autoresearch](https://github.com/karpathy/autoresearch).

## Setup

To set up a new improvement session, work with the user to:

1. **Agree on a run tag**: propose a tag based on today's date (e.g. `mar29`). The branch `autoimprove/<tag>` must not already exist.
2. **Create the branch**: `git checkout -b autoimprove/<tag>` from current master.
3. **Read the in-scope files**: Read these files for full context:
   - `config.nix` — host definitions, module sets, baseModules list
   - `system/hosts.nix` — how modules are resolved and composed
   - `docs/tool-selection.md` — adopted/rejected tools and evaluation criteria
   - `docs/ergonomics.md` — the unified philosophy (reduce human burden)
   - `system/dev-tools.nix` — linters, formatters, pre-commit hooks
4. **Scan existing modules**: List all files in `tools/`, `shell/`, `terminal/`, `editor/`, `dev/`, `ai/`, `security/` to know what's already configured.
5. **Record baseline metrics**: Run the evaluation commands and record the initial statix/deadnix counts. This is your baseline.
6. **Initialize results.tsv**: Create `results.tsv` with just the header row.
7. **Confirm and go**: Confirm setup looks good.

Once you get confirmation, kick off the loop.

## Experimentation

Each experiment is: discover a tool or config improvement, apply it, and check.

**What you CAN do:**
- Create new module files (e.g. `tools/hyperfine.nix`)
- Modify existing module files to improve configuration
- Add new modules to `baseModules` or `moduleSets` in `config.nix`
- Add new packages via `programs.*` (preferred) or `home.packages`
- Search the web for dev environment articles, tool comparisons, dotfiles repos
- Read tool documentation to configure properly

**What you CANNOT do:**
- Modify `system/hosts.nix` or `system/lib.nix` (infrastructure)
- Modify `flake.nix` (add new flake inputs)
- Change the evaluation criteria in `docs/tool-selection.md` without user approval
- Install tools that conflict with the rejected list in `docs/tool-selection.md`
- Add tools that require GUI (this is CLI/terminal only)
- Break the existing module structure or architecture

**Evaluation criteria** (from `docs/tool-selection.md`, in priority order):
1. Physical Ergonomics — RSI prevention, home row priority
2. Security — no plaintext secrets, E2EE
3. Cognitive Load — fewer concepts, intuitive interface
4. Flow State — no friction (shell startup ≤200ms)
5. Portability — Linux + macOS, Nix package available

**Simplicity criterion**: All else equal, simpler is better. A tool that adds complexity for marginal gain is not worth it. Removing unused config and getting equal results is a great outcome. Prefer `programs.*` over raw `home.packages`.

## Metrics

The hard metric is: **`nix flake check` must pass**.

Soft metrics (check before and after):
- `statix check .` — warning count should not increase
- `deadnix .` — dead code count should not increase
- `nix fmt -- --check .` — formatting must pass (run `nix fmt` to fix)

Run evaluation as:
```bash
nix flake check 2>&1 | tail -5
statix check . 2>&1 | wc -l
deadnix . 2>&1 | wc -l
```

## Output format

After each check, note:
```
flake_check:   pass/fail
statix_warns:  <count>
deadnix_warns: <count>
```

## Logging results

Log each experiment to `results.tsv` (tab-separated).

Header and columns:
```
commit	status	type	description
```

1. git commit hash (short, 7 chars)
2. status: `keep`, `discard`, or `fail`
3. type: `new-tool`, `config-improve`, `cleanup`, `fix`
4. short description of what this experiment tried

Example:
```
commit	status	type	description
a1b2c3d	keep	new-tool	add hyperfine (CLI benchmarking)
b2c3d4e	discard	new-tool	add nushell — rejected (not POSIX)
c3d4e5f	keep	config-improve	enable fish integration for yazi
d4e5f6g	fail	new-tool	add tool X — not in nixpkgs
e5f6g7h	keep	cleanup	remove unused import in shell/defaults.nix
```

## Research sources

Cycle through these categories to avoid searching the same thing repeatedly. Track which sources you've already visited in `results.tsv` descriptions.

**Category A — Tool discovery** (search the web):
- "best new CLI tools 2025 2026"
- "rust CLI tools developer"
- "modern unix tools"
- "awesome-cli-apps github"

**Category B — Dotfiles inspiration** (fetch and read repos):
- Browse popular dotfiles repos on GitHub: search `nix home-manager dotfiles`
- Look at their module structure and what tools they include that we don't

**Category C — Config improvement** (no web search needed):
- Re-read each existing module file and check:
  - Is there a `programs.*` module available that we're not using? (using `home.packages` instead)
  - Are all shell integrations enabled? (`enableZshIntegration`, `enableFishIntegration`, etc.)
  - Any hardcoded values that should be options?
  - Any dead code or unused imports? (run `deadnix`)
- Run `statix check .` and fix the warnings one by one

**Category D — Documentation sync**:
- Check if `docs/tool-selection.md` Adopted table matches reality
- Check if Candidates have been adopted but not updated

Rotate: A → C → B → C → D → A → C → ... This ensures you alternate between adding new things and improving existing ones, and you don't burn context on web searches every iteration.

## The experiment loop

LOOP FOREVER:

1. **Pick a category**: Follow the rotation above. For web searches (A, B), keep queries short and redirect output carefully:
   - Do NOT read full articles into context. Extract only the tool name + one-line description.
   - Do NOT search for the same query twice. Vary your search terms.

2. **Evaluate fit**: Before implementing, check against `docs/tool-selection.md`:
   - Is the tool already adopted? → skip (or improve config)
   - Is the tool in the rejected list? → skip
   - Does it pass all 5 evaluation criteria? → proceed
   - Is it available in nixpkgs? → `nix search nixpkgs#<tool>` to verify
   - For config improvements: is the change actually better, or just different?

3. **Implement**: Create or modify the module file.
   - Follow existing module patterns (look at similar files for style)
   - Use `programs.*` when home-manager has a module for it
   - Use `home.packages` only when no HM module exists
   - Keep modules under 400 lines, one concern per file
   - Stage new files with `git add` before checking (flake only sees tracked files)

4. **Format and check**: Run in sequence, bail early on failure:
   ```bash
   nix fmt
   nix flake check 2>&1 | tail -20
   ```
   If `nix flake check` takes longer than 10 minutes, kill it and treat as failure.

5. **Commit or discard**:
   - If check passes and the change has value → `git commit` with conventional commit message, then log as `keep`
   - If check fails after 2-3 fix attempts → `git checkout -- .` to discard all changes, log as `fail`
   - If the change is not worthwhile → `git checkout -- .`, log as `discard`

6. **Log**: Append to `results.tsv` (do NOT commit this file).

7. **Go to step 1.**

**Context management**: Each iteration should be self-contained. Do not keep large file contents or web pages in your working memory. Read what you need, act, then move on. If you find yourself losing track, re-read `results.tsv` to see what you've already tried.

**Stall detection**: If you've logged 3 consecutive `discard` or `fail` results, switch to a different category. If all categories feel exhausted, shift to deeper config improvements: read each module file line by line and look for small optimizations.

**NEVER STOP**: Once the loop has begun, do NOT pause to ask the human if you should continue. The human might be away and expects you to work indefinitely until manually stopped. If you run out of ideas, think harder — re-read existing modules for improvement angles, search for new articles with different keywords, try combining tools, look at popular dotfiles repos on GitHub for inspiration.
