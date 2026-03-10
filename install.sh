#!/bin/bash
set -e

REPO="https://raw.githubusercontent.com/ahoa/claude-agents/master"

echo "🤖 Installing Claude agents..."

mkdir -p .claude/agents .claude/commands

curl -fsSL "$REPO/.claude/agents/security-reviewer.md"     -o .claude/agents/security-reviewer.md
curl -fsSL "$REPO/.claude/agents/architecture-reviewer.md" -o .claude/agents/architecture-reviewer.md
curl -fsSL "$REPO/.claude/agents/test-reviewer.md"         -o .claude/agents/test-reviewer.md
curl -fsSL "$REPO/.claude/agents/docs-reviewer.md"         -o .claude/agents/docs-reviewer.md
curl -fsSL "$REPO/.claude/commands/develop.md"             -o .claude/commands/develop.md
curl -fsSL "$REPO/.claude/commands/review.md"              -o .claude/commands/review.md

if [ -f "CLAUDE.md" ]; then
  echo "" >> CLAUDE.md
  echo "---" >> CLAUDE.md
  curl -fsSL "$REPO/CLAUDE.md" >> CLAUDE.md
  echo "✅ Appended agent config to existing CLAUDE.md"
else
  curl -fsSL "$REPO/CLAUDE.md" -o CLAUDE.md
  echo "✅ Created CLAUDE.md"
fi

echo ""
echo "✅ Done! Usage:"
echo "   /develop <id|slug>   — implement + review"
echo "   /review <id|slug>    — review only"
