#!/bin/bash
set -e

REPO="https://raw.githubusercontent.com/ahoa/claude-agents/master"
HOOK_CMD="curl -fsSL $REPO/install.sh | bash"
SETTINGS=".claude/settings.json"
VERSION_FILE=".claude/agents-version"

# Check if update is needed
REMOTE_VERSION=$(curl -fsSL "$REPO/.claude/agents-version" 2>/dev/null || echo "unknown")
LOCAL_VERSION=$(cat "$VERSION_FILE" 2>/dev/null || echo "none")

if [ "$REMOTE_VERSION" = "$LOCAL_VERSION" ]; then
  echo "✅ Claude agents already up to date ($LOCAL_VERSION)"
  exit 0
fi

echo "🤖 Installing Claude agents ($LOCAL_VERSION → $REMOTE_VERSION)..."

mkdir -p .claude/agents .claude/commands

curl -fsSL "$REPO/.claude/agents/security-reviewer.md"     -o .claude/agents/security-reviewer.md
curl -fsSL "$REPO/.claude/agents/architecture-reviewer.md" -o .claude/agents/architecture-reviewer.md
curl -fsSL "$REPO/.claude/agents/test-reviewer.md"         -o .claude/agents/test-reviewer.md
curl -fsSL "$REPO/.claude/agents/docs-reviewer.md"         -o .claude/agents/docs-reviewer.md
curl -fsSL "$REPO/.claude/commands/develop.md"             -o .claude/commands/develop.md
curl -fsSL "$REPO/.claude/commands/review.md"              -o .claude/commands/review.md
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

# Set up preSession hook
if [ -f "$SETTINGS" ]; then
  if grep -q "preSession" "$SETTINGS"; then
    echo "✅ preSession hook already configured, skipping"
  else
    python3 -c "
import json
with open('$SETTINGS') as f:
    s = json.load(f)
s.setdefault('hooks', {})['preSession'] = '$HOOK_CMD'
with open('$SETTINGS', 'w') as f:
    json.dump(s, f, indent=2)
"
    echo "✅ Added preSession hook to $SETTINGS"
  fi
else
  echo "{\"hooks\":{\"preSession\":\"$HOOK_CMD\"}}" | python3 -c "
import json,sys
print(json.dumps(json.load(sys.stdin), indent=2))
" > "$SETTINGS"
  echo "✅ Created $SETTINGS with preSession hook"
fi

echo ""
echo "✅ Claude agents $REMOTE_VERSION installed."
echo "   Restart Claude Code to apply."
echo ""
echo "   /develop <id|slug>   — implement + review"
echo "   /review <id|slug>    — review only"
