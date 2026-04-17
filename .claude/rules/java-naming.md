---
paths: "**/*.java"
---
# Java Naming Conventions

## Classes & Interfaces
- Classes: `PascalCase` — `OrderService`, `UserRepository`
- Interfaces: `PascalCase`, no `I` prefix — `PaymentGateway` not `IPaymentGateway`
- Enums: `PascalCase` type, `UPPER_SNAKE_CASE` constants

## Methods & Variables
- Methods: `camelCase`, start with verb — `processOrder()`, `findByEmail()`
- Variables: `camelCase` — `orderTotal`, `customerName`
- Booleans: `is`, `has`, `can` prefix — `isActive`, `hasPermission()`
- Constants: `UPPER_SNAKE_CASE` — `MAX_RETRY_COUNT`

## Packages
- Lowercase only, no underscores — `com.company.project.module`
- Layers: `web`, `service`, `repository`, `domain`, `config`, `exception`, `dto`

## Tests
- Class: matches class under test + `Test` suffix — `OrderServiceTest`
- Methods: descriptive — `should_ReturnOrder_When_ValidIdProvided()`
