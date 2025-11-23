# TCA + Dependencies Integration Patterns

**Purpose**: Effective coordination between TCA state management and Dependencies injection.

## Core Integration Principles

### 1. Responsibility Boundaries
```swift
┌─────────────────┬──────────────────────────┬─────────────────┐
│ TCA Responsibility│ Dependencies Responsibility │ Integration     │
├─────────────────┼──────────────────────────┼─────────────────┤
│ UI State        │ External Services        │ @Dependency in │
│ User Actions    │ Platform APIs            │ reducers        │
│ View Logic      │ Shared Resources         │ Async effects   │
│ Navigation Flow │ Network Calls            │ Test mocking    │
└─────────────────┴──────────────────────────┴─────────────────┘
```

### 2. Communication Flow
```mermaid
graph TD
    A[TCA Reducer] -->|@Dependency| B[Dependency Client]
    B -->|Async Response| A
    A -->|State Change| C[SwiftUI View]
    C -->|User Action| A
```

## Pattern 1: API Client Integration

### Dependency Definition
```swift
import Dependencies

struct APIClient {
    var fetchUser: @Sendable (String) async throws -> User
    var updateUser: @Sendable (User) async throws -> User
    var deletePost: @Sendable (String) async throws -> Void
    var uploadImage: @Sendable (Data) async throws -> URL
}

extension APIClient: DependencyKey {
    static let liveValue = APIClient(
        fetchUser: { userID in
            let url = URL(string: "https://api.example.com/users/\(userID)")!
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(User.self, from: data)
        },
        updateUser: { user in
            let url = URL(string: "https://api.example.com/users/\(user.id)")!
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.httpBody = try JSONEncoder().encode(user)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let (data, _) = try await URLSession.shared.data(from: request)
            return try JSONDecoder().decode(User.self, from: data)
        },
        deletePost: { postID in
            let url = URL(string: "https://api.example.com/posts/\(postID)")!
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            _ = try await URLSession.shared.data(from: url)
        },
        uploadImage: { imageData in
            // Implementation for image upload
            let url = URL(string: "https://api.example.com/upload")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            // Set up multipart form data...
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(UploadResponse.self, from: data)
            return response.imageURL
        }
    )

    static let testValue = APIClient(
        fetchUser: { userID in
            if userID == "error" { throw APIError.userNotFound }
            return User.mock(id: userID)
        },
        updateUser: { user in
            User.mock(id: user.id, name: user.name, updated: true)
        },
        deletePost: { _ in
            // Mock successful deletion
        },
        uploadImage: { _ in
            URL(string: "https://example.com/mock-image.jpg")!
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

### TCA Reducer with API Integration
```swift
import ComposableArchitecture
import Dependencies

@Reducer
struct UserProfileFeature {
    @ObservableState
    struct State: Equatable {
        var user: User?
        var isEditing = false
        var isLoading = false
        var errorMessage: String?
        var uploadProgress: Double = 0.0
    }

    enum Action: Equatable {
        case loadUser(String)
        case userLoaded(User)
        case userLoadFailed(String)
        case startEditing
        case saveUser
        case userSaved(User)
        case userSaveFailed(String)
        case uploadPhoto(Data)
        case photoUploadProgress(Double)
        case photoUploadCompleted(URL)
        case photoUploadFailed(String)
        case cancelEditing
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

            case .startEditing:
                state.isEditing = true
                return .none

            case .saveUser:
                guard var user = state.user else { return .none }
                user.lastUpdated = dateClient.now()
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    do {
                        let savedUser = try await apiClient.updateUser(user)
                        await send(.userSaved(savedUser))
                    } catch {
                        await send(.userSaveFailed(error.localizedDescription))
                    }
                }

            case .userSaved(let user):
                state.user = user
                state.isLoading = false
                state.isEditing = false
                return .none

            case .userSaveFailed(let message):
                state.errorMessage = message
                state.isLoading = false
                return .none

            case .uploadPhoto(let imageData):
                state.uploadProgress = 0.0
                return .run { send in
                    await send(.photoUploadProgress(0.1))

                    do {
                        let imageURL = try await apiClient.uploadImage(imageData)
                        await send(.photoUploadProgress(1.0))
                        await send(.photoUploadCompleted(imageURL))
                    } catch {
                        await send(.photoUploadFailed(error.localizedDescription))
                    }
                }

