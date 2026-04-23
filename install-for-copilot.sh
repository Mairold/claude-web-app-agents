#!/bin/bash
set -e

REPO="https://raw.githubusercontent.com/ahoa/claude-agents/master"
VERSION_FILE=".github/agents-version"
HOOK_FILE=".github/hooks/claude-agents-update.json"
HOOK_CMD="curl -fsSL $REPO/install-for-copilot.sh | bash"

# --- Version check -----------------------------------------------------------
REMOTE_VERSION=$(curl -fsSL "https://api.github.com/repos/ahoa/claude-agents/commits/master" | python3 -c "import json,sys; print(json.load(sys.stdin)['sha'][:7])")
LOCAL_VERSION=$(cat "$VERSION_FILE" 2>/dev/null || echo "none")

if [ "$REMOTE_VERSION" = "$LOCAL_VERSION" ]; then
  echo "✅ Copilot agents already up to date ($LOCAL_VERSION)"
  exit 0
fi

echo "🤖 Installing Copilot agents ($LOCAL_VERSION → $REMOTE_VERSION)..."

# --- Directory structure -----------------------------------------------------
mkdir -p \
  .github/agents \
  .github/skills \
  .github/instructions \
  .github/hooks \
  .claude/docs

# --- Stage source files in a temp dir ---------------------------------------
TMP=$(mktemp -d)
trap 'rm -rf $TMP' EXIT

mkdir -p "$TMP/agents" "$TMP/commands" "$TMP/skills" "$TMP/rules" "$TMP/docs"

AGENTS=(security-reviewer architecture-reviewer test-reviewer docs-reviewer
        svelte-reviewer spring-reviewer swift-reviewer swiftui-reviewer
        tdd-test-writer tdd-implementer tdd-refactorer)

COMMANDS=(develop plan implement e2e-test e2e-setup review ship fix-bug refactor retro learn)

SKILLS=(svelte-tailwind ui-ux swiftui)

RULES=(java-best-practices java-naming swift-best-practices swift-naming
       typescript-conventions project-security shared-config)

DOCS=(git-rules docker-rules clean-code engineering-principles mobile-guidelines
      spring-conventions svelte-conventions swift-conventions mcp-rules
      database-conventions security-conventions hono-reference e2e-conventions)

for f in "${AGENTS[@]}";   do curl -fsSL "$REPO/.claude/agents/$f.md"           -o "$TMP/agents/$f.md"; done
for f in "${COMMANDS[@]}"; do curl -fsSL "$REPO/.claude/commands/$f.md"         -o "$TMP/commands/$f.md"; done
for f in "${SKILLS[@]}";   do mkdir -p "$TMP/skills/$f" && curl -fsSL "$REPO/.claude/skills/$f/SKILL.md" -o "$TMP/skills/$f/SKILL.md"; done
for f in "${RULES[@]}";    do curl -fsSL "$REPO/.claude/rules/$f.md"            -o "$TMP/rules/$f.md"; done
for f in "${DOCS[@]}";     do curl -fsSL "$REPO/.claude/docs/$f.md"             -o "$TMP/docs/$f.md"; done

# --- Convert with Python -----------------------------------------------------
python3 - "$TMP" <<'PYEOF'
import os, re, sys, shutil
from pathlib import Path

tmp = Path(sys.argv[1])
cwd = Path.cwd()

def split_frontmatter(text):
    """Return (frontmatter_dict_lines, body). If no frontmatter, returns ({}, text)."""
    if not text.startswith("---\n"):
        return {}, text
    end = text.find("\n---\n", 4)
    if end == -1:
        return {}, text
    fm_raw = text[4:end]
    body = text[end + 5:]
    # Parse simple YAML key: value lines (no nested structures in these files)
    fm = {}
    for line in fm_raw.splitlines():
        if ":" in line:
            k, v = line.split(":", 1)
            fm[k.strip()] = v.strip()
    return fm, body

def dump_frontmatter(fm):
    """Dump frontmatter dict back to YAML. Preserves insertion order."""
    if not fm:
        return ""
    out = ["---"]
    for k, v in fm.items():
        out.append(f"{k}: {v}")
    out.append("---")
    return "\n".join(out) + "\n"

