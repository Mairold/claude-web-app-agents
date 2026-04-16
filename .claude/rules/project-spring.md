# Spring — project-specific rules

spring-reviewer also checks:
- `.claude/docs/database-conventions.md`
- `.claude/docs/security-conventions.md`

## Domain Exceptions
- All custom exceptions MUST extend `RuntimeException` — never checked exceptions
- Use domain-specific names: `OrderNotFoundException`, `InsufficientBalanceException`
  — never throw generic `RuntimeException` or `IllegalArgumentException`
- Handle with `@ControllerAdvice` + `@ExceptionHandler` — one global handler per project
- Exception class per error category, not per method