            case .photoUploadProgress(let progress):
                state.uploadProgress = progress
                return .none

            case .photoUploadCompleted(let imageURL):
                guard var user = state.user else { return .none }
                user.profileImageURL = imageURL
                state.user = user
                state.uploadProgress = 0.0
                return .none

            case .photoUploadFailed(let message):
                state.errorMessage = message
                state.uploadProgress = 0.0
                return .none

            case .cancelEditing:
                state.isEditing = false
                return .none
            }
        }
    }
}
```

## Pattern 2: Shared Resource Management

### Authentication Dependency
```swift
struct AuthClient {
    var signIn: @Sendable (String, String) async throws -> AuthToken
    var signOut: @Sendable () async -> Void
    var currentUserID: @Sendable () -> String?
    var refreshToken: @Sendable () async throws -> AuthToken
    var register: @Sendable (String, String, String) async throws -> AuthToken
}

extension AuthClient: DependencyKey {
    static let liveValue = AuthClient(
        signIn: { email, password in
            // Live authentication implementation
            let url = URL(string: "https://api.example.com/auth/signin")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let body = ["email": email, "password": password]
            request.httpBody = try JSONEncoder().encode(body)

            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(AuthToken.self, from: data)
        },
        signOut: {
            // Clear stored token and navigate to login
            UserDefaults.standard.removeObject(forKey: "authToken")
        },
        currentUserID: {
            UserDefaults.standard.string(forKey: "currentUserID")
        },
        refreshToken: {
            // Token refresh implementation
            let storedToken = UserDefaults.standard.string(forKey: "authToken") ?? ""
            let url = URL(string: "https://api.example.com/auth/refresh")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(storedToken)", forHTTPHeaderField: "Authorization")

            let (data, _) = try await URLSession.shared.data(from: url)
            let newToken = try JSONDecoder().decode(AuthToken.self, from: data)
            UserDefaults.standard.set(newToken.value, forKey: "authToken")
            return newToken
        },
        register: { email, password, name in
            // User registration implementation
            let url = URL(string: "https://api.example.com/auth/register")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let body = ["email": email, "password": password, "name": name]
            request.httpBody = try JSONEncoder().encode(body)

            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(AuthToken.self, from: data)
        }
    )

    static let testValue = AuthClient(
        signIn: { email, password in
            if email == "error@test.com" { throw AuthError.invalidCredentials }
            return AuthToken.mock(value: "test-token")
        },
        signOut: {
            // Mock sign out
        },
        currentUserID: {
            "test-user-id"
        },
        refreshToken: {
            AuthToken.mock(value: "refreshed-test-token")
        },
        register: { _, _, _ in
            AuthToken.mock(value: "registered-test-token")
        }
    )
}

extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}
```

### Multiple TCA Features Using Shared Auth
```swift
@Reducer
struct AuthFeature {
    @ObservableState
    struct State: Equatable {
        var email = ""
        var password = ""
        var name = ""
        var isLoading = false
        var errorMessage: String?
        var isRegistering = false
    }

    enum Action: Equatable {
        case emailChanged(String)
        case passwordChanged(String)
        case nameChanged(String)
        case toggleRegisterMode
        case signInButtonTapped
        case registerButtonTapped
        case signOutButtonTapped
        case authenticationSucceeded(AuthToken)
        case authenticationFailed(String)
    }

    @Dependency(\.authClient) var authClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .emailChanged(let email):
                state.email = email
                return .none

            case .passwordChanged(let password):
                state.password = password
                return .none

            case .nameChanged(let name):
                state.name = name
                return .none

            case .toggleRegisterMode:
                state.isRegistering.toggle()
                state.errorMessage = nil
                return .none

