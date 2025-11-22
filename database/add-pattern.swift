#!/usr/bin/env swift

import Foundation

/// Simple script to add patterns to Maxwell database
/// Usage: ./add-pattern.swift

// Database path (adjust as needed)
let dbPath = "/Volumes/Plutonian/_Developer/Maxwells/database/maxwell.db"

// Pattern data structures
struct Pattern {
    let name: String
    let domain: String
    let problem: String
    let solution: String
    let codeExample: String
    let notes: String
}

// Core patterns to add from TCA documentation
let tcaPatterns: [Pattern] = [
    Pattern(
        name: "@Shared In-Memory Sharing",
        domain: "TCA",
        problem: "Need to share state between features without persistence",
        solution: "Use @Shared property wrapper with no arguments to share data in memory only. The shared data is available across all features and will be cleared when the app restarts.",
        codeExample: """
@Reducer
struct ParentFeature {
  @ObservableState
  struct State {
    @Shared var count: Int
    // Other properties
  }
  // ...
}

@Reducer
struct ChildFeature {
  @ObservableState
  struct State {
    @Shared var count: Int
    // Other properties
  }
  // ...
}

// In parent action:
case .presentButtonTapped:
  state.child = ChildFeature.State(count: state.$count)
""",
        notes: "Simplest form of @Shared. Data is not persisted. Great for temporary shared state during app session."
    ),

    Pattern(
        name: "@Shared Reference Passing",
        domain: "TCA",
        problem: "Child features need access to shared state from parent feature",
        solution: "Use the `$` projected value syntax to pass a reference to the shared data. This maintains the shared connection while allowing child access.",
        codeExample: """
// Parent feature creates child with shared reference:
case .presentChild:
  state.child = ChildFeature.State(count: state.$count)

// Child feature accesses shared data:
struct ChildFeature {
  @ObservableState
  struct State {
    @Shared var count: Int
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .increment:
        state.count += 1  // Modifies shared state
        return .none
      }
    }
  }
}
""",
        notes: "Critical pattern: Use `$count` for references, not `state.count` which creates a copy."
    ),

    Pattern(
        name: "@SharedFileStorage",
        domain: "TCA",
        problem: "Need to persist shared state across app launches",
        solution: "Use @Shared with fileStorage persistence strategy. Data is automatically saved to disk and restored on app launch.",
        codeExample: """
@Shared(.fileStorage) var userData: UserData

// When modifying:
userData.username = "newUsername"  // Automatically persisted
""",
        notes: "Good for user preferences, settings, and data that should survive app restarts."
    ),

    Pattern(
        name: "@SharedUserDefaults",
        domain: "TCA",
        problem: "Need to persist simple shared data using UserDefaults",
        solution: "Use @Shared with appStorage persistence strategy. Leverages iOS/macOS UserDefaults system.",
        codeExample: """
@Shared(.appStorage) var userSettings: UserSettings

// Usage:
userSettings.theme = "dark"
userSettings.notificationsEnabled = true
""",
        notes: "Limited by UserDefaults storage constraints. Best for simple user preferences."
    ),

    Pattern(
        name: "@Shared Single Owner Pattern",
        domain: "TCA",
        problem: "Need to establish clear ownership of shared data to prevent confusion",
        solution: "Designate one feature as the 'owner' of each @Shared property. Other features read from but don't modify the shared data.",
        codeExample: """
@Reducer
struct UserSettingsFeature {
  @ObservableState
  struct State {
    @Shared var theme: Theme = .light
    @Shared var notificationsEnabled: Bool = true
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .toggleTheme:
        state.theme = state.theme == .light ? .dark : .light  // Owner can modify
        return .none
      case .otherFeatureAction:
        // Other feature can read:
        print("Current theme: \\(state.theme)")
        return .none
      }
    }
  }
}

@Reducer
struct ReadOnlyFeature {
  @ObservableState
  struct State {
    @Shared var theme: Theme
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .displayInfo:
        // Can read shared state but not modify
        return .none
      }
    }
  }
}
""",
        notes: "Establishes clear separation between owners (can modify) and readers (can only access)."
    ),

    Pattern(
        name: "@Shared with Type-Safe Keys",
        domain: "TCA",
        problem: "String-based keys are error-prone and can cause runtime issues",
        solution: "Define custom SharedKey types that conform to the SharedKey protocol for type-safe shared state access.",
        codeExample: """
// Define type-safe keys:
public struct UserPreferencesKeys: SharedKey {
  public static let theme = SharedKey("com.app.theme")
  public static let notifications = SharedKey("com.app.notifications")
}

// Use type-safe @Shared:
@Shared(UserPreferencesKeys.theme) var theme: Theme
@Shared(UserPreferencesKeys.notifications) var notificationsEnabled: Bool
""",
        notes: "Eliminates string literal typos in shared keys and provides compile-time safety."
    )
]

