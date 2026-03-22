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

## Security Config
- Every new endpoint must be explicitly added to the security filter chain
