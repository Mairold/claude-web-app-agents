# SvelteKit / Svelte 5 Conventions

## Runes
- `$state`, `$derived`, `$effect` MUST be in `.svelte` or `.svelte.js` files only
- Never in plain `.js` or `.ts` files — causes production breakage

## Shared State
- Shared state in `src/lib/stores/` as `.svelte.js` files
- Never use module-level variables in plain `.js` for reactive state

## API Calls
- All fetch calls through `src/lib/api/` — never inline in components
- All API errors must be logged (e.g. `console.error`) before surfacing to the user — no silent failures in catch blocks

## File Inputs
- Never `display:none` — use `absolute w-0 h-0 overflow-hidden opacity-0`

## SVG Icons
- Svelte components in `src/lib/icons/` accepting `class` prop
- Never inline SVG in pages
