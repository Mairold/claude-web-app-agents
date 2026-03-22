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

## Security
- Secrets in Keychain with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`
- Never UserDefaults for sensitive data
- No PII in logs

## Naming
- Views: `NameView.swift`
- ViewModels: `NameViewModel.swift`
- Extensions: `Type+Protocol.swift`
