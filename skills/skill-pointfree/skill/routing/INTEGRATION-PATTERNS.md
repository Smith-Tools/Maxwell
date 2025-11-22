# Point-Free Integration Patterns

**Purpose**: Curated patterns for combining multiple Point-Free frameworks effectively.

## Core Integration Principles

### 1. Framework Responsibility Boundaries
```swift
// Clear separation of concerns
├─ TCA: UI state, user actions, view logic
├─ Dependencies: External services, platform APIs, shared resources
├─ Navigation: Screen flow, deep linking, navigation state
└─ Testing: Verification across all framework boundaries
```

### 2. Communication Protocols
- **TCA → Dependencies**: Through @DependencyClient in reducers
- **Dependencies → TCA**: Through dependency async responses
- **TCA → Navigation**: Through state-driven navigation APIs
- **Navigation → TCA**: Through navigation state changes

### 3. State Ownership Rules
- **TCA owns**: UI-specific state, user interaction state
- **Dependencies own**: Shared resources, external service state
- **Navigation owns**: Navigation stack, deep linking state
- **Testing owns**: Test configuration, mock setup

## Pattern 1: TCA + Dependencies Integration

### Basic Dependency Injection in TCA
```swift
import ComposableArchitecture
import Dependencies

@Reducer
struct UserProfileFeature {
    @ObservableState
    struct State: Equatable {
        var user: User?
        var isLoading = false
        var errorMessage: String?
    }

    enum Action: Equatable {
        case loadUser(userID: String)
        case userLoaded(User)
        case userLoadFailed(String)
        case retryButtonTapped
    }

    @Dependency(\.apiClient) var apiClient
    @Dependency(\.dateClient) var dateClient
    @Dependency(\.dismiss) var dismiss

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadUser(let userID):
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    do {
                        let user = try await apiClient.fetchUser(userID)
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

            case .retryButtonTapped:
                guard let userID = state.user?.id else { return .none }
                return .send(.loadUser(userID: userID))
            }
        }
    }
}
```

### Dependency Definition with Test Values
```swift
// Define the dependency client
struct APIClient {
    var fetchUser: @Sendable (String) async throws -> User
    var updateUser: @Sendable (User) async throws -> User
}

extension APIClient: DependencyKey {
    static let liveValue = APIClient(
        fetchUser: { id in
            // Live implementation with actual API calls
            let url = URL(string: "https://api.example.com/users/\(id)")!
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(User.self, from: data)
        },
        updateUser: { user in
            // Live implementation for updating users
            let url = URL(string: "https://api.example.com/users/\(user.id)")!
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.httpBody = try JSONEncoder().encode(user)
            let (data, _) = try await URLSession.shared.data(from: request)
            return try JSONDecoder().decode(User.self, from: data)
        }
    )

    static let testValue = APIClient(
        fetchUser: { id in
            // Mock implementation for testing
            if id == "error" {
                throw APIError.userNotFound
            }
            return User.mock(id: id)
        },
        updateUser: { user in
            // Mock implementation for testing
            return User.mock(id: user.id, name: user.name, updated: true)
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

### Testing TCA + Dependencies
```swift
import Testing
import ComposableArchitecture
import Dependencies

