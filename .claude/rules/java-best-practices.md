---
paths: "**/*.java"
---
# Java Best Practices

## Modern Java (21+)
- Use records for DTOs and immutable data carriers
- Use pattern matching for `instanceof`
- Use text blocks for multi-line SQL, JSON, templates
- Use switch expressions with arrow syntax
- Prefer `var` for local variables when type is obvious from context

## Collections & Optional
- Prefer `List.of()`, `Set.of()`, `Map.of()` for immutable collections
- Use `Optional` for return types that may be absent — never for fields or parameters
- Use Streams for data transformation, not for simple iterations

## Exceptions
- All custom exceptions MUST extend `RuntimeException` — never checked exceptions
- Create domain-specific exceptions (`OrderNotFoundException`, `InsufficientBalanceException`) — never throw generic `RuntimeException` or `IllegalArgumentException`
- Exception class per error category, not per method
- Spring-based global handler setup (`@ControllerAdvice`, log levels, error DTO): see `.claude/docs/spring-conventions.md`

## Code Quality
- Methods ≤20 lines
- Favor composition over inheritance
- Meaningful names — no abbreviations (`customer` not `cust`)
- Use `Objects.requireNonNull()` for null checks in constructors
- **No Javadoc** — well-named methods, classes, and tests serve as documentation. For public HTTP APIs use OpenAPI annotations (`@Operation`, `@Parameter`), not Javadoc.
