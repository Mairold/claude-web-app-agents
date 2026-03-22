---
globs: "**/*.swift"
---
# Swift Naming Conventions

## Types
- Classes, structs, enums, protocols: `PascalCase`
- Protocols: noun or adjective (`Drawable`, `DataSource`) — no `Protocol` suffix, no `I` prefix

## Methods & Properties
- Methods and properties: `camelCase`
- Mutating methods start with verb: `updateUser()`, `fetchData()`
- Booleans: `is`, `has`, `can`, `should` prefix — `isLoading`, `hasError`, `canSubmit`
- Constants: `camelCase` (Swift convention) — `maxRetryCount`, `defaultTimeout`

## Files
- One primary type per file, filename matches type name exactly
- Extensions: `TypeName+ProtocolName.swift` — `User+Codable.swift`
- View files: `NameView.swift`, ViewModel files: `NameViewModel.swift`

## Tests
- Test class: matches type under test + `Tests` suffix — `LoginViewModelTests`
- Test methods: `test_[scenario]_[expectedBehavior]()` — `test_login_withInvalidCredentials_showsError()`
