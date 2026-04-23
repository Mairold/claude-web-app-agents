# claude-agents repo configuration
# This file is for the claude-agents repo itself, not installed into projects.
# Shared config for installed projects lives in .claude/rules/shared-config.md
# (also autoloaded for this repo via .claude/rules/)

## Install script maintenance

When adding, removing, or renaming any file in `.claude/agents/`,
`.claude/commands/`, `.claude/skills/`, `.claude/rules/`, or
`.claude/docs/`, you MUST also update BOTH install scripts in the
same commit:

- `install.sh` — the file list for Claude Code install
- `install-for-copilot.sh` — the file list for Copilot CLI install

Both scripts use hardcoded file lists (AGENTS, COMMANDS, SKILLS,
RULES, DOCS arrays). Every file under `.claude/` must appear in
both scripts, or the installer will silently skip it on user machines.

After editing, verify by running:
grep -c "^\\s*[a-z-]\\+\\s*$" install.sh
grep -c "^\\s*[a-z-]\\+\\s*$" install-for-copilot.sh
Counts must match between the two scripts.
