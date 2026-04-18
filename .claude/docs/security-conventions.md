# Security Conventions

Shared baseline — applies to every project. Project-specific overrides, implementation details, or exemptions belong in `.claude/rules/project-security.md`, not here.

## Authentication
- Bearer token auth for API endpoints, session auth for UI endpoints
- Every new endpoint must be explicitly added to the security filter chain

## Sensitive Data
- Never log sensitive data (passwords, tokens, PII, session IDs, request bodies containing credentials) — sanitize or mask before logging
- Never leak stack traces or internal details to the client in production
