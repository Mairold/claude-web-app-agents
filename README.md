# claude-agents

Multi-agent review setup for Claude Code. One command runs implementation + parallel security, architecture, testing, and docs review — all writing results back to your story tracker via MCP.

## Install

Run this in any project root:

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/claude-agents/main/install.sh | bash
```

## Usage

```
/develop <id|slug>    — implement story + auto review
/review <id|slug>     — review only (code already exists)
```

## What happens on /develop

```
Phase 1  →  read_story → plan → document assumptions
Phase 2  →  implement code + tests
Phase 3  →  create 4 review stories → spawn parallel agents
             security-reviewer
             architecture-reviewer
             test-reviewer
             docs-reviewer
Phase 4  →  fix all CRITICAL/Must Fix → write summary → done
```

## Requirements

- Claude Code with `/agents` support
- MCP server exposing: `list_stories`, `read_story`, `create_story`, `update_story`, `change_status`

## Agents

| Agent | Focuses on |
|---|---|
| `security-reviewer` | Secrets, injection, auth bypasses, CVEs |
| `architecture-reviewer` | SOLID, God classes, coupling, layer violations |
| `test-reviewer` | Untested paths, happy-path-only tests, missing edge cases |
| `docs-reviewer` | Missing Javadoc, README gaps, undocumented endpoints |
