---
name: svelte-tailwind
description: SvelteKit 2 + Svelte 5 + Tailwind CSS v4 patterns and best practices. Auto-invoke when working with .svelte files, SvelteKit routing, Svelte 5 runes ($state, $derived, $effect), Tailwind styling, SSR, form actions, or load functions.
---

# SvelteKit 2 + Svelte 5 + Tailwind CSS v4

## Svelte 5 Runes

Runes MUST only be used in `.svelte` or `.svelte.js` files — never in plain `.js` or `.ts`.

```svelte
<script>
  let count = $state(0)
  let doubled = $derived(count * 2)

  $effect(() => {
    console.log('count changed:', count)
  })
</script>
```

Props use `$props()`:
```svelte
<script>
  let { title, onClose } = $props()
</script>
```

Two-way binding with `$bindable()`:
```svelte
<script>
  let { value = $bindable() } = $props()
</script>
```

## Shared State (Stores)

Shared state lives in `src/lib/stores/` as `.svelte.js` files — never module-level variables in plain `.js`.

```js
// src/lib/stores/user.svelte.js
let user = $state(null)
export function getUser() { return user }
export function setUser(u) { user = u }
```

## SvelteKit Data Flow

**Load functions** run on server by default:
```js
// +page.server.js
export async function load({ params, locals }) {
  const item = await db.getItem(params.id)
  if (!item) error(404)
  return { item }
}
```

**Form actions** handle mutations:
```js
export const actions = {
  default: async ({ request, locals }) => {
    const data = await request.formData()
    // validate and save
    return { success: true }
  }
}
```

**`use:enhance`** for progressive enhancement:
```svelte
<form method="POST" use:enhance={() => {
  submitting = $state(true)
  return async ({ result, update }) => {
    submitting = false
    await update()
  }
}}>
```

## Tailwind v4 Setup

```js
// vite.config.js — plugin order matters
import tailwindcss from '@tailwindcss/vite'
import { sveltekit } from '@sveltejs/kit/vite'

export default { plugins: [tailwindcss(), sveltekit()] }
```

```css
/* app.css */
@import "tailwindcss";
```

**Dynamic classes — always use full names:**
```svelte
<!-- ✅ correct -->
<div class:bg-blue-500={active} class:bg-gray-200={!active}>

<!-- ❌ wrong — gets purged -->
<div class="bg-{active ? 'blue' : 'gray'}-500">
```

## Mobile-First Breakpoints

- Default (no prefix) = mobile
- `sm:` = desktop-only behavior
- Never hover-only without touch fallback: use `sm:hover:` not `hover:`

## API Calls

All fetch calls go through `src/lib/api/` — never inline in components.

```js
// src/lib/api/stories.js
export async function getStory(id) {
  const res = await fetch(`/api/stories/${id}`)
  if (!res.ok) throw new Error('Failed')
  return res.json()
}
```

## File Inputs

Never `display:none` on file inputs — mobile browsers may not trigger `.click()`.
Use instead: `class="absolute w-0 h-0 overflow-hidden opacity-0"`

## SVG Icons

SVG icons are Svelte components in `src/lib/icons/` accepting a `class` prop. Never inline SVG in pages.

```svelte
<!-- src/lib/icons/ChevronDown.svelte -->
<script>
  let { class: className = '' } = $props()
</script>
<svg class={className} viewBox="0 0 24 24">...</svg>
```

## SSR Constraints

`$state`, `$derived`, `$effect` cannot run in SSR context:
- Server-only logic goes in `+page.server.js` / `+layout.server.js`
- Client-only logic uses `onMount` or `browser` check

```js
import { browser } from '$app/environment'
if (browser) { /* client-only */ }
```

## Common Issues

- CSS not loading in production → check Vite plugin order, CSS import in root layout
- Runes causing SSR errors → move to `.svelte` file or wrap in `browser` check
- Store not reactive → must be `.svelte.js`, not `.js`
