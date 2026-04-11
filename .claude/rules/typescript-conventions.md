# TypeScript Naming Conventions

## Fields & Properties

- Always use `camelCase` for field names, interface properties, and variables
- Never use `snake_case` in TypeScript — if the API returns snake_case, alias in the SQL query or map at the API boundary
- Booleans: `is`, `has`, `can` prefix — `isActive`, `hasVideo`, `canSubmit`

## Types & Interfaces

- Use `PascalCase` for types, interfaces, and enums
- Prefer `interface` over `type` for object shapes
- Use `type` for unions, intersections, and mapped types
