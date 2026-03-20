# Project Agent Configuration

## MCP Tools Available
- `list_stories` — list all stories (supports filter by status/tag)
- `read_story` — read a story by ID or slug
- `create_story` — create a new story
- `update_story` — update story description/content
- `change_status` — change story status

## MCP Fallback Behavior
When an MCP story tool is unavailable or a call fails:
- **`read_story`**: if `$ARGUMENTS` contains spaces, treat it as the task description directly. If it looks like a slug (no spaces, hyphen-separated), ask the user to paste the requirements.
- **`update_story`**: print the content that would have been written, prefixed with the target section name (e.g. `## Acceptance Criteria:`).
- **`change_status`**: print `[slug] done (story system unavailable)` and continue.

## Custom Commands
- `/develop <slug or description>` — full cycle: plan → implement → test → review → fix → commit → push → deploy
- `/plan <slug or description>` — read story, add AC + implementation plan
- `/implement <slug or description>` — TDD implementation cycle
- `/e2e-test <slug or description>` — write Playwright E2E tests (bootstraps Playwright on first use)
- `/review <slug or description>` — parallel review (up to 6 agents, conditional tech-stack agents)
- `/fix-and-ship <slug or description>` — fix CRITICAL/MUST FIX + close story
- `/fix-bug <slug or description>` — standalone bug fix + deploy + done
- `/refactor` — standalone refactoring + deploy

## Story Sizing
- **Stories must be minimally testable units.** Never create a single story that spans DB migration + new service + UI changes for multiple concepts.
- Split large features into dependent stories with clear ordering. Each story should be independently deployable and testable.
- When creating stories via `create_story`, check if the scope covers more than one vertical slice. If it does, split and note dependencies.
- **Group related stories with a label.** When splitting a feature into multiple stories, apply a shared label (e.g. the feature name) to all of them.

## Review Scope Rules
- **Only review code written/modified in the current story.** Do not flag pre-existing issues in files that were only touched for minor edits (imports, signature changes).
- **Only report CRITICAL and HIGH findings.** MEDIUM/LOW/Nice-to-have go into the story summary but do NOT generate follow-up stories or tasks.
- **Fix CRITICAL inline. Log the rest.** Never create follow-up stories from reviews. If something isn't worth fixing now, it's not worth tracking.
- **No endless cycles.** Each `/develop` run produces exactly one review round. No re-reviews, no follow-up reviews.

## Agents
6 review agents in `.claude/agents/` — agent files are authoritative, not this section.
Core: security, architecture, test, docs. Conditional: svelte (frontend files), spring (Java files).
Max 30 lines per agent, max 3 lines per finding. Clean Areas section mandatory.

## Mobile Guidelines
- **No hover-only interactions.** Anything behind `hover:` must also work on touch. Use `sm:opacity-0 sm:group-hover:opacity-100` so elements are always visible on mobile but hover-revealed on desktop.
- **File inputs:** Never use `display:none` on file inputs — mobile browsers may not trigger `click()`. Use `absolute w-0 h-0 overflow-hidden opacity-0` instead.
- **Camera photos** may arrive as `image/heic`. Don't restrict file types client-side — let the backend validate.
- **Feedback:** Always show visible status (spinner, success/error message) for async actions. Mobile users can't see network tabs.
- **Tailwind breakpoints:** `sm:` = desktop-only behavior. Default (no prefix) = mobile-first.

## Clean Code Conventions
All agents and implementation must follow these rules:

- **Names & size:** Intent-revealing names. Functions ≤20 lines, 0–2 args. Single responsibility. DI.
- **Error handling:** Exceptions not return codes. No null returns — use Optional/empty collections.
- **Design:** No side effects. Command-query separation. Law of Demeter (no chaining).
- **Abstraction:** DRY but don't over-abstract. Delete dead code. Prefer well-named methods over comments. No Javadoc on private methods.
- **Tests:** Arrange-Act-Assert. One concept per test. Same quality as production code.
- **Discipline:** Boy Scout Rule. Minimal design. Only extract when clearly needed.

## Engineering Principles
1. Zero silent failures — every exception has a name and a visible effect
2. Every error path is traced — happy path is never the only path
3. Diagrams are mandatory for state machines and multi-step flows
4. Everything deferred is written down — no mental IOUs
5. Optimize for the developer reading this in 6 months
6. When in doubt, implement the complete version — marginal cost is zero
