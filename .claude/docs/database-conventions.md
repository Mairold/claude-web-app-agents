# Database Conventions

## Entity / DTO Separation
- Entities must never reach controllers
- DTOs must contain no business logic
- Use records for DTOs (Java 21)

## Migrations (Flyway)
- snake_case migration filenames
- Never modify existing migrations
- All tables must have: `created_at`, `created_by`, `changed_at`, `changed_by`