# --- AGENTS: .claude/agents/NAME.md → .github/agents/NAME.agent.md -----------
# Claude Code:   tools: Read, Grep, Glob   (comma-separated string)
# Copilot CLI:   tools: ['Read', 'Grep', 'Glob']   (YAML array)
# Claude Code has 'model: opus/sonnet/haiku' — we strip it (Copilot uses /model).
agents_src = tmp / "agents"
agents_dst = cwd / ".github" / "agents"
for src in sorted(agents_src.glob("*.md")):
    text = src.read_text()
    fm, body = split_frontmatter(text)

    # Strip model — Copilot CLI uses /model to switch, not frontmatter
    fm.pop("model", None)

    # Convert 'tools: Read, Grep, Glob' → "tools: ['Read', 'Grep', 'Glob']"
    if "tools" in fm:
        tools = [t.strip() for t in fm["tools"].split(",") if t.strip()]
        fm["tools"] = "[" + ", ".join(f"'{t}'" for t in tools) + "]"

    # Ensure 'name' is present (Copilot requires it implicitly via filename but explicit is safer)
    if "name" not in fm:
        fm["name"] = src.stem

    dst = agents_dst / f"{src.stem}.agent.md"
    dst.write_text(dump_frontmatter(fm) + body)

# --- COMMANDS → SKILLS: .claude/commands/NAME.md → .github/skills/NAME/SKILL.md
# Claude Code command:  frontmatter has only 'model: opus' (optional)
# Copilot CLI skill:    needs 'name' + 'description' in frontmatter
# We derive description from the first line of body content.
commands_src = tmp / "commands"
skills_dst = cwd / ".github" / "skills"

# Hand-written descriptions — better than first-line heuristics for triggering.
# Keep these short and specific so Copilot picks the right skill for a prompt.
CMD_DESCRIPTIONS = {
    "develop":   "Full development cycle for a story: plan, implement, test, review, ship. Invoke with a story slug.",
    "plan":      "Read a story and add acceptance criteria plus implementation plan. Invoke with a story slug.",
    "implement": "TDD implementation of a planned story. Runs test-writer, implementer, refactorer subagents. Invoke with a story slug.",
    "e2e-test":  "Write or run Playwright E2E tests for a story. Invoke with a story slug.",
    "e2e-setup": "Bootstrap E2E test infrastructure (Playwright, docker-compose.test.yml, test auth) in a project.",
    "review":    "Parallel code review using up to 8 specialist agents (security, architecture, tests, docs, framework). Invoke with a story slug or 'all'.",
    "ship":      "Commit, deploy, and close a story. Invoke with a story slug.",
    "fix-bug":   "Standalone bug fix workflow: read bug, write failing test, fix, deploy, close. Invoke with a story slug.",
    "refactor":  "Standalone refactoring workflow: baseline tests, refactor, verify, deploy. No slug required.",
    "retro":     "Analyze accumulated learnings, find recurring patterns, propose rule promotions to CLAUDE.md or agent files.",
    "learn":     "Manually log a new learning or promote an existing one by UUID to a permanent rule.",
}

for src in sorted(commands_src.glob("*.md")):
    _, body = split_frontmatter(src.read_text())
    name = src.stem
    fm = {
        "name": name,
        "description": CMD_DESCRIPTIONS.get(name, f"{name} workflow."),
    }
    skill_dir = skills_dst / name
    skill_dir.mkdir(parents=True, exist_ok=True)
    (skill_dir / "SKILL.md").write_text(dump_frontmatter(fm) + body)

# --- SKILLS: .claude/skills/NAME/SKILL.md → .github/skills/NAME/SKILL.md -----
# Format is already agentskills.io compatible. Copy verbatim.
skills_src = tmp / "skills"
for src_dir in sorted(p for p in skills_src.iterdir() if p.is_dir()):
    dst_dir = skills_dst / src_dir.name
    dst_dir.mkdir(parents=True, exist_ok=True)
    shutil.copy(src_dir / "SKILL.md", dst_dir / "SKILL.md")

# --- RULES → INSTRUCTIONS: .claude/rules/NAME.md → .github/instructions/NAME.instructions.md
# Claude Code:  paths: "**/*.java"
# Copilot CLI:  applyTo: "**/*.java"
rules_src = tmp / "rules"
instr_dst = cwd / ".github" / "instructions"
for src in sorted(rules_src.glob("*.md")):
    text = src.read_text()
    fm, body = split_frontmatter(text)

    # Rename 'paths' → 'applyTo'
    if "paths" in fm:
        fm["applyTo"] = fm.pop("paths")

    # Rules without a path constraint become repo-wide instructions.
    # If no applyTo, keep frontmatter minimal (Copilot reads it repo-wide).
    dst = instr_dst / f"{src.stem}.instructions.md"
    dst.write_text(dump_frontmatter(fm) + body)