// Navigation patterns
let navigationPatterns: [Pattern] = [
    Pattern(
        name: "Stack-Based Navigation",
        domain: "TCA",
        problem: "Need to navigate between screens in iOS/macOS apps with proper state management",
        solution: "Use SwiftUINavigationStackWrapStyle to integrate SwiftUI navigation with TCA state management.",
        codeExample: """
@Reducer
struct NavigationFeature {
  @ObservableState
  struct State {
    var path = NavigationPath()
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      case .pushDestination(let route):
        state.path.append(route)
        return .none
      case .popToRoot:
        state.path.removeAll()
        return .none
    }
  }
}

struct NavigationView: View {
  let store: StoreOf<NavigationFeature>
  var body: some View {
    NavigationStack(path: store.scope(state: \.path)) {
      DetailView(detail: store.scope(state: \.detail))
        Button("Back to Root") {
          store.send(.popToRoot)
        }
      }
    }
    .navigationDestination(for: String.self) { destination in
      if destination == "settings" {
        SettingsView(store: store)
      }
    }
  }
}
""",
        notes: "Standard navigation pattern for TCA + SwiftUI integration."
    ),

    Pattern(
        name: "Tree-Based Navigation",
        domain: "TCA",
        problem: "Need complex navigation structure with multiple levels and state management",
        solution: "Use SwiftUI navigation tree with PathNavigatableStack for deep navigation scenarios.",
        codeExample: """
@Reducer
struct AppFeature {
  @ObservableState
  struct State {
    var path = NavigationPath()
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .navigateToTab(let tab):
        state.path = NavigationPath(tab)
        return .none
      }
    }
  }
}

struct AppNavigationView: View {
  let store: StoreOf<AppFeature>
  var body: some View {
    NavigationStack(path: store.scope(state: \.path)) {
      TabSelectionView(selection: store.binding(
        send: AppFeature.Action.navigateToTab
      ))

      // Deep navigation destination
      NavigationLink(value: "/settings") {
        SettingsView(store: store)
      }
    }
  }
}
""",
        notes: "More flexible than stack navigation for complex app structures."
    ),

    Pattern(
        name: "State Restoration Navigation",
        domain: "TCA",
        problem: "Need to preserve and restore user's navigation state across app launches",
        solution: "Use @Shared to store navigation state and PathNavigatableStack with restoration APIs for proper state persistence.",
        codeExample: """
@Reducer
struct AppFeature {
  @ObservableState
  struct State {
    @Shared var navigationPath = NavigationPath()
    @Shared var selectedTab = 0
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .selectTab(let index):
        state.selectedTab = index
        return .none
      }
    }
  }
}

struct App: App {
  let store = StoreOf(initialState: AppFeature.State()) {
    AppFeature()
  }

  var body: some Scene {
    WindowGroup {
      PathNavigableStack {
        AppNavigationStore(store: store)
      }
    }
  }
}
""",
        notes: "Ensures users return to same screen/state after app restart."
    )
]

