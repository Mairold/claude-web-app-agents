# Spring Boot Conventions

## Dependency Injection
- Constructor injection only — never `@Autowired` on fields
- Use `@RequiredArgsConstructor` (Lombok) or explicit constructor
- Declare injected fields as `private final`

## Controllers & Services
- `@RestController` + `@RequestMapping` at class level
- Return `ResponseEntity<>` from controllers for explicit HTTP status control
- `@Valid` on request body parameters
- `@Transactional` on service methods, not repository methods

## Configuration
- Prefer `application.yml` over `application.properties`
- Use `@ConfigurationProperties` for type-safe config binding

## Global Exception Handling

Java-level exception rules (custom classes, hierarchy) are in `.claude/rules/java-best-practices.md` §Exceptions. This section covers the Spring-specific handler setup.

- A `@ControllerAdvice` global exception handler is mandatory in every Spring Boot project
- Log every exception at WARN or ERROR level (ERROR for 5xx, WARN for 4xx)
- Use `log.error("message", exception)` — always include the exception object for stack trace
- Return a consistent error response DTO (e.g. `ErrorResponse` record with `status`, `message`, `timestamp`)

Also follow:
- Database: see `.claude/docs/database-conventions.md`
- Security: see `.claude/docs/security-conventions.md`