            case .signInButtonTapped:
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    do {
                        let token = try await authClient.signIn(state.email, state.password)
                        await send(.authenticationSucceeded(token))
                    } catch {
                        await send(.authenticationFailed(error.localizedDescription))
                    }
                }

            case .registerButtonTapped:
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    do {
                        let token = try await authClient.register(state.name, state.email, state.password)
                        await send(.authenticationSucceeded(token))
                    } catch {
                        await send(.authenticationFailed(error.localizedDescription))
                    }
                }

            case .signOutButtonTapped:
                return .run { _ in
                    await authClient.signOut()
                }

            case .authenticationSucceeded(let token):
                state.isLoading = false
                return .none

            case .authenticationFailed(let message):
                state.errorMessage = message
                state.isLoading = false
                return .none
            }
        }
    }
}

// Another feature that depends on authentication state
@Reducer
struct ProtectedFeature {
    @ObservableState
    struct State: Equatable {
        var data: [DataItem] = []
        var isLoading = false
        var errorMessage: String?
    }

    enum Action {
        case loadData
        case dataLoaded([DataItem])
        case dataLoadFailed(String)
    }

    @Dependency(\.authClient) var authClient
    @Dependency(\.protectedAPIClient) var protectedAPIClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadData:
                guard authClient.currentUserID() != nil else {
                    return .none  // User not authenticated
                }

                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    do {
                        let data = try await protectedAPIClient.fetchProtectedData()
                        await send(.dataLoaded(data))
                    } catch {
                        await send(.dataLoadFailed(error.localizedDescription))
                    }
                }

            case .dataLoaded(let items):
                state.data = items
                state.isLoading = false
                return .none

            case .dataLoadFailed(let message):
                state.errorMessage = message
                state.isLoading = false
                return .none
            }
        }
    }
}
```

## Pattern 3: Advanced Dependency Composition

### Complex Service Composition
```swift
struct AnalyticsClient {
    var track: @Sendable (String, [String: Any]) async -> Void
    var setUser: @Sendable (User?) async -> Void
    var screenView: @Sendable (String) async -> Void
}

struct NotificationClient {
    var requestPermission: @Sendable () async -> Bool
    var scheduleNotification: @Sendable (String, String, Date) async -> String
    var cancelNotification: @Sendable (String) async -> Void
}

struct LocationClient {
    var requestLocationPermission: @Sendable () async -> Bool
    var getCurrentLocation: @Sendable () async -> Location?
    var startLocationUpdates: @Sendable () async -> AsyncStream<Location>
}

// Complex TCA feature using multiple dependencies
@Reducer
struct SocialMediaFeature {
    @ObservableState
    struct State: Equatable {
        var user: User?
        var posts: [Post] = []
        var isUploading = false
        var uploadProgress: Double = 0.0
        var locationPermissionGranted = false
        var notificationsEnabled = false
        var errorMessage: String?
    }

    enum Action {
        case loadUser
        case userLoaded(User)
        case loadPosts
        case postsLoaded([Post])
        case createPost(String, Data?)
        case postCreated(Post)
        case requestLocationPermission
        case locationPermissionGranted(Bool)
        case enableNotifications
        case notificationsEnabled(Bool)
        case uploadProgress(Double)
        case error(String)
    }

    @Dependency(\.apiClient) var apiClient
    @Dependency(\.authClient) var authClient
    @Dependency(\.analyticsClient) var analyticsClient
    @Dependency(\.notificationClient) var notificationClient
    @Dependency(\.locationClient) var locationClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadUser:
                guard let userID = authClient.currentUserID() else { return .none }
                return .run { send in
                    do {
                        let user = try await apiClient.fetchUser(userID)
                        await send(.userLoaded(user))
                    } catch {
                        await send(.error(error.localizedDescription))
                    }
                }

            case .userLoaded(let user):
                state.user = user
                return .run { _ in
                    await analyticsClient.setUser(user)
                }

            case .loadPosts:
                return .run { send in
                    do {
                        let posts = try await apiClient.fetchPosts()
                        await send(.postsLoaded(posts))
                    } catch {
                        await send(.error(error.localizedDescription))
                    }
                }

            case .postsLoaded(let posts):
                state.posts = posts
                return .none

            case .createPost(let text, let imageData):
                guard let user = state.user else { return .none }

                state.isUploading = true
                state.errorMessage = nil

