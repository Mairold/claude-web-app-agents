# Swift / SwiftUI Conventions

## Memory
- Delegates: always `weak`
- Stored closures: always `[weak self]`
- Combine `.sink`: always `[weak self]` + store in `Set<AnyCancellable>`

## Concurrency
- ViewModels: `@MainActor class ViewModel: ObservableObject`
- Async in views: `.task {}` not `Task {}` in `onAppear`
- No mixing GCD and async/await

## Property Wrappers
- `@State` for value types this view owns
- `@StateObject` for reference types this view owns
- `@ObservedObject` for reference types injected from parent

## Error Handling & Logging
- Log every caught error using `Logger` (OSLog) at `.error` or `.fault` level
- Never silently discard errors in `catch` blocks — at minimum log
- Use a centralized error handler for network/API errors that logs before surfacing to UI

## Security
- Secrets in Keychain with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`
- Never UserDefaults for sensitive data
- For sensitive-data logging rules: see `.claude/docs/security-conventions.md`

## Naming
- Views: `NameView.swift`
- ViewModels: `NameViewModel.swift`
- Extensions: `Type+Protocol.swift`
