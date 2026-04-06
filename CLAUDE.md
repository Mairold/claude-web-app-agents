# Project Agent Configuration

## MCP Tools Available
- `list_stories` — list all stories (supports filter by status/tag)
- `read_story` — read a story by ID or slug
- `create_story` — create a new story
- `update_story` — update story description/content
- `change_status` — change story status
- `log_learning` — log a finding or pattern from a development phase
- `list_learnings` — list accumulated learnings, grouped by pattern
- `promote_learning` — mark a learning as promoted to CLAUDE.md

## MCP Safety Rules
- **Never change story title/slug via MCP** — when calling `update_story`, keep the first `# Feature:` heading identical to what `read_story` returned. Changing the title regenerates the slug, which can orphan comments and cause data loss.
- **Preserve original story content** — never rewrite the entire story from scratch. Always `read_story` first, then modify only specific sections (AC, Tasks, Details, Bugs). Keep all other sections and user-written text verbatim.

## MCP Fallback Behavior
When an MCP story tool is unavailable or a call fails:
- **`read_story`**: if `$ARGUMENTS` contains spaces, treat it as the task description directly. If it looks like a slug (no spaces, hyphen-separated), ask the user to paste the requirements.
- **`update_story`**: print the content that would have been written, prefixed with the target section name (e.g. `## Acceptance Criteria:`).
- **`create_story`**: print the story content (title, description, tasks) as markdown. Prefix with `📋 Story (not saved — no story system):`.
- **`list_stories`**: print `Story system unavailable` and continue.
- **`change_status`**: print `[slug] done (story system unavailable)` and continue.
- **`log_learning`**: print `[learning not saved — no MCP]` and continue. Never block the pipeline.
- **`list_learnings`**: print `No learnings available` and continue.
- **`promote_learning`**: print `[promote manually]` and continue.

## Custom Commands
- `/develop <slug or description>` — full cycle: plan → implement → test → review → fix → commit → push → deploy
- `/plan <slug or description>` — read story, add AC + implementation plan
- `/implement <slug or description>` — TDD implementation cycle
- `/e2e-test <slug or description>` — write Playwright E2E tests (bootstraps Playwright on first use)
- `/e2e-setup` — bootstrap Playwright E2E infrastructure (run once per project)
- `/review <slug or description>` — parallel review (up to 6 agents, conditional tech-stack agents)
- `/fix-and-ship <slug or description>` — fix CRITICAL/MUST FIX + close story
- `/fix-bug <slug or description>` — standalone bug fix + deploy + done
- `/refactor` — standalone refactoring + deploy
- `/retro` — analyze accumulated learnings, propose rule promotions
- `/learn <description or UUID>` — manually log or promote a learning

## Story Sizing
- **Stories must be minimally testable units.** Never create a single story that spans DB migration + new service + UI changes for multiple concepts.
- Split large features into dependent stories with clear ordering. Each story should be independently deployable and testable.
- When creating stories via `create_story`, check if the scope covers more than one vertical slice. If it does, split and note dependencies.
- **Group related stories with a label.** When splitting a feature into multiple stories, apply a shared label (e.g. the feature name) to all of them.

## TDD and Testing Rules
- **Tests are part of every task** — always write tests with every task, not as a separate step. Don't wait for the user to ask.
- **Failing tests — ask before fixing** — when a test fails, analyze root cause and present findings to the user before changing test or code. Never blindly modify tests.
- **Re-run E2E after review fixes** — always re-run all E2E tests after fixing review findings in `/develop`. Don't assume fixes are safe.

## Planning Rules
- **Always wait for plan approval** — never start implementing before user approves the plan, even in `/develop`. Exception: if the story already has a detailed plan with tasks before `/plan` runs.

## Review Scope Rules
- **Only review code written/modified in the current story.** Do not flag pre-existing issues in files that were only touched for minor edits (imports, signature changes).
- **Only report CRITICAL and HIGH findings for inline fixing.** MEDIUM go into summary.
- **Fix CRITICAL and HIGH inline.** MEDIUM findings across the whole review get bundled into exactly ONE follow-up story (not one per finding). LOW/Nice-to-have are logged but ignored.
- **Max one follow-up story per `/develop` run.** Title format: `[FOLLOWUP] <original-slug> — review cleanup`
- **No endless cycles.** Each `/develop` run produces exactly one review round. No re-reviews, no follow-up reviews. Never create follow-up stories from reviews.

## Agents
11 review/TDD agents in `.claude/agents/` — agent files are authoritative, not this section.
Review agents (8): security, architecture, test, docs, svelte, spring, swift, swiftui.
  Core (always): security, architecture, test.
  Conditional: docs (new API endpoints/public-facing), svelte (frontend files), spring (Java files), swift + swiftui (Swift files).
TDD agents (3): tdd-test-writer (RED), tdd-implementer (GREEN), tdd-refactorer (REFACTOR).
  Invoked by /implement — not called directly.
Max 30 lines per review agent, max 3 lines per finding. Clean Areas section mandatory.

## Mobile Guidelines
See `agent_docs/mobile-guidelines.md`.

## Clean Code Conventions
See `agent_docs/clean-code.md`.

## Engineering Principles
See `agent_docs/engineering-principles.md`.

## Stack-Specific Conventions
- Spring Boot: see `agent_docs/spring-conventions.md`
- SvelteKit: see `agent_docs/svelte-conventions.md`
- Swift/iOS: see `agent_docs/swift-conventions.md`
