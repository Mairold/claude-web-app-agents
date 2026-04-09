# Mobile Guidelines

- **No hover-only interactions.** Anything behind `hover:` must also work on touch. Use `sm:opacity-0 sm:group-hover:opacity-100` so elements are always visible on mobile but hover-revealed on desktop.
- **File inputs:** Never use `display:none` on file inputs — mobile browsers may not trigger `click()`. Use `absolute w-0 h-0 overflow-hidden opacity-0` instead.
- **Camera photos** may arrive as `image/heic`. Don't restrict file types client-side — let the backend validate.
- **Feedback:** Always show visible status (spinner, success/error message) for async actions. Mobile users can't see network tabs.
- **Tailwind breakpoints:** `sm:` = desktop-only behavior. Default (no prefix) = mobile-first.
