# Spring Boot Conventions

## Dependency Injection
- Constructor injection only — never `@Autowired` on fields
- Use `@RequiredArgsConstructor` (Lombok) or explicit constructor
- Declare injected fields as `private final`

## IDOR Protection
- All story/entity operations must verify ownership: `findByIdInProject(id, projectId)`
- All project endpoints must check membership: `projectService.requireRole(projectId, userId, role)`

## Entity / DTO Separation
- Entities must never reach controllers
- DTOs must contain no business logic
- Use records for DTOs (Java 21)

## Flyway
- snake_case migration filenames
- Never modify existing migrations
- All tables must have: `created_at`, `created_by`, `changed_at`, `changed_by`

## Exceptions
- All custom exceptions MUST extend `RuntimeException` — never checked exceptions
- Create domain-specific exceptions (`OrderNotFoundException`, `InsufficientBalanceException`) — never throw generic `RuntimeException` or `IllegalArgumentException`

## Global Exception Handling
- A `@ControllerAdvice` global exception handler is mandatory in every Spring Boot project
- Log every exception at WARN or ERROR level (ERROR for 5xx, WARN for 4xx)
- Use `log.error("message", exception)` — always include the exception object for stack trace
- **Never log sensitive data** (passwords, tokens, PII, session IDs, request bodies containing credentials) — sanitize or mask before logging
- Return a consistent error response DTO (e.g. `ErrorResponse` record with `status`, `message`, `timestamp`)
- Never leak stack traces or internal details to the client in production

## Security Config
- Every new endpoint must be explicitly added to the security filter chain
