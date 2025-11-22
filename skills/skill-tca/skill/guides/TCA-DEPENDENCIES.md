# TCA Dependency Injection Patterns

> **Modern dependency injection patterns for The Composable Architecture (TCA 1.23.0+)**

## Dependency Injection & Modern TCA Patterns

### Why Modern Patterns Are Required (Swift 6.2 Strict Concurrency)

**This is not a style choice. This is a language requirement.**

Modern Swift 6.2 has introduced **strict concurrency enforcement** and macro-based tooling that makes old patterns incompatible:

**Old patterns (TCA 1.22 era):**
```swift
@Perception.Bindable
WithPerceptionTracking { ... }
Manual DependencyKey + extension DependencyValues
```

**Problem:** These patterns don't satisfy Swift 6.2 `Sendable` requirements. They will **not compile** with strict concurrency enabled.

**New patterns (TCA 1.23.0+ with Swift 6.2):**
```swift
@DependencyClient  // Macro handles Sendable + concurrency
@Bindable          // Optimized for strict concurrency
@ObservableState   // Works with Sendable requirements
```

**Why this matters:**
- Swift 6.2 requires `Sendable` on all public types in concurrent code
- TCA and its satellite libraries continuously evolve with macros and tools to solve concurrent programming challenges
- Libraries are continuously improving to adapt to language evolution
- Being on the current version is critical for adhering to the latest language and platform standards

## @DependencyClient Best Practices

### Defining Dependencies
```swift
// Modern dependency definition with @DependencyClient
@DependencyClient
struct APIClient {
  var fetchUser: @Sendable (ID) async throws -> User
  var updateUser: @Sendable (User) async throws -> User
  var deleteUser: @Sendable (ID) async throws -> Void
}
```

### Default Implementations
```swift
extension APIClient: DependencyKey {
  static let liveValue = APIClient(
    fetchUser: { id in
      // Live API call
    },
    updateUser: { user in
      // Live update call
    },
    deleteUser: { id in
      // Live delete call
    }
  )
}

extension DependencyValues {
  var apiClient: APIClient {
    get { self[APIClient.self] }
    set { self[APIClient.self] = newValue }
  }
}
```

### Testing Values
```swift
extension APIClient: TestDependencyKey {
  static let testValue = APIClient(
    fetchUser: { _ in .mock }
    // Test implementations
  )
}
```

## Dependency Usage Patterns

### In Reducers
```swift
@Reducer
struct UserFeature {
  @Dependency(\.apiClient) var apiClient
  @Dependency(\.continuousClock) var clock

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchUser(let id):
        state.isLoading = true
        return .run { send in
          // Use dependency
          let user = try await apiClient.fetchUser(id)
          await send(.userReceived(user))
        } catch: { error, send in
          await send(.userFetchFailed(error))
        }

      default:
        return .none
      }
    }
  }
}
```

### @Shared Dependencies
```swift
@Reducer
struct AuthFeature {
  @Shared var currentUser: User?
  @Dependency(\.authClient) var authClient

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .logout:
        return .run { _ in
          await authClient.logout()
          // Clear shared state
          self.currentUser = nil
        }

      default:
        return .none
      }
    }
  }
}
```

## Anti-Patterns to Avoid

### ❌ Don't Do This
```swift
// Bad: Direct API calls in reducer
@Reducer
struct BadFeature {
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchData:
        // Direct call - not testable
        URLSession.shared.dataTask(with: url)
        return .none
      }
    }
  }
}
```

### ❌ Don't Do This Either
```swift
// Bad: Manual dependency keys without @DependencyClient
struct MyAPIKey: DependencyKey {
  static let liveValue = MyAPIClient()
}
```

### ✅ Do This Instead
```swift
// Good: Use @DependencyClient
@DependencyClient
struct MyAPIClient {
  var fetchData: @Sendable () async throws -> Data
}
```

## Async/Await with Dependencies

### Proper Error Handling
```swift
@Reducer
struct NetworkFeature {
  @Dependency(\.apiClient) var apiClient

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .loadData:
        state.isLoading = true
        return .run { send in
          do {
            let data = try await apiClient.fetchData()
            await send(.dataLoaded(data))
          } catch {
            await send(.loadFailed(error))
          }
        }

      case .dataLoaded(let data):
        state.isLoading = false
        state.data = data
        return .none

      case .loadFailed(let error):
        state.isLoading = false
        state.error = error
        return .none
      }
    }
  }
}
```

## Mocking Dependencies

### Simple Mocks
```swift
extension APIClient {
  static let mock = APIClient(
    fetchUser: { _ in
      User.mock
    },
    updateUser: { user in
      user // Echo back for testing
    },
    deleteUser: { _ in
      // No-op for testing
    }
  )
}
```

### Complex Mocks with State
```swift
actor MockAPI {
  private var users: [ID: User] = [:]

  func fetchUser(_ id: ID) async throws -> User {
    guard let user = users[id] else {
      throw APIError.notFound
    }
    return user
  }

  func updateUser(_ user: User) async throws -> User {
    users[user.id] = user
    return user
  }
}
```

## Environment-Specific Dependencies

### Live vs Preview vs Test
```swift
@DependencyClient
struct DatabaseClient {
  var save: @Sendable (Model) async throws -> Void
  var load: @Sendable (ID) async throws -> Model
}

extension DatabaseClient: DependencyKey {
  static let liveValue = DatabaseClient(
    save: { model in
      // Real database save
    },
    load: { id in
      // Real database load
    }
  )
}

extension DatabaseClient: TestDependencyKey {
  static let testValue = DatabaseClient(
    save: { _ in /* no-op */ },
    load: { _ in .mock }
  )
}
```

Preview-specific values can be set in Xcode previews or SwiftUI previews.

## Platform-Specific Dependencies

### iOS-Specific
```swift
@DependencyClient
struct UIApplicationClient {
  var openURL: @Sendable (URL) -> Bool
}
```

### macOS-Specific
```swift
@DependencyClient
struct NSApplicationClient {
  var terminate: @Sendable () -> Void
}
```

### visionOS-Specific
```swift
@DependencyClient
struct ARSessionClient {
  var startSession: @Sendable () async throws -> Void
}
```