@Suite("UserProfile Feature Tests")
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
        }

        let userID = "123"

        await store.send(.loadUser(userID: userID)) { state in
            state.isLoading = true
        }

        await store.receive(.userLoaded(.mock(id: userID, name: "Test User"))) { state in
            state.user = .mock(id: userID, name: "Test User")
            state.isLoading = false
        }
    }

    @Test("Handle API error gracefully")
    @MainActor
    func loadUserProfileError() async {
        let store = TestStore(initialState: UserProfileFeature.State()) {
            UserProfileFeature()
        } withDependencies: {
            $0.apiClient.fetchUser = { _ in
                throw APIError.networkError
            }
        }

        await store.send(.loadUser(userID: "error")) { state in
            state.isLoading = true
        }

        await store.receive(.userLoadFailed("Network error")) { state in
            state.errorMessage = "Network error"
            state.isLoading = false
        }
    }
}
```

## Pattern 2: TCA + Navigation Integration

### Navigation-Driven TCA Architecture
```swift
import ComposableArchitecture
import SwiftNavigation

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var path = NavigationPathState<Destination>()
        var home: HomeFeature.State = .init()
        var profile: ProfileFeature.State = .init()
        var settings: SettingsFeature.State = .init()
    }

    enum Action: Equatable {
        case home(HomeFeature.Action)
        case profile(ProfileFeature.Action)
        case settings(SettingsFeature.Action)
        case path(NavigationPathAction<Destination>)
    }

    enum Destination: Equatable {
        case profile(userID: String)
        case settings
        case editProfile
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        .onChange(of: \.home.selectedUserID) { oldValue, newValue in
            Reduce { state, action in
                guard let userID = newValue else { return .none }
                state.path.append(.profile(userID: userID))
                return .none
            }
        }

        Scope(state: \.settings, action: \.settings) {
            SettingsFeature()
        }

        NavigationReducer { state, action in
            switch action {
            case .path(.element(_, .profile(let userID))):
                // Configure profile feature when navigating
                return .send(.profile(.loadUser(userID: userID)))

            case .path(.element(_, .editProfile)):
                // Setup edit profile state
                return .send(.profile(.enterEditMode))

            default:
                return .none
            }
        } destination: { state in
            switch state {
            case .profile(let userID):
                CasePath(/AppFeature.Action.profile)
                    .appending(path: /AppFeature.State.profile)
                    .appending(action: /AppFeature.Action.profile)
                    .map { ProfileFeature.State(userID: userID) } { _, _ in }

            case .settings:
                CasePath(/AppFeature.Action.settings)
                    .appending(path: /AppFeature.State.settings)
                    .appending(action: /AppFeature.Action.settings)

            case .editProfile:
                CasePath(/AppFeature.Action.profile)
                    .appending(path: /AppFeature.State.profile)
                    .appending(action: /AppFeature.Action.profile)
            }
        }
    }
}
```

### Deep Linking with TCA State
```swift
@Reducer
struct DeepLinkFeature {
    @ObservableState
    struct State: Equatable {
        var deepLink: URL?
        var appState: AppFeature.State = .init()
    }

    enum Action: Equatable {
        case handleDeepLink(URL)
        case app(AppFeature.Action)
        case deepLinkProcessed
    }

    @Dependency(\.deepLinkClient) var deepLinkClient

    var body: some Reducer<State, Action> {
        Scope(state: \.appState, action: \.app) {
            AppFeature()
        }

        Reduce { state, action in
            switch action {
            case .handleDeepLink(let url):
                state.deepLink = url

                if let destination = deepLinkClient.parseDestination(from: url) {
                    return .run { send in
                        await send(.app(.path(.push(destination))))
                        await send(.deepLinkProcessed)
                    }
                } else {
                    return .send(.deepLinkProcessed)
                }

            case .deepLinkProcessed:
                state.deepLink = nil
                return .none

            case .app:
                return .none
            }
        }
    }
}
```

## Pattern 3: Multi-Framework Testing Integration

### Integration Testing Across Framework Boundaries
```swift
import Testing
import ComposableArchitecture
import Dependencies

@Suite("Multi-Framework Integration Tests")
struct AppIntegrationTests {
    @Test("Complete user flow: Login → Profile → Settings")
    @MainActor
    func completeUserFlow() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        } withDependencies: {
            // Mock all dependencies
            $0.apiClient.fetchUser = { id in
                User.mock(id: id, name: "Test User", email: "test@example.com")
            }
            $0.apiClient.updateUser = { user in
                user
            }
            $0.authClient.signIn = { _ in
                AuthToken(value: "mock-token")
            }
            $0.authClient.currentUserID = "123"
        }

        // Step 1: Login flow
        await store.send(.auth(.signIn(email: "test@example.com", password: "password"))) { state in
            state.auth.isLoading = true
        }

        await store.receive(.auth(.signInSuccess(.init(value: "mock-token")))) { state in
            state.auth.isLoading = false
            state.auth.token = .init(value: "mock-token")
        }

        await store.receive(.auth(.loadCurrentUser)) { state in
            state.auth.isLoading = true
        }

        await store.receive(.auth(.currentUserLoaded(.mock(id: "123")))) { state in
            state.auth.currentUser = .mock(id: "123")
            state.auth.isLoading = false
        }

        // Step 2: Navigate to profile
        await store.send(.path(.push(.profile(userID: "123"))))

        await store.receive(.profile(.loadUser(userID: "123"))) { state in
            // Profile feature state would be set up here
        }

        // Step 3: Navigate to settings
        await store.send(.path(.push(.settings)))

        // Verify final state
        #expect(store.state.path.count == 2)
        #expect(store.state.auth.currentUser?.id == "123")
    }

    @Test("Error handling across framework boundaries")
    @MainActor
    func errorHandlingIntegration() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        } withDependencies: {
            // Configure dependency to return error
            $0.apiClient.fetchUser = { _ in
                throw APIError.networkError
            }
        }

        // Trigger error scenario
        await store.send(.profile(.loadUser(userID: "error-user")))

        // Verify error propagates correctly through TCA state
        await store.receive(.profile(.userLoadFailed("Network error"))) { state in
            // Check that error state is properly managed
            // and UI would show appropriate error message
        }
    }
}
```

## Pattern 4: Performance-Optimized Integration

### Efficient State Updates Across Frameworks
```swift
@Reducer
struct OptimizedFeature {
    @ObservableState
    struct State: Equatable {
        var posts: [Post] = []
        var selectedPost: Post?
        var isLoading = false
        var lastUpdated: Date = .distantPast