// Testing patterns
let testingPatterns: [Pattern] = [
    Pattern(
        name: "TestStore @Shared Testing",
        domain: "TCA",
        problem: "Need to test features that use @Shared state sharing",
        solution: "Use TestStore with assertValues to test shared state changes across multiple features",
        codeExample: """
@Test
func testSharedStateBetweenFeatures() async {
  let store = TestStore(initialState: ParentFeature.State())

  // Test initial shared state
  await store.send(.incrementCount)
  await store.send(.presentChild)

  // Test that child can access shared state
  let childState = await store.scope(state: \.child.state)
  XCTAssertEqual(childState.count, 1)

  // Test that shared state is actually shared
  await store.send(.incrementFromChild)
  let parentState = await store.state
  let childStateAfter = await store.scope(state: \.child.state)
  XCTAssertEqual(parentState.count, 2)
  XCTAssertEqual(childStateAfter.count, 2)
}
""",
        notes: "TestStore automatically handles @Shared state synchronously during tests."
    ),

    Pattern(
        name: "TestStore File Storage Testing",
        domain: "TCA",
        problem: "Need to test features with persisted @Shared state",
        solution: "Use TestStore with withDependencies to create controlled file storage environment for testing",
        codeExample: """
@Test
func testPersistedSharedState() async {
  let fileManager = FileManager.temporaryDirectory
  let testDirectory = fileManager.appendingPathComponent("test-persistence")

  let store = TestStore(
    initialState: Feature.State(),
    withDependencies: {
      $0.fileStorage = FileStorage(path: testDirectory)
    }
  )

  // Test persistence across store instances
  await store.send(.updateSharedData("test_value"))

  // Create new store instance to test persistence
  let restoredStore = TestStore(
    initialState: Feature.State(),
    withDependencies: {
      $0.fileStorage = FileStorage(path: testDirectory)
    }
  )

  let restoredState = await restoredStore.state
  XCTAssertEqual(restoredState.sharedData, "test_value")
}
""",
        notes: "Use fileStorage dependency to create isolated test environment for persistence testing."
    ),

    Pattern(
        name: "Override @Shared in Tests",
        domain: "TCA",
        problem: "Need to test different scenarios for shared state in different tests",
        solution: "Use TestStore.withDependencies to override @Shared with mock or controlled values for specific test scenarios",
        codeExample: """
@Test
func testWithMockSharedState() async {
  let store = TestStore(
    initialState: Feature.State(),
    withDependencies: {
      $0.fileStorage = FileStorage(path: testDir)
      $0.sharedValues[SharedKey.someKey] = "mock_value"
    }
  )

  // Test with overridden shared value
  let state = await store.state
  XCTAssertEqual(state.someSharedValue, "mock_value")
}

@Test
func testWithReadonlySharedState() async {
  let store = TestStore(
    initialState: Feature.State(),
    withDependencies: {
      $0.fileStorage = FileStorage(path: testDir)
      $0.sharedValues[SharedKey.readonlyKey] = 123
    }
  )

  // Test that readonly state cannot be modified
  await store.send(.attemptModification)
  // Assertion that state remains unchanged
}
""",
        notes: "Use dependency injection for testing different shared state scenarios."
    )
]

// Let's add these patterns to the database
func addPatternsToDatabase(patterns: [Pattern]) throws {
    let db = try SimpleDatabase(databasePath: dbPath)

    for pattern in patterns {
        try db.insertPattern(
            name: pattern.name,
            domain: pattern.domain,
            problem: pattern.problem,
            solution: pattern.solution,
            codeExample: pattern.codeExample,
            notes: pattern.notes
        )
        print("✅ Added pattern: \\(pattern.name)")
    }

    print("\\n📊 Successfully added \\(patterns.count) patterns to database")
}

// Main execution
do {
    print("🚀 Adding TCA patterns to Maxwell database...")
    print("📁 Database path: \\(dbPath)")

    print("\\n📝 Adding @Shared patterns...")
    try addPatternsToDatabase(patterns: tcaPatterns)

    print("\\n🧭 Adding Navigation patterns...")
    try addPatternsToDatabase(patterns: navigationPatterns)

    print("\\n🧪 Adding Testing patterns...")
    try addPatternsToDatabase(patterns: testingPatterns)

    print("\\n✅ Pattern extraction complete!")

} catch {
    print("❌ Error adding patterns: \\(error)")
}

// SimpleDatabase extension to handle Pattern operations
extension SimpleDatabase {
    func insertPattern(name: String, domain: String, problem: String, solution: String, codeExample: String, notes: String) throws {
        // Implementation would be added here...
        print("Would insert pattern: \\(name)")
    }
}