# claude-agents

Multi-agent review setup for Claude Code. One command runs implementation + parallel security, architecture, testing, and docs review — all writing results back to your story tracker via MCP.

## Install

Run this in any project root:

```bash
curl -fsSL https://raw.githubusercontent.com/ahoa/claude-agents/master/install.sh | bash
```

The installer will:
- Copy all agent and command files into `.claude/`
- Append agent conventions to `CLAUDE.md`
- Add a `preSession` hook to `.claude/settings.json` so agents **auto-update at the start of every Claude Code session** — no manual reinstall needed when the repo changes

Restart Claude Code after the first install — files are loaded at session start.

## Usage

```
/develop <id|slug>    — implement story + auto review
/review <id|slug>     — review only (code already exists)
```

## Requirements

- Claude Code with `/agents` support
- MCP server exposing: `list_stories`, `read_story`, `create_story`, `update_story`, `change_status`

## /develop phases

| #  | Phase                | Description                                                                                                               |
|----|----------------------|---------------------------------------------------------------------------------------------------------------------------|
| 1  | Read & Plan          | Reads story via MCP. Briefly documents what will be built and key assumptions.                                            |
| 2a | Write Tests First    | ⚠️ Writes unit tests before any implementation. Tests are expected to fail to compile.                                    |
| 2b | Stub Implementations | ⚠️ Creates empty stubs just enough to compile. All tests must be red before moving on.                                    |
| 2c | Implement            | Implements real logic one failing test at a time until all green. Refactors after green.                                  |
| 3  | Parallel Review      | Spawns 4 independent agents simultaneously. Each returns findings as text — no DB writes.                                 |
| 4  | Fix & Synthesize     | Fixes CRITICAL/MUST FIX immediately. Writes compact summary to story. Creates follow-up story for remaining items if any. |

## Agents

| Agent                   | Focuses on                                                                                      |
|-------------------------|-------------------------------------------------------------------------------------------------|
| `security-reviewer`     | OWASP Top 10:2025 (A01–A10) — findings tagged by category, ordered CRITICAL → LOW               |
| `architecture-reviewer` | Clean Code rules, SOLID, God classes (>200 lines), circular deps, business logic in wrong layer |
| `test-reviewer`         | Untested critical paths, happy-path-only tests, missing edge cases, over-mocked tests           |
| `docs-reviewer`         | Missing README, undocumented endpoints, unexplained business logic, outdated comments           |

Each agent runs in its own clean context — it sees only the file paths it was given and its own system prompt. No shared state between agents.