        // Computed property that depends on multiple state aspects
        var canRefresh: Bool {
            !isLoading && Date().timeIntervalSince(lastUpdated) > 30
        }
    }

    enum Action {
        case loadPosts
        case postsLoaded([Post])
        case selectPost(Post?)
        case refreshIfNeeded
    }

    @Dependency(\.apiClient) var apiClient
    @Dependency(\.dateClient) var dateClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadPosts:
                guard state.canRefresh else { return .none }
                state.isLoading = true
                return .run { send in
                    let posts = try await apiClient.fetchPosts()
                    await send(.postsLoaded(posts))
                }

            case .postsLoaded(let posts):
                state.posts = posts
                state.isLoading = false
                state.lastUpdated = dateClient.now()
                return .none

            case .selectPost(let post):
                state.selectedPost = post
                return .none

            case .refreshIfNeeded:
                return state.canRefresh ? .send(.loadPosts) : .none
            }
        }
        .debounce(id: "loadPosts", for: .milliseconds(300))
    }
}
```

## Anti-Pattern Detection

### Common Integration Anti-Patterns

#### 1. Framework Boundary Violations
```swift
// ❌ ANTI-PATTERN: Direct dependency usage in views
struct UserProfileView: View {
    @Dependency(\.apiClient) var apiClient  // WRONG: Views shouldn't use dependencies directly

    var body: some View {
        // ...
    }
}

// ✅ CORRECT: Dependencies only in reducers
@Reducer
struct UserProfileFeature {
    @Dependency(\.apiClient) var apiClient  // CORRECT: Dependencies in reducers

    // ...
}
```

#### 2. State Duplication
```swift
// ❌ ANTI-PATTERN: Duplicating state across frameworks
@Reducer
struct Feature {
    struct State {
        var user: User?           // TCA state
        var currentUser: User?    // Duplicated state - WRONG
    }
}

// ✅ CORRECT: Single source of truth
@Reducer
struct Feature {
    struct State {
        var user: User?           // Single source of truth
    }
}
```

#### 3. Circular Dependencies
```swift
// ❌ ANTI-PATTERN: Circular dependency chain
APIClient -> UserManager -> AuthClient -> APIClient  // WRONG

// ✅ CORRECT: Clear dependency hierarchy
Core Services -> Business Logic -> UI Layer
```

## Integration Validation Checklist

### Before Implementing Integration
- [ ] Framework responsibilities are clearly defined
- [ ] No circular dependencies between frameworks
- [ ] State ownership is unambiguous
- [ ] Communication protocols are established

### During Implementation
- [ ] Dependencies are properly injected
- [ ] State updates flow through correct channels
- [ ] Error handling spans framework boundaries
- [ ] Performance considerations are addressed

### After Implementation
- [ ] Integration tests cover all framework boundaries
- [ ] End-to-end tests validate complete workflows
- [ ] Performance tests verify acceptable behavior
- [ ] Memory usage is optimized across frameworks

---

**Integration Patterns v1.0.0**

Curated patterns for effective Point-Free framework integration.

*Last updated: November 21, 2025*