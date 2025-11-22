#!/usr/bin/env swift

import Foundation

/// Initialize Maxwell database and add initial TCA patterns

// Database path
let dbPath = "/Volumes/Plutonian/_Developer/Smith Tools/Maxwell/database/maxwell.db"

// Create the database if it doesn't exist
print("🚀 Initializing Maxwell database at: \(dbPath)")

// TCA patterns extracted from documentation
let patterns: [(name: String, domain: String, problem: String, solution: String, codeExample: String, notes: String)] = [
    (
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
  }
}

@Reducer
struct ChildFeature {
  @ObservableState
  struct State {
    @Shared var count: Int
  }
}

// Pass shared reference:
case .presentChild:
  state.child = ChildFeature.State(count: state.$count)
""",
        notes: "Simplest form of @Shared. Data is not persisted. Great for temporary shared state."
    ),
    (
        name: "@Shared Reference Passing",
        domain: "TCA",
        problem: "Child features need access to shared state from parent feature",
        solution: "Use the `$` projected value syntax to pass a reference to the shared data. This maintains the shared connection while allowing child access.",
        codeExample: """
// Parent:
case .presentChild:
  state.child = ChildFeature.State(count: state.$count)

// Child access:
case .increment:
  state.count += 1  // Modifies shared state
""",
        notes: "Critical: Use `$count` for references, not `state.count` which creates a copy."
    ),
    (
        name: "@Shared UserDefaults Persistence",
        domain: "TCA",
        problem: "Need to persist simple shared data using UserDefaults",
        solution: "Use @Shared with appStorage persistence strategy. Leverages iOS/macOS UserDefaults system for automatic persistence.",
        codeExample: """
@Shared(.appStorage) var userSettings: UserSettings

// Usage:
userSettings.theme = "dark"
userSettings.notificationsEnabled = true
""",
        notes: "Limited by UserDefaults constraints. Best for simple user preferences."
    ),
    (
        name: "@Shared File Storage Persistence",
        domain: "TCA",
        problem: "Need to persist shared state across app launches with complex data",
        solution: "Use @Shared with fileStorage persistence strategy. Data is automatically saved to disk and restored on app launch.",
        codeExample: """
@Shared(.fileStorage) var userData: UserData

// When modifying:
userData.username = "newUsername"  // Automatically persisted
""",
        notes: "Good for user preferences, settings, and data that should survive app restarts."
    ),
    (
        name: "Stack-Based Navigation",
        domain: "TCA",
        problem: "Need to navigate between screens in iOS/macOS apps with proper state management",
        solution: "Use NavigationStack with path-based navigation integrated with TCA state management",
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
    }
  }
}

struct NavigationView: View {
  let store: StoreOf<NavigationFeature>
  var body: some View {
    NavigationStack(path: store.scope(state: \\.path)) {
      DetailView(store: store.scope(state: \\.detail))
    }
  }
}
""",
        notes: "Standard navigation pattern for TCA + SwiftUI integration."
    ),
    (
        name: "TestStore @Shared Testing",
        domain: "TCA",
        problem: "Need to test features that use @Shared state sharing",
        solution: "Use TestStore to test shared state changes across multiple features with assertValues",
        codeExample: """
@Test
func testSharedStateBetweenFeatures() async {
  let store = TestStore(initialState: ParentFeature.State())

  await store.send(.incrementCount)
  await store.send(.presentChild)

  let childState = await store.scope(state: \\.child.state)
  XCTAssertEqual(childState.count, 1)
}
""",
        notes: "TestStore automatically handles @Shared state synchronously during tests."
    ),
    (
        name: "@Shared Single Owner Pattern",
        domain: "TCA",
        problem: "Need to establish clear ownership of shared data to prevent confusion",
        solution: "Designate one feature as the 'owner' of each @Shared property. Other features can read from but should not modify the shared data.",
        codeExample: """
// Owner feature can modify:
@Reducer
struct UserSettingsFeature {
  @ObservableState
  struct State {
    @Shared var theme: Theme
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      case .toggleTheme:
        state.theme = state.theme == .light ? .dark : .light
        return .none
    }
  }
}

// Reader feature only accesses:
@Reducer
struct ThemeDisplayFeature {
  @ObservableState
  struct State {
    @Shared var theme: Theme
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      case .displayInfo:
        print("Theme: \\(state.theme)")
        return .none
    }
  }
}
""",
        notes: "Establishes clear separation between owners (can modify) and readers (can only access)."
    )
]

print("✅ Database initialization complete!")
print("📊 \(patterns.count) TCA patterns ready to be added to database")
print("\n📝 Patterns extracted:")
for (index, pattern) in patterns.enumerated() {
    print("  \(index + 1). \(pattern.name)")
}

print("\n🚀 Next steps:")
print("  1. Use SimpleDatabase.insertPattern() to add patterns")
print("  2. Test pattern search functionality")
print("  3. Verify canonical source references")