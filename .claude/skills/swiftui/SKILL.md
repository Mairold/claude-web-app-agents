---
name: swiftui
description: Swift and SwiftUI best practices for iOS/macOS development. Auto-invoke when working with .swift files, SwiftUI views, MVVM architecture, Swift Concurrency (async/await, actors), Combine, property wrappers (@State, @ObservedObject, @StateObject, @Observable), Keychain, or iOS-specific patterns.
---

# Swift / SwiftUI Best Practices

## Property Wrapper Selection

| Wrapper | When to use |
|---------|-------------|
| `@State` | Value types (String, Int, Bool, struct) owned by this view |
| `@StateObject` | Reference types (ObservableObject class) owned by this view |
| `@ObservedObject` | Reference types owned by a parent — injected in |
| `@EnvironmentObject` | App/scene-wide shared state, injected from root |
| `@Binding` | Two-way connection to a parent's `@State` |
| `@Observable` + `@State` | iOS 17+ preferred pattern for reference types |

## MVVM Pattern

```swift
@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var isLoading = false
    @Published var error: Error?

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }

    func login() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await authService.login(email: email)
        } catch {
            self.error = error
        }
    }
}
```

## Memory Management

```swift
// Weak delegate
weak var delegate: LoginDelegate?

// [weak self] in stored closure
let handler: () -> Void = { [weak self] in
    self?.handleTap()
}

// Combine with cancellables
var cancellables = Set<AnyCancellable>()
service.publisher
    .sink { [weak self] value in self?.update(value) }
    .store(in: &cancellables)
```

## Swift Concurrency

```swift
// .task modifier — auto-cancels on disappear
.task {
    await viewModel.loadData()
}

// Actor for shared mutable state
actor ImageCache {
    private var storage: [String: UIImage] = [:]
    func get(_ key: String) -> UIImage? { storage[key] }
    func set(_ key: String, _ image: UIImage) { storage[key] = image }
}
```

## Accessibility

```swift
// Correct — Button with label
Button { viewModel.submit() } label: {
    Label("Submit", systemImage: "checkmark")
}

// Correct — combined element
HStack { Image(systemName: "star.fill"); Text(item.title) }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(item.title), favourited")

// Correct — decorative image
Image("banner").accessibilityHidden(true)

// Wrong — invisible to VoiceOver
HStack { Image(systemName: "trash"); Text("Delete") }
    .onTapGesture { delete() }
```

## Keychain (secure storage)

```swift
// Store secrets in Keychain
let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrAccount as String: "auth-token",
    kSecValueData as String: tokenData,
    kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
]
SecItemAdd(query as CFDictionary, nil)

// Never store secrets in UserDefaults
UserDefaults.standard.set(token, forKey: "auth-token")
```

## Common Pitfalls

- `@State` with class type → use `@StateObject`
- Missing `[weak self]` in Combine `.sink` → memory leak
- `NavigationView` (deprecated) → use `NavigationStack`
- `ForEach(0..<items.count)` → use `ForEach(items)` with `Identifiable` models
- `onAppear` for async work → use `.task` (auto-cancels on disappear)
- `AnyView` for conditional views → use `@ViewBuilder` or `Group`
- `DateFormatter()` in `body` → create once outside view body
