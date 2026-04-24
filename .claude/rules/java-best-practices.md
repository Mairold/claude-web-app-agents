---
paths: "**/*.java"
---
# Java Best Practices

## Dependency Injection
- Always constructor injection — never field injection (`@Autowired` on fields)
- Use `@RequiredArgsConstructor` (Lombok) or explicit constructor
- Declare injected fields as `private final`

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

## Spring Boot
- `@RestController` + `@RequestMapping` at class level
- Return `ResponseEntity<>` from controllers for explicit HTTP status control
- `@Valid` on request body parameters
- `@Transactional` on service methods, not repository methods
- Prefer `application.yml` over `application.properties`
- Use `@ConfigurationProperties` for type-safe config binding

## Exceptions
- All custom exceptions MUST extend `RuntimeException` — never checked exceptions
- Create domain-specific exceptions (`OrderNotFoundException`, `InsufficientBalanceException`) — never throw generic `RuntimeException` or `IllegalArgumentException`
- Handle with `@ControllerAdvice` + `@ExceptionHandler` — one global handler per project
- Exception class per error category, not per method

## Code Quality
- Methods ≤20 lines
- Favor composition over inheritance
- Meaningful names — no abbreviations (`customer` not `cust`)
- Use `Objects.requireNonNull()` for null checks in constructors
