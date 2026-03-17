#!/bin/bash
set -e

REPO="https://raw.githubusercontent.com/ahoa/claude-agents/master"
SETTINGS=".claude/settings.json"
VERSION_FILE=".claude/agents-version"
HOOK_CMD="curl -fsSL $REPO/install.sh | bash"

# Check if update is needed
REMOTE_VERSION=$(curl -fsSL "https://api.github.com/repos/ahoa/claude-agents/commits/master" | python3 -c "import json,sys; print(json.load(sys.stdin)['sha'][:7])")
LOCAL_VERSION=$(cat "$VERSION_FILE" 2>/dev/null || echo "none")

if [ "$REMOTE_VERSION" = "$LOCAL_VERSION" ]; then
  echo "✅ Claude agents already up to date ($LOCAL_VERSION)"
  exit 0
fi

echo "🤖 Installing Claude agents ($LOCAL_VERSION → $REMOTE_VERSION)..."

mkdir -p .claude/agents .claude/commands .claude/skills/svelte-tailwind .claude/skills/ui-ux .claude/rules

# 6 agents
curl -fsSL "$REPO/.claude/agents/security-reviewer.md"      -o .claude/agents/security-reviewer.md
curl -fsSL "$REPO/.claude/agents/architecture-reviewer.md"  -o .claude/agents/architecture-reviewer.md
curl -fsSL "$REPO/.claude/agents/test-reviewer.md"          -o .claude/agents/test-reviewer.md
curl -fsSL "$REPO/.claude/agents/docs-reviewer.md"          -o .claude/agents/docs-reviewer.md
curl -fsSL "$REPO/.claude/agents/svelte-reviewer.md"        -o .claude/agents/svelte-reviewer.md
curl -fsSL "$REPO/.claude/agents/spring-reviewer.md"        -o .claude/agents/spring-reviewer.md

# 8 commands
curl -fsSL "$REPO/.claude/commands/develop.md"              -o .claude/commands/develop.md
curl -fsSL "$REPO/.claude/commands/plan.md"                 -o .claude/commands/plan.md
curl -fsSL "$REPO/.claude/commands/implement.md"            -o .claude/commands/implement.md
curl -fsSL "$REPO/.claude/commands/e2e-test.md"             -o .claude/commands/e2e-test.md
curl -fsSL "$REPO/.claude/commands/review.md"               -o .claude/commands/review.md
curl -fsSL "$REPO/.claude/commands/fix-and-ship.md"         -o .claude/commands/fix-and-ship.md
curl -fsSL "$REPO/.claude/commands/fix-bug.md"              -o .claude/commands/fix-bug.md
curl -fsSL "$REPO/.claude/commands/refactor.md"             -o .claude/commands/refactor.md

# 2 skills
curl -fsSL "$REPO/.claude/skills/svelte-tailwind/SKILL.md"  -o .claude/skills/svelte-tailwind/SKILL.md
curl -fsSL "$REPO/.claude/skills/ui-ux/SKILL.md"            -o .claude/skills/ui-ux/SKILL.md

# 2 rules (auto-activate for *.java files)
curl -fsSL "$REPO/.claude/rules/java-best-practices.md"     -o .claude/rules/java-best-practices.md
curl -fsSL "$REPO/.claude/rules/java-naming.md"             -o .claude/rules/java-naming.md

echo "$REMOTE_VERSION" > "$VERSION_FILE"

if [ -f "CLAUDE.md" ]; then
  if grep -q "## Clean Code Conventions" CLAUDE.md; then
    echo "✅ CLAUDE.md already contains agent config, skipping"
  else
    echo "" >> CLAUDE.md
    echo "---" >> CLAUDE.md
    curl -fsSL "$REPO/CLAUDE.md" >> CLAUDE.md
    echo "✅ Appended agent config to existing CLAUDE.md"
  fi
else
  curl -fsSL "$REPO/CLAUDE.md" -o CLAUDE.md
  echo "✅ Created CLAUDE.md"
fi

# Set up SessionStart hook so agents auto-update on every Claude Code session
if [ -f "$SETTINGS" ]; then
  if grep -q "SessionStart" "$SETTINGS"; then
    echo "✅ SessionStart hook already configured, skipping"
  else
    python3 -c "
import json
with open('$SETTINGS') as f:
    s = json.load(f)
s.setdefault('hooks', {}).setdefault('SessionStart', [])
s['hooks']['SessionStart'].append({'hooks': [{'type': 'command', 'command': '$HOOK_CMD'}]})
with open('$SETTINGS', 'w') as f:
    json.dump(s, f, indent=2)
"
    echo "✅ Added SessionStart hook to $SETTINGS"
  fi
else
  python3 -c "
import json
s = {'hooks': {'SessionStart': [{'hooks': [{'type': 'command', 'command': '$HOOK_CMD'}]}]}}
print(json.dumps(s, indent=2))
" > "$SETTINGS"
  echo "✅ Created $SETTINGS with SessionStart hook"
fi

echo ""
echo "✅ Claude agents $REMOTE_VERSION installed."
echo "   Agents will auto-update at the start of every Claude Code session."
echo ""
echo "   /develop <slug>      — full cycle: plan → implement → test → review → fix → deploy"
echo "   /plan <slug>         — read story, add AC + plan"
echo "   /implement <slug>    — TDD implementation"
echo "   /e2e-test <slug>     — Playwright E2E tests"
echo "   /review <slug>       — parallel review (6 agents)"
echo "   /fix-and-ship <slug> — fix findings + close story"
echo "   /fix-bug <slug>      — standalone bug fix + deploy"
echo "   /refactor            — standalone refactoring + deploy"