# --- DOCS: keep in .claude/docs/ (shared between Claude Code and Copilot) ----
# Agents and skills reference these via relative paths like `.claude/docs/security-conventions.md`.
# We preserve that path so the same files work for both CLIs without rewriting references.
docs_src = tmp / "docs"
docs_dst = cwd / ".claude" / "docs"
for src in sorted(docs_src.glob("*.md")):
    shutil.copy(src, docs_dst / src.name)

print("  ✓ agents converted")
print("  ✓ commands → skills converted")
print("  ✓ skills copied")
print("  ✓ rules → instructions converted")
print("  ✓ docs copied to .claude/docs/")
PYEOF

# --- AGENTS.md (repo-wide custom instructions for Copilot) ------------------
# Point Copilot at the shared-config and the agent docs so it has the same
# project context that Claude Code gets via CLAUDE.md + .claude/rules/.
if [ ! -f "AGENTS.md" ]; then
  cat > AGENTS.md <<'EOF'
# Project guidelines

This project uses shared conventions documented in `.claude/docs/` and
`.github/instructions/`. Those files are authoritative — read them when
relevant.

## Core references

- `.claude/docs/engineering-principles.md` — general engineering principles
- `.claude/docs/clean-code.md` — clean-code rules
- `.claude/docs/git-rules.md` — commit and branch conventions
- `.claude/docs/docker-rules.md` — container conventions
- `.claude/docs/mcp-rules.md` — MCP safety rules and story sizing
- `.github/instructions/shared-config.instructions.md` — project-specific overrides

## Per-language rules (auto-applied via applyTo)

- `.github/instructions/java-best-practices.instructions.md` — `**/*.java`
- `.github/instructions/java-naming.instructions.md` — `**/*.java`
- `.github/instructions/typescript-conventions.instructions.md` — `**/*.{ts,tsx}`
- `.github/instructions/swift-best-practices.instructions.md` — `**/*.swift`
- `.github/instructions/swift-naming.instructions.md` — `**/*.swift`

## Skills and agents

Slash-invokable skills (`/develop`, `/plan`, `/implement`, `/review`, `/ship`,
`/fix-bug`, `/refactor`, `/retro`, `/learn`, `/e2e-test`, `/e2e-setup`) live in
`.github/skills/`. Review and TDD subagents live in `.github/agents/` and are
invoked via `/agent` or automatically when their expertise fits.

## Model selection

Agent and skill frontmatter does not pin a model — use `/model` to switch.
Recommended pairing (tune to availability):

- Orchestrators (`/develop`, `/implement`, `/fix-bug`, `/refactor`): strongest
  model (e.g. Claude Opus or GPT-5 with reasoning).
- Review and TDD subagents, other skills: mid-tier (Claude Sonnet, GPT-5).
- `docs-reviewer`: fastest available (Claude Haiku).
EOF
  echo "✅ Created AGENTS.md"
else
  echo "✅ AGENTS.md already exists, not overwriting"
fi

# --- SessionStart hook -------------------------------------------------------
# Copilot CLI reads .github/hooks/*.json. sessionStart output is ignored,
# which is exactly what we want for a silent auto-update.
if [ -f "$HOOK_FILE" ]; then
  echo "✅ Update hook already configured at $HOOK_FILE"
else
  cat > "$HOOK_FILE" <<EOF
{
  "version": 1,
  "hooks": {
    "sessionStart": [
      {
        "type": "command",
        "bash": "$HOOK_CMD",
        "timeoutSec": 30
      }
    ]
  }
}
EOF
  echo "✅ Created $HOOK_FILE (auto-update on every Copilot CLI session)"
fi

# --- Version stamp -----------------------------------------------------------
echo "$REMOTE_VERSION" > "$VERSION_FILE"

# --- Done --------------------------------------------------------------------
echo ""
echo "✅ Copilot agents $REMOTE_VERSION installed."
echo "   Agents will auto-update at the start of every Copilot CLI session."
echo ""
echo "   /develop <slug>     — full cycle (Java/Spring + SvelteKit + Swift/SwiftUI)"
echo "   /plan <slug>        — read story, add AC + plan"
echo "   /implement <slug>   — TDD implementation"
echo "   /e2e-test <slug>    — Playwright E2E tests"
echo "   /review <slug>      — parallel review"
echo "   /ship <slug>        — commit, deploy, close story"
echo "   /fix-bug <slug>     — standalone bug fix + deploy"
echo "   /refactor           — standalone refactoring + deploy"
echo "   /retro              — analyze learnings, propose promotions"
echo "   /learn <desc|uuid>  — log or promote a learning"
echo ""
echo "   Tip: run 'copilot' in a folder you've trusted so .mcp.json loads."