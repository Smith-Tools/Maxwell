# TCA Testing Patterns

> **Comprehensive testing guidance for The Composable Architecture using Swift Testing**

## Testing Framework

- **Use Swift Testing framework** (`@Test`, `#expect()`) for all new code, not XCTest.
- Mark TCA tests with `@MainActor`.
- **Use `TestClock()` for deterministic time** (never `Date.constant()`).
- Use suite-level traits with `.dependencies { }` for shared setup.
- Use `expectNoDifference` for complex data comparison.

## Test Coverage Requirements

- **[STANDARD] Aim for 80%+ test coverage** on TCA reducers and business logic
  - Measure: `swift test --enable-code-coverage && xcrun llvm-cov report`
  - Priority: Cover all action paths, state transitions, and effect handling
  - Acceptable gaps: View rendering code, RealityKit entity setup, third-party library wrappers

- **[CRITICAL] 100% coverage required for:**
  - Public API boundaries (exposed to other modules/packages)
  - Critical business logic (authentication, payments, data persistence)
  - State mutations that could lead to inconsistencies

## Testing Patterns

### Reducer Testing
```swift
@Test("Login reducer processes successful authentication")
@MainActor
func loginSuccess() async {
  let store = TestStore(initialState: LoginFeature.State()) {
    LoginFeature()
  } withDependencies: {
    $0.authenticationClient.login = { _ in .success(User.mock) }
  }

  await store.send(.emailChanged("user@example.com")) {
    $0.email = "user@example.com"
  }

  await store.send(.passwordChanged("password123")) {
    $0.password = "password123"
  }

  await store.send(.loginButtonTapped) {
    $0.isLoading = true
  }

  await store.receive(.loginResponse(.success(User.mock))) {
    $0.isLoading = false
    $0.user = User.mock
  }
}
```

### @Shared State Testing
```swift
@Test("Shared state mutations propagate between features")
@MainActor
func sharedStatePropagation() async {
  let sharedUser = Shared(User.mock)

  let featureA = TestStore(initialState: FeatureA.State()) {
    FeatureA()
  } withDependencies: {
    $0.sharedUser = sharedUser
  }

  let featureB = TestStore(initialState: FeatureB.State()) {
    FeatureB()
  } withDependencies: {
    $0.sharedUser = sharedUser
  }

  // Feature A modifies shared user
  await featureA.send(.updateUserName("New Name")) {
    $0.sharedUser.wrappedValue.name = "New Name"
  }

  // Feature B sees the change
  await featureB.receive(.userChanged) {
    $0.displayName = "New Name"
  }
}
```

### Effect Testing
```swift
@Test("Async effects with proper cancellation")
@MainActor
func asyncEffectWithCancellation() async {
  let clock = TestClock()

  let store = TestStore(initialState: Feature.State()) {
    Feature()
  } withDependencies: {
    $0.continuousClock = clock
  }

  await store.send(.startAsyncWork) {
    $0.isLoading = true
  }

  // Advance clock but don't complete
  await clock.advance(by: .seconds(1))

  // Cancel the work
  await store.send(.cancelAsyncWork) {
    $0.isLoading = false
  }

  // Verify cancellation was handled
  await store.finish()
}
```

## Testing Anti-Patterns

### ❌ Don't Do This
```swift
// Bad: Testing view store details
@Test("Bad test - internal implementation")
func testViewStore() {
  let viewStore = ViewStore(store, observe: { $0 })
  // Testing @Bindable internals
}
```

### ✅ Do This Instead
```swift
// Good: Testing through public interface
@Test("Good test - reducer behavior")
func testReducerBehavior() async {
  await store.send(.publicAction) {
    // Test observable state changes only
  }
}
```

## Dependency Injection in Tests

### Test Dependencies
```swift
extension DependencyValues {
  @TestDependency
  var mockAPIClient: APIClient = .mock
}
```

### Suite-Level Setup
```swift
@Test("Suite of related tests", .dependencies {
  $0.apiClient = .mock
  $0.continuousClock = TestClock()
})
func authenticationTests() async {
  // All tests in this suite get the same dependencies
}
```

## Performance Testing

- **[STANDARD] Measure reducer performance** for complex state transitions
- **[GUIDANCE] Use `measure` blocks** for critical path operations
- **[ANTI-PATTERN] Don't test view rendering performance** in unit tests

## Integration Testing

- **[STANDARD] Test feature integration** when multiple features interact
- **[CRITICAL] Test @Shared state boundaries** between features
- **[GUIDANCE] Use end-to-end scenarios** for complete user workflows