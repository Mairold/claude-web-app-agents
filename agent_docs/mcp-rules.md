# MCP Rules

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

## Story Sizing
- **Stories must be minimally testable units.** Never create a single story that spans DB migration + new service + UI changes for multiple concepts.
- Split large features into dependent stories with clear ordering. Each story should be independently deployable and testable.
- When creating stories via `create_story`, check if the scope covers more than one vertical slice. If it does, split and note dependencies.
- **Group related stories with a label.** When splitting a feature into multiple stories, apply a shared label (e.g. the feature name) to all of them.
