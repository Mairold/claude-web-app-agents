---
name: ui-ux
description: UI/UX design principles and patterns. Auto-invoke when building UI components, designing layouts, creating forms, working on navigation, accessibility, mobile responsiveness, or when asked to improve visual design or user experience.
---

# UI/UX Design Principles

## Core Design Laws

**Fitts's Law** — interactive targets must be large enough to tap/click easily.
- Minimum touch target: 44×44px (iOS) / 48×48dp (Android)
- Primary actions should be larger and more accessible than secondary

**Hick's Law** — more choices = longer decision time.
- Limit options per screen; use progressive disclosure
- Default to the most common choice; hide advanced options

**Jakob's Law** — users expect your UI to work like sites they already know.
- Follow platform conventions (back button, pull-to-refresh, swipe patterns)
- Don't reinvent standard patterns without good reason

**Miller's Law** — working memory holds ~7 items.
- Group related items (chunking)
- Break long forms into steps

**Law of Proximity** — elements close together are perceived as related.
- Group related controls; separate unrelated ones with whitespace

## Visual Hierarchy (CRAP Principles)

- **Contrast** — distinguish important from unimportant. Use size, weight, color.
- **Repetition** — consistent patterns build familiarity. Reuse components.
- **Alignment** — everything aligns to a grid. No floating elements.
- **Proximity** — related items are close; unrelated items have space between them.

## Typography

- Body: 16px minimum (never below 14px)
- Line height: 1.5× font size for body, 1.2× for headings
- Max line length: 65–75 characters
- Contrast ratio: 4.5:1 minimum (WCAG AA), 7:1 for small text

## Color

- Primary action: one dominant color only
- Destructive action: red, always with confirmation
- Never rely on color alone to convey meaning (add icon or text)
- Dark mode: don't use pure black (#000) — use dark gray (#1a1a1a or similar)

## Forms

- One column layout (never multi-column for primary forms)
- Labels above inputs, not placeholder-only
- Show errors inline, next to the field, immediately on blur
- Required fields: mark optional, not required (most fields should be required)
- Submit button: always at the bottom, full-width on mobile
- Disable submit only after first submission to prevent double-submit

## Feedback & States

Every async action needs visible feedback:
- **Loading** — spinner or skeleton, within 100ms of action
- **Success** — confirmation message, auto-dismiss after 3s
- **Error** — inline message, never just an alert dialog
- **Empty state** — explain why it's empty + call to action

## Mobile Patterns

- Bottom navigation for primary actions (thumb reach)
- Top bar for title + secondary actions
- Swipe gestures with visual affordance
- Sticky CTA button at bottom for conversion flows
- Never show desktop hover states on mobile

## Accessibility (WCAG AA minimum)

- All interactive elements keyboard navigable
- Focus visible at all times (never `outline: none` without alternative)
- Images have `alt` text; decorative images have `alt=""`
- Form inputs have associated `<label>` (not just placeholder)
- Error messages announced to screen readers (`aria-describedby`)
- Touch targets ≥44px

## Component Patterns

**Modal / Dialog**
- Trigger is clear (button with label, not just icon)
- Close on backdrop click + Escape key
- Focus trapped inside while open
- Return focus to trigger on close

**Navigation**
- Active state always visible
- Current page marked with `aria-current="page"`
- Mobile: hamburger only if ≤4 items don't fit; otherwise bottom nav

**Tables**
- Sortable columns have visible sort indicator
- Responsive: horizontal scroll or stacked layout on mobile
- Sticky header for long tables

**Notifications / Toasts**
- Position: top-right desktop, top-center mobile
- Auto-dismiss: 4s for success, never auto-dismiss for errors
- Max 3 visible at once

## Checklist Before Shipping UI

- [ ] Works on 375px wide (iPhone SE)
- [ ] Touch targets ≥44px
- [ ] Form submits on Enter key
- [ ] Loading states for all async actions
- [ ] Empty states handled
- [ ] Error states handled
- [ ] Keyboard navigable
- [ ] Color contrast passes WCAG AA
- [ ] No horizontal scroll on mobile
