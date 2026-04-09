# Security Conventions

## Authentication
- Bearer token auth for API endpoints, session auth for UI endpoints
- Every new endpoint must be explicitly added to the security filter chain

## IDOR Protection
- All entity operations must verify ownership: `findByIdInProject(id, projectId)`
- All project endpoints must check membership: `projectService.requireRole(projectId, userId, role)`

## Sensitive Data
- Never log sensitive data (passwords, tokens, PII, session IDs, request bodies containing credentials) — sanitize or mask before logging
- Never leak stack traces or internal details to the client in production
