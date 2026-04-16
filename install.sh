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

mkdir -p .claude/agents .claude/commands .claude/skills/svelte-tailwind .claude/skills/ui-ux .claude/skills/swiftui .claude/rules .claude/docs

# Remove legacy agent_docs if exists (moved to .claude/docs)
[ -d "agent_docs" ] && rm -rf agent_docs && echo "🗑  Removed legacy agent_docs/ (now .claude/docs/)"

# 11 agents (8 review + 3 TDD)
curl -fsSL "$REPO/.claude/agents/security-reviewer.md"      -o .claude/agents/security-reviewer.md
curl -fsSL "$REPO/.claude/agents/architecture-reviewer.md"  -o .claude/agents/architecture-reviewer.md
curl -fsSL "$REPO/.claude/agents/test-reviewer.md"          -o .claude/agents/test-reviewer.md
curl -fsSL "$REPO/.claude/agents/docs-reviewer.md"          -o .claude/agents/docs-reviewer.md
curl -fsSL "$REPO/.claude/agents/svelte-reviewer.md"        -o .claude/agents/svelte-reviewer.md
curl -fsSL "$REPO/.claude/agents/spring-reviewer.md"        -o .claude/agents/spring-reviewer.md
curl -fsSL "$REPO/.claude/agents/swift-reviewer.md"         -o .claude/agents/swift-reviewer.md
curl -fsSL "$REPO/.claude/agents/swiftui-reviewer.md"       -o .claude/agents/swiftui-reviewer.md
curl -fsSL "$REPO/.claude/agents/tdd-test-writer.md"        -o .claude/agents/tdd-test-writer.md
curl -fsSL "$REPO/.claude/agents/tdd-implementer.md"        -o .claude/agents/tdd-implementer.md
curl -fsSL "$REPO/.claude/agents/tdd-refactorer.md"         -o .claude/agents/tdd-refactorer.md

# 11 commands
curl -fsSL "$REPO/.claude/commands/develop.md"              -o .claude/commands/develop.md
curl -fsSL "$REPO/.claude/commands/plan.md"                 -o .claude/commands/plan.md
curl -fsSL "$REPO/.claude/commands/implement.md"            -o .claude/commands/implement.md
curl -fsSL "$REPO/.claude/commands/e2e-test.md"             -o .claude/commands/e2e-test.md
curl -fsSL "$REPO/.claude/commands/e2e-setup.md"           -o .claude/commands/e2e-setup.md
curl -fsSL "$REPO/.claude/commands/review.md"               -o .claude/commands/review.md
curl -fsSL "$REPO/.claude/commands/ship.md"                 -o .claude/commands/ship.md
curl -fsSL "$REPO/.claude/commands/fix-bug.md"              -o .claude/commands/fix-bug.md
curl -fsSL "$REPO/.claude/commands/refactor.md"             -o .claude/commands/refactor.md
curl -fsSL "$REPO/.claude/commands/retro.md"                -o .claude/commands/retro.md
curl -fsSL "$REPO/.claude/commands/learn.md"                -o .claude/commands/learn.md

# 3 skills
curl -fsSL "$REPO/.claude/skills/svelte-tailwind/SKILL.md"  -o .claude/skills/svelte-tailwind/SKILL.md
curl -fsSL "$REPO/.claude/skills/ui-ux/SKILL.md"            -o .claude/skills/ui-ux/SKILL.md
curl -fsSL "$REPO/.claude/skills/swiftui/SKILL.md"          -o .claude/skills/swiftui/SKILL.md

# 5 rules (auto-activate for *.java, *.swift, *.ts files)
curl -fsSL "$REPO/.claude/rules/java-best-practices.md"     -o .claude/rules/java-best-practices.md
curl -fsSL "$REPO/.claude/rules/java-naming.md"             -o .claude/rules/java-naming.md
curl -fsSL "$REPO/.claude/rules/swift-best-practices.md"    -o .claude/rules/swift-best-practices.md
curl -fsSL "$REPO/.claude/rules/swift-naming.md"            -o .claude/rules/swift-naming.md
curl -fsSL "$REPO/.claude/rules/typescript-conventions.md"  -o .claude/rules/typescript-conventions.md

# shared config (loaded automatically by Claude Code, never touches project CLAUDE.md)
curl -fsSL "$REPO/.claude/rules/shared-config.md"    -o .claude/rules/shared-config.md

# docs (referenced by CLAUDE.md and commands)
curl -fsSL "$REPO/.claude/docs/git-rules.md"                  -o .claude/docs/git-rules.md
curl -fsSL "$REPO/.claude/docs/docker-rules.md"               -o .claude/docs/docker-rules.md
curl -fsSL "$REPO/.claude/docs/clean-code.md"                 -o .claude/docs/clean-code.md
curl -fsSL "$REPO/.claude/docs/engineering-principles.md"     -o .claude/docs/engineering-principles.md
curl -fsSL "$REPO/.claude/docs/mobile-guidelines.md"          -o .claude/docs/mobile-guidelines.md
curl -fsSL "$REPO/.claude/docs/spring-conventions.md"         -o .claude/docs/spring-conventions.md
curl -fsSL "$REPO/.claude/docs/svelte-conventions.md"         -o .claude/docs/svelte-conventions.md
curl -fsSL "$REPO/.claude/docs/swift-conventions.md"          -o .claude/docs/swift-conventions.md
curl -fsSL "$REPO/.claude/docs/mcp-rules.md"                 -o .claude/docs/mcp-rules.md
curl -fsSL "$REPO/.claude/docs/database-conventions.md"     -o .claude/docs/database-conventions.md
curl -fsSL "$REPO/.claude/docs/security-conventions.md"     -o .claude/docs/security-conventions.md
curl -fsSL "$REPO/.claude/docs/hono-reference.md"           -o .claude/docs/hono-reference.md

echo "$REMOTE_VERSION" > "$VERSION_FILE"

echo "✅ CLAUDE.md untouched — project-specific config stays yours"

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
echo "   /develop <slug>      — full cycle (Java/Spring + SvelteKit + Swift/SwiftUI)"
echo "   /plan <slug>         — read story, add AC + plan"
echo "   /implement <slug>    — TDD implementation"
echo "   /e2e-test <slug>     — Playwright E2E tests"
echo "   /review <slug>       — parallel review (up to 8 agents)"
echo "   /ship <slug>          — commit, deploy, close story"
echo "   /fix-bug <slug>      — standalone bug fix + deploy"
echo "   /refactor            — standalone refactoring + deploy"
echo "   /retro               — analyze learnings, propose rule promotions"
echo "   /learn <desc|uuid>   — manually log or promote a learning"
