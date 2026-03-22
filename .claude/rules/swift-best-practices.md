---
globs: "**/*.swift"
---
# Swift Best Practices

## Memory Management
- Delegates: always `weak var delegate: ProtocolName?`
- Stored closures: always `[weak self]` capture list
- Combine `.sink`: always `[weak self]`, store in `Set<AnyCancellable>`
- Prefer `weak` over `unowned` unless object lifetime is guaranteed

## Concurrency (Swift 6)
- ViewModels: always `@MainActor class ViewModel: ObservableObject`
- Async tasks in views: use `.task {}` modifier, not `Task {}` in `onAppear`
- Never mix DispatchQueue with async/await in the same flow
- Types crossing actor boundaries must conform to `Sendable`
- Use structured concurrency (`async let`, `TaskGroup`) over unstructured `Task {}`

## Error Handling
- Never use force unwrap `!`, force cast `as!`, or `try!` in production
- Use `guard let` or `if let` for optional unwrapping
- Define custom error types conforming to `Error` with meaningful cases
- Use `Result<Success, Failure>` for async error propagation

## Code Quality
- Functions ≤40 lines
- No `print()` in production — use `Logger` from OSLog framework
- Prefer value types (structs, enums) over classes when possible
- Use `private`, `internal`, `public` access modifiers explicitly
- `final` on classes not designed for subclassing
