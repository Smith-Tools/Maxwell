# Point-Free Anti-Patterns Detection

**Purpose**: Identify and prevent common anti-patterns when using multiple Point-Free frameworks together.

## Anti-Pattern Categories

### 1. Framework Boundary Violations

#### Anti-Pattern 1.1: Direct Dependency Usage in Views
```swift
// ❌ ANTI-PATTERN
struct UserProfileView: View {
    @Dependency(\.apiClient) var apiClient  // WRONG: Views shouldn't use dependencies

    var body: some View {
        Button("Load User") {
            Task {
                let user = try await apiClient.fetchUser("123")  // WRONG: Direct API call
            }
        }
    }
}

// ✅ CORRECT PATTERN
@Reducer
struct UserProfileFeature {
    @Dependency(\.apiClient) var apiClient  // CORRECT: Dependencies in reducers

    enum Action {
        case loadUser(String)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadUser(let id):
                return .run { send in
                    let user = try await apiClient.fetchUser(id)
                    // Handle response
                }
            }
        }
    }
}

struct UserProfileView: View {
    @Bindable var store: StoreOf<UserProfileFeature>

    var body: some View {
        Button("Load User") {
            store.send(.loadUser("123"))  // CORRECT: Send action to reducer
        }
    }
}
```

#### Anti-Pattern 1.2: State Duplication Across Frameworks
```swift
// ❌ ANTI-PATTERN
@Reducer
struct AppFeature {
    struct State {
        var tcaUser: User?        // TCA state
        var dependencyUser: User?  // Duplicate state - WRONG
        var navigationUser: User?  // Triplicate state - WRONG
    }
}

// ✅ CORRECT PATTERN
@Reducer
struct AppFeature {
    struct State {
        var user: User?           // Single source of truth
    }
}
```

#### Anti-Pattern 1.3: Circular Dependencies Between Frameworks
```swift
// ❌ ANTI-PATTERN
struct APIClient {
    var fetchUser: (AuthClient) async throws -> User  // WRONG: Circular dependency
}

struct AuthClient {
    var authenticate: (APIClient) async throws -> Token  // WRONG: Circular dependency
}

// ✅ CORRECT PATTERN
struct APIClient {
    var fetchUser: @Sendable (String) async throws -> User  // CORRECT: Independent
}

struct AuthClient {
    var authenticate: @Sendable (String, String) async throws -> Token  // CORRECT: Independent
}
```

### 2. Navigation Integration Anti-Patterns

#### Anti-Pattern 2.1: Mixed Navigation Paradigms
```swift
// ❌ ANTI-PATTERN
struct MixedNavigationView: View {
    @State private var path = NavigationPath()        // SwiftUI navigation
    @Bindable var store: StoreOf<TCAFeature>          // TCA state

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                // Some navigation driven by TCA
                Button("TCA Navigate") {
                    store.send(.navigate)  // TCA navigation
                }

                // Some navigation driven by SwiftUI
                Button("SwiftUI Navigate") {
                    path.append("destination")  // SwiftUI navigation - WRONG
                }
            }
        }
    }
}

// ✅ CORRECT PATTERN
@Reducer
struct UnifiedNavigationFeature {
    struct State {
        var path = NavigationPathState<Destination>()
    }

    enum Action {
        case navigateToDestination
    }

    enum Destination {
        case destination
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .navigateToDestination:
                state.path.append(.destination)  // CORRECT: Single navigation source
                return .none
            }
        }
    }
}
```

#### Anti-Pattern 2.2: State-Driven Navigation Without Proper Structure
```swift
// ❌ ANTI-PATTERN
@Reducer
struct PoorNavigationFeature {
    struct State {
        var showSettings = false
        var showProfile = false
        var showHelp = false
        // ... 20 more boolean flags - WRONG
    }

    enum Action {
        case showSettingsToggled
        case showProfileToggled
        // ... 20 more actions - WRONG
    }
}

// ✅ CORRECT PATTERN
@Reducer
struct GoodNavigationFeature {
    struct State {
        var path = NavigationPathState<Destination>()
    }

    enum Action {
        case path(NavigationPathAction<Destination>)
    }

    enum Destination {
        case settings
        case profile
        case help
        // ... all destinations in one enum - CORRECT
    }
}
```

### 3. Dependency Integration Anti-Patterns

#### Anti-Pattern 3.1: Direct System Calls in Reducers
```swift
// ❌ ANTI-PATTERN
@Reducer
struct DirectSystemCallsFeature {
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadData:
                return .run { send in
                    let now = Date()  // WRONG: Direct system call
                    let uuid = UUID()  // WRONG: Direct system call
                    let data = try await URLSession.shared.data(from: url)  // WRONG: Direct API call
                    // ...
                }
            }
        }
    }
}

// ✅ CORRECT PATTERN
@Reducer
struct ProperDependencyFeature {
    @Dependency(\.dateClient) var dateClient
    @Dependency(\.uuidClient) var uuidClient
    @Dependency(\.apiClient) var apiClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadData:
                return .run { send in
                    let now = dateClient.now()  // CORRECT: Through dependency
                    let uuid = uuidClient.generate()  // CORRECT: Through dependency
                    let data = try await apiClient.fetchData()  // CORRECT: Through dependency
                    // ...
                }
            }
        }
    }
}
```

#### Anti-Pattern 3.2: Missing Test Values for Dependencies
```swift
// ❌ ANTI-PATTERN
struct PartialAPIClient {
    var fetchUser: @Sendable (String) async throws -> User
    var updateUser: @Sendable (User) async throws -> User
}

extension PartialAPIClient: DependencyKey {
    static let liveValue = PartialAPIClient(
        fetchUser: { /* live implementation */ },
        updateUser: { /* live implementation */ }
    )
    // WRONG: No testValue - makes testing impossible
}

// ✅ CORRECT PATTERN
struct CompleteAPIClient {
    var fetchUser: @Sendable (String) async throws -> User
    var updateUser: @Sendable (User) async throws -> User
}

extension CompleteAPIClient: DependencyKey {
    static let liveValue = CompleteAPIClient(
        fetchUser: { /* live implementation */ },
        updateUser: { /* live implementation */ }
    )

    static let testValue = CompleteAPIClient(
        fetchUser: { id in User.mock(id: id) },  // CORRECT: Test implementation
        updateUser: { user in user }             // CORRECT: Test implementation
    )
}
```

### 4. State Management Anti-Patterns

#### Anti-Pattern 4.1: @Shared State with Multiple Writers
```swift
// ❌ ANTI-PATTERN
@Reducer
struct FeatureA {
    @Shared var sharedState: SharedState  // WRITER 1

    enum Action {
        case updateSharedState(String)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateSharedState(let value):
                sharedState.value = value  // WRONG: Multiple writers
                return .none
            }
        }
    }
}

@Reducer
struct FeatureB {
    @Shared var sharedState: SharedState  // WRITER 2 - WRONG

    enum Action {
        case updateSharedState(Int)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateSharedState(let value):
                sharedState.value = String(value)  // WRONG: Multiple writers - race condition!
                return .none
            }
        }
    }
}

// ✅ CORRECT PATTERN
@Reducer
struct SharedStateOwner {  // SINGLE WRITER
    @Shared var sharedState: SharedState

    enum Action {
        case updateFromFeatureA(String)
        case updateFromFeatureB(Int)
        case externalUpdate(String)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateFromFeatureA(let value):
                sharedState.value = value  // CORRECT: Single writer
                return .none
            case .updateFromFeatureB(let value):
                sharedState.value = String(value)  // CORRECT: Single writer
                return .none
            case .externalUpdate(let value):
                sharedState.value = value  // CORRECT: Single writer
                return .none
            }
        }
    }
}

@Reducer
struct FeatureA {
    @SharedReader var sharedState: SharedState  // READER ONLY

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .someAction:
                // Can read from sharedState
                let currentValue = sharedState.value
                // Must send action to owner to update
                return .send(.delegate(.requestSharedUpdate("new-value")))
            }
        }
    }
}
```

#### Anti-Pattern 4.2: Unnecessary @Shared Usage
```swift
// ❌ ANTI-PATTERN
@Reducer
struct OverSharedFeature {
    @Shared var localCounter: SharedState  // WRONG: Not shared between features
    @Shared var localText: SharedState    // WRONG: Not shared between features
    @Shared var localFlag: SharedState    // WRONG: Not shared between features
}

// ✅ CORRECT PATTERN
@Reducer
struct ProperStateFeature {
    @ObservableState
    struct State {  // CORRECT: Local state in State struct
        var counter = 0
        var text = ""
        var flag = false
    }
}
```

### 5. Testing Anti-Patterns

#### Anti-Pattern 5.1: Testing Without Dependency Mocking
```swift
// ❌ ANTI-PATTERN
@Suite("Poor Tests")
struct PoorTests {
    @Test("Test with real dependencies")
    func testWithRealDependencies() async {
        let store = TestStore(initialState: Feature.State()) {
            Feature()  // WRONG: Using real dependencies in tests
        }

        await store.send(.loadData)
        // Test depends on real API, network, timing - WRONG
    }
}

// ✅ CORRECT PATTERN
@Suite("Good Tests")
struct GoodTests {
    @Test("Test with mocked dependencies")
    func testWithMockedDependencies() async {
        let store = TestStore(initialState: Feature.State()) {
            Feature()
        } withDependencies: {
            $0.apiClient.fetchData = { .mock() }  // CORRECT: Mocked dependencies
            $0.dateClient.now = { Date(timeIntervalSince1970: 1234567890) }  // CORRECT: Deterministic
        }

        await store.send(.loadData)
        await store.receive(.dataLoaded(.mock()))  // CORRECT: Predictable results
    }
}
```

#### Anti-Pattern 5.2: Missing Integration Tests
```swift
// ❌ ANTI-PATTERN: Only unit tests
@Suite("Incomplete Testing")
struct IncompleteTests {
    @Test("Test TCA reducer in isolation")
    func testTCAReducer() { /* TCA only test */ }

    @Test("Test dependency client in isolation")
    func testDependencyClient() { /* Dependency only test */ }

    // WRONG: No integration tests
}

// ✅ CORRECT PATTERN: Include integration tests
@Suite("Complete Testing")
struct CompleteTests {
    @Test("Test TCA reducer in isolation")
    func testTCAReducer() { /* TCA only test */ }

    @Test("Test dependency client in isolation")
    func testDependencyClient() { /* Dependency only test */ }

    @Test("Test TCA + Dependencies integration")
    func testIntegration() async {
        let store = TestStore(initialState: Feature.State()) {
            Feature()
        } withDependencies: {
            $0.apiClient.fetchData = { .mock() }
        }

        await store.send(.loadData)  // CORRECT: Tests integration
        await store.receive(.dataLoaded(.mock()))
    }

    @Test("Test complete user flow")
    func testCompleteFlow() async {
        // CORRECT: End-to-end integration test
    }
}
```

## Anti-Pattern Detection Checklist

### Before Implementing
- [ ] Am I using @Dependency in a SwiftUI view?
- [ ] Am I making direct API calls in views?
- [ ] Am I duplicating state across frameworks?
- [ ] Do I have circular dependencies?
- [ ] Am I mixing navigation paradigms?

### During Implementation
- [ ] Am I making direct system calls (Date(), UUID()) in reducers?
- [ ] Do all my dependencies have test values?
- [ ] Am I writing to @Shared from multiple locations?
- [ ] Is my @Shared state really shared between features?
- [ ] Am I using boolean flags for complex navigation?

### During Testing
- [ ] Am I testing with real dependencies?
- [ ] Do I have integration tests for framework boundaries?
- [ ] Am I using TestClock for time-dependent tests?
- [ ] Do I test failure scenarios?

## Performance Anti-Patterns

### Anti-Pattern 6.1: Inefficient State Updates
```swift
// ❌ ANTI-PATTERN
@Reducer
struct InefficientFeature {
    struct State {
        var items: [Item] = []
        var filteredItems: [Item] = []  // WRONG: Derived state in State struct
    }

    enum Action {
        case addItem(Item)
        case filterChanged(String)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .addItem(let item):
                state.items.append(item)
                state.filteredItems = state.items.filter { $0.matches }  // WRONG: Recompute every time
                return .none
            case .filterChanged(let filter):
                state.filteredItems = state.items.filter { $0.matches(filter) }  // WRONG: Every keystroke
                return .none
            }
        }
    }
}

// ✅ CORRECT PATTERN
@Reducer
struct EfficientFeature {
    struct State {
        var items: [Item] = []
        var filterText = ""
    }

    enum Action {
        case addItem(Item)
        case filterChanged(String)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .addItem(let item):
                state.items.append(item)  // CORRECT: Only update what changed
                return .none
            case .filterChanged(let filter):
                state.filterText = filter  // CORRECT: Only update what changed
                return .none
            }
        }
    }

    // CORRECT: Computed property for derived state
    var filteredItems: (State) -> [Item] = { state in
        state.items.filter { $0.matches(state.filterText) }
    }
}

struct EfficientView: View {
    @Bindable var store: StoreOf<EfficientFeature>

    var body: some View {
        List(store.filteredItems(store.state), id: \.id) { item in  // CORRECT: Compute in view
            Text(item.name)
        }
    }
}
```

---

**Point-Free Anti-Patterns v1.0.0**

Comprehensive guide to avoiding common pitfalls in multi-framework Point-Free development.

*Last updated: November 21, 2025*