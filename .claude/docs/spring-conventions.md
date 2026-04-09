# Spring Boot Conventions

## Dependency Injection
- Constructor injection only — never `@Autowired` on fields
- Use `@RequiredArgsConstructor` (Lombok) or explicit constructor
- Declare injected fields as `private final`

## Exceptions
- All custom exceptions MUST extend `RuntimeException` — never checked exceptions
- Create domain-specific exceptions (`OrderNotFoundException`, `InsufficientBalanceException`) — never throw generic `RuntimeException` or `IllegalArgumentException`

## Global Exception Handling
- A `@ControllerAdvice` global exception handler is mandatory in every Spring Boot project
- Log every exception at WARN or ERROR level (ERROR for 5xx, WARN for 4xx)
- Use `log.error("message", exception)` — always include the exception object for stack trace
- Return a consistent error response DTO (e.g. `ErrorResponse` record with `status`, `message`, `timestamp`)

Also follow:
- Database: see `.claude/docs/database-conventions.md`
- Security: see `.claude/docs/security-conventions.md`
