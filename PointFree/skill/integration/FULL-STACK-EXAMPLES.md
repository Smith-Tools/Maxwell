# Point-Free Integration Patterns Database

**Purpose**: Curated patterns for combining multiple Point-Free frameworks effectively.

## TCA + Dependencies Integration Patterns

### Pattern 1: Basic Dependency Injection
```swift
@Reducer
struct Feature {
    @ObservableState
    struct State {
        var data: [Item] = []
        var isLoading = false
    }

    enum Action {
        case loadData
        case dataLoaded([Item])
    }

    @Dependency(\.dataClient) var dataClient
    @Dependency(\.dateClient) var dateClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadData:
                state.isLoading = true
                return .run { send in
                    let data = await dataClient.fetchItems()
                    await send(.dataLoaded(data))
                }

            case .dataLoaded(let items):
                state.data = items
                state.isLoading = false
                return .none
            }
        }
    }
}
```

**Dependencies Required**: `DataClient`, `DateClient`
**Test Values**: Mock data client, fixed date
**Integration Points**: Data loading, async operations

### Pattern 2: Shared State via Dependencies
```swift
// Global dependency container
struct AuthDependencyKey: DependencyKey {
    static let liveValue = AuthClient.live
    static let testValue = AuthClient.mock
}

extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthDependencyKey.self] }
        set { self[AuthDependencyKey.self] = newValue }
    }
}

// Multiple features accessing shared auth state
@Reducer
struct LoginFeature {
    @Dependency(\.authClient) var authClient

    // ... login logic using authClient
}

@Reducer
struct ProfileFeature {
    @Dependency(\.authClient) var authClient

    // ... profile logic using shared auth state
}
```

## TCA + Navigation Integration Patterns

### Pattern 1: Enum-Based Navigation with State
```swift
@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        var path = NavigationPathState<Path>()
        var home: HomeFeature.State = .init()
        var settings: SettingsFeature.State = .init()
    }

    enum Action {
        case home(HomeFeature.Action)
        case settings(SettingsFeature.Action)
        case path(NavigationPathAction<Path>)
    }

    enum Path {
        case settings
        case profile
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }

        Scope(state: \.settings, action: \.settings) {
            SettingsFeature()
        }

        NavigationReducer {
            Reduce { state, action in
                switch action {
                case .path(.push):
                    return .none
                default:
                    return .none
                }
            }
        } destination: { state in
            switch state {
            case .settings:
                CasePath(/AppFeature.Path.settings)
            case .profile:
                CasePath(/AppFeature.Path.profile)
            }
        }
    }
}
```

## Multi-Framework Integration Patterns

### Pattern 1: TCA + Dependencies + Navigation + Testing
```swift
// 1. Define dependencies with test values
struct APIClient {
    var fetchUser: @Sendable (ID) async throws -> User
}

extension APIClient: DependencyKey {
    static let liveValue = APIClient(
        fetchUser: { id in
            // Live implementation
            return try await APIService.shared.fetchUser(id)
        }
    )

    static let testValue = APIClient(
        fetchUser: { id in
            // Mock implementation
            return User.mock(id: id)
        }
    )
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}

// 2. TCA feature with navigation and dependencies
@Reducer
struct UserProfileFeature {
    @ObservableState
    struct State: Equatable {
        var user: User?
        var isLoading = false
        var errorMessage: String?
    }

    enum Action {
        case loadUser(ID)
        case userLoaded(User)
        case userLoadFailed(String)
        case editProfile
    }

    @Dependency(\.apiClient) var apiClient
    @Dependency(\.routerClient) var routerClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadUser(let id):
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    do {
                        let user = try await apiClient.fetchUser(id)
                        await send(.userLoaded(user))
                    } catch {
                        await send(.userLoadFailed(error.localizedDescription))
                    }
                }

            case .userLoaded(let user):
                state.user = user
                state.isLoading = false
                return .none

            case .userLoadFailed(let message):
                state.errorMessage = message
                state.isLoading = false
                return .none

            case .editProfile:
                return .run { _ in
                    await routerClient.route(to: .profileEdit)
                }
            }
        }
    }
}

// 3. Testing across all frameworks
@Suite("UserProfile Integration Tests")
struct UserProfileTests {
    @Test("Successfully load user profile")
    @MainActor
    func loadUserProfile() async {
        let store = TestStore(initialState: UserProfileFeature.State()) {
            UserProfileFeature()
        } withDependencies: {
            $0.apiClient.fetchUser = { id in
                User.mock(id: id, name: "Test User")
            }
            $0.routerClient.route = { _ in }
        }

        let userId = ID("123")

        await store.send(.loadUser(userId)) { state in
            state.isLoading = true
        }

        await store.receive(.userLoaded(.mock(id: userId, name: "Test User"))) { state in
            state.user = .mock(id: userId, name: "Test User")
            state.isLoading = false
        }
    }
}
```

## Anti-Pattern Detection

### Integration Anti-Patterns
1. **Direct Dependencies in Views**: Views should not directly use @Dependency
2. **State Duplication**: Don't duplicate state across frameworks
3. **Circular Dependencies**: Avoid A depending on B, B depending on A
4. **Mixed Navigation Patterns**: Don't mix SwiftUI navigation with TCA navigation haphazardly

### Validation Checklist for Integrations
- [ ] Each framework has a clear responsibility
- [ ] Dependencies are properly injected and testable
- [ ] Navigation state flows through TCA
- [ ] Testing covers integration points
- [ ] No direct coupling between non-related frameworks
- [ ] Error handling spans frameworks appropriately

## Decision Trees

### When to Use Multiple Frameworks
```
Need: User authentication and state management?
├─ Yes → TCA + Dependencies
│   ├─ Complex UI state? → TCA + Dependencies + Navigation
│   └─ Simple UI state? → TCA + Dependencies only
└─ No → Single framework approach

Need: Complex navigation with state?
├─ Yes → TCA + Navigation
│   ├─ External API calls? → TCA + Navigation + Dependencies
│   └─ Local state only? → TCA + Navigation only
└─ No → Consider simpler approach

Need: Testing across multiple frameworks?
├─ Yes → All involved frameworks + Snapshot Testing
└─ No → Framework-specific testing
```

## Performance Considerations

### Framework Order for Optimal Performance
1. **Dependencies**: Set up dependency graph first
2. **TCA**: Build state management on dependencies
3. **Navigation**: Add navigation layer on state
4. **Testing**: Test entire integration stack

### Memory Management
- Use `@Dependency` for shared resources
- Avoid retain cycles in TCA + Navigation
- Clean up navigation paths properly
- Test memory usage in integration scenarios