                return .run { send in
                    // Track post creation
                    await analyticsClient.track("post_created", [
                        "user_id": user.id,
                        "has_image": imageData != nil
                    ])

                    do {
                        var post = Post(
                            id: UUID().uuidString,
                            author: user,
                            text: text,
                            timestamp: Date(),
                            imageURL: nil,
                            location: nil
                        )

                        // Upload image if provided
                        if let imageData = imageData {
                            await send(.uploadProgress(0.3))
                            let imageURL = try await apiClient.uploadImage(imageData)
                            post.imageURL = imageURL
                            await send(.uploadProgress(0.7))
                        }

                        // Add location if permission granted
                        if state.locationPermissionGranted {
                            if let location = try await locationClient.getCurrentLocation() {
                                post.location = location
                            }
                        }

                        await send(.uploadProgress(0.9))

                        let createdPost = try await apiClient.createPost(post)
                        await send(.uploadProgress(1.0))
                        await send(.postCreated(createdPost))

                        // Schedule notification if enabled
                        if state.notificationsEnabled {
                            _ = try? await notificationClient.scheduleNotification(
                                "Post Shared",
                                "Your post has been successfully shared!",
                                Date().addingTimeInterval(1)
                            )
                        }

                        await analyticsClient.track("post_completed", [
                            "post_id": createdPost.id,
                            "had_image": post.imageURL != nil,
                            "had_location": post.location != nil
                        ])

                    } catch {
                        await send(.error(error.localizedDescription))
                    }
                }

            case .postCreated(let post):
                state.posts.insert(post, at: 0)
                state.isUploading = false
                state.uploadProgress = 0.0
                return .none

            case .requestLocationPermission:
                return .run { send in
                    let granted = await locationClient.requestLocationPermission()
                    await send(.locationPermissionGranted(granted))
                }

            case .locationPermissionGranted(let granted):
                state.locationPermissionGranted = granted
                return .run { _ in
                    await analyticsClient.track("location_permission", [
                        "granted": granted
                    ])
                }

            case .enableNotifications:
                return .run { send in
                    let enabled = await notificationClient.requestPermission()
                    await send(.notificationsEnabled(enabled))
                }

            case .notificationsEnabled(let enabled):
                state.notificationsEnabled = enabled
                return .run { _ in
                    await analyticsClient.track("notifications_enabled", [
                        "enabled": enabled
                    ])
                }

            case .uploadProgress(let progress):
                state.uploadProgress = progress
                return .none

            case .error(let message):
                state.errorMessage = message
                state.isUploading = false
                state.uploadProgress = 0.0
                return .none
            }
        }
    }
}
```

## Testing TCA + Dependencies Integration

### Comprehensive Test Suite
```swift
import Testing
import ComposableArchitecture
import Dependencies

@Suite("TCA + Dependencies Integration Tests")
struct SocialMediaFeatureTests {
    @Test("Complete post creation flow")
    @MainActor
    func createPostWithImageAndLocation() async {
        let testUser = User.mock(id: "123")
        let testImageData = Data([1, 2, 3, 4]) // Mock image data

        let store = TestStore(initialState: SocialMediaFeature.State()) {
            SocialMediaFeature()
        } withDependencies: {
            $0.authClient.currentUserID = { "123" }
            $0.apiClient.fetchUser = { id in
                User.mock(id: id, name: "Test User")
            }
            $0.apiClient.uploadImage = { _ in
                URL(string: "https://example.com/image.jpg")!
            }
            $0.apiClient.createPost = { post in
                post
            }
            $0.locationClient.requestLocationPermission = { true }
            $0.locationClient.getCurrentLocation = {
                Location.mock(latitude: 37.7749, longitude: -122.4194)
            }
            $0.notificationClient.requestPermission = { true }
            $0.notificationClient.scheduleNotification = { _, _, _ in
                "notification-id"
            }
            // Mock analytics client to track calls
            $0.analyticsClient.track = { event, properties in
                // In real tests, you might verify these calls
                print("Analytics: \(event) - \(properties)")
            }
            $0.analyticsClient.setUser = { user in
                print("Analytics user set: \(user.id)")
            }
        }

        // Load user
        await store.send(.loadUser)
        await store.receive(.userLoaded(.mock(id: "123", name: "Test User")))

        // Request location permission
        await store.send(.requestLocationPermission)
        await store.receive(.locationPermissionGranted(true)) { state in
            state.locationPermissionGranted = true
        }

        // Enable notifications
        await store.send(.enableNotifications)
        await store.receive(.notificationsEnabled(true)) { state in
            state.notificationsEnabled = true
        }

        // Create post with image
        await store.send(.createPost("Test post with location and image", testImageData)) { state in
            state.isUploading = true
        }

        // Track upload progress
        await store.receive(.uploadProgress(0.3)) { state in
            state.uploadProgress = 0.3
        }

        await store.receive(.uploadProgress(0.7)) { state in
            state.uploadProgress = 0.7
        }

        await store.receive(.uploadProgress(0.9)) { state in
            state.uploadProgress = 0.9
        }

        await store.receive(.uploadProgress(1.0)) { state in
            state.uploadProgress = 1.0
        }

        // Post creation completed
        await store.receive(.postCreated(.mock(
            id: "post-123",
            text: "Test post with location and image",
            imageURL: URL(string: "https://example.com/image.jpg")
        ))) { state in
            state.isUploading = false
            state.uploadProgress = 0.0
            state.posts.insert(.mock(
                id: "post-123",
                text: "Test post with location and image",
                imageURL: URL(string: "https://example.com/image.jpg")
            ), at: 0)
        }

        // Verify final state
        #expect(store.state.posts.count == 1)
        #expect(store.state.posts.first?.text == "Test post with location and image")
        #expect(store.state.posts.first?.imageURL != nil)
        #expect(store.state.locationPermissionGranted == true)
        #expect(store.state.notificationsEnabled == true)
        #expect(store.state.isUploading == false)
    }

    @Test("Handle dependency failures gracefully")
    @MainActor
    func handleDependencyFailures() async {
        let store = TestStore(initialState: SocialMediaFeature.State()) {
            SocialMediaFeature()
        } withDependencies: {
            $0.authClient.currentUserID = { "123" }
            $0.apiClient.uploadImage = { _ in
                throw APIError.uploadFailed
            }
            $0.analyticsClient.track = { _, _ in }
        }

        await store.send(.createPost("Test post", Data())) { state in
            state.isUploading = true
        }

        await store.receive(.error("Upload failed")) { state in
            state.errorMessage = "Upload failed"
            state.isUploading = false
            state.uploadProgress = 0.0
        }

        #expect(store.state.errorMessage == "Upload failed")
        #expect(store.state.isUploading == false)
    }
}
```

## Performance Optimization

### Efficient Dependency Usage
```swift
@Reducer
struct OptimizedFeature {
    @ObservableState
    struct State: Equatable {
        var users: [String: User] = [:]  // Cache users by ID
        var posts: [Post] = []
        var isLoading = false
        var lastRefreshTime: Date?
    }

    enum Action {
        case loadPosts
        case postsLoaded([Post])
        case loadUserIfNeeded(String)
        case userLoaded(User)
        case refreshIfNeeded
    }

    @Dependency(\.apiClient) var apiClient
    @Dependency(\.dateClient) var dateClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadPosts:
                state.isLoading = true
                return .run { send in
                    let posts = try await apiClient.fetchPosts()
                    await send(.postsLoaded(posts))
                }

            case .postsLoaded(let posts):
                state.posts = posts
                state.isLoading = false
                state.lastRefreshTime = dateClient.now()
                return .none

            case .loadUserIfNeeded(let userID):
                // Only fetch user if not already cached
                guard state.users[userID] == nil else { return .none }

                return .run { send in
                    let user = try await apiClient.fetchUser(userID)
                    await send(.userLoaded(user))
                }

            case .userLoaded(let user):
                state.users[user.id] = user
                return .none

            case .refreshIfNeeded:
                let timeSinceLastRefresh = state.lastRefreshTime.map {
                    dateClient.now().timeIntervalSince($0)
                } ?? .infinity

                return timeSinceLastRefresh > 300 ? .send(.loadPosts) : .none
            }
        }
        .debounce(id: "loadUser", for: .milliseconds(100))
    }
}
```

---

**TCA + Dependencies Integration v1.0.0**

Comprehensive patterns for coordinating TCA state management with Dependencies injection.

*Last updated: November 21, 2025*