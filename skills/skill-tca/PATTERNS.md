# TCA Patterns Extracted from Official Documentation

This document contains patterns extracted from the official TCA documentation, ready for use in Maxwell's pattern database.

## 🔍 Pattern Categories

### @Shared Patterns (70%)

#### 1. @Shared In-Memory Sharing
- **Problem**: Need to share state between features without persistence
- **Solution**: Use @Shared property wrapper with no arguments
- **Code**:
  ```swift
  @Shared var count: Int
  // Pass reference: state.child = ChildFeature.State(count: state.$count)
  ```
- **Notes**: Simplest form of @Shared. Data cleared on app restart. Great for temporary session state.

#### 2. @Shared Reference Passing
- **Problem**: Child features need access to shared state from parent
- **Solution**: Use `$` projected value to pass references
- **Code**:
  ```swift
  // Parent:
  state.child = ChildFeature.State(count: state.$count)
  // Child:
  state.count += 1  // Modifies shared state
  ```
- **Notes**: Critical: Use `$count` for references, not `state.count` which creates a copy.

#### 3. @Shared UserDefaults Persistence
- **Problem**: Need to persist simple shared data using UserDefaults
- **Solution**: Use @Shared with appStorage persistence strategy
- **Code**:
  ```swift
  @Shared(.appStorage) var userSettings: UserSettings
  userSettings.theme = "dark"
  ```
- **Notes**: Limited by UserDefaults constraints. Best for simple user preferences.

#### 4. @Shared File Storage Persistence
- **Problem**: Need to persist complex shared data across app launches
- **Solution**: Use @Shared with fileStorage persistence strategy
- **Code**:
  ```swift
  @Shared(.fileStorage) var userData: UserData
  userData.username = "newUsername"  // Automatically persisted
  ```
- **Notes**: Good for user preferences, settings, and data that should survive app restarts.

#### 5. @Shared Single Owner Pattern
- **Problem**: Need clear ownership of shared data to prevent confusion
- **Solution**: Designate one feature as 'owner', others as 'readers'
- **Code**:
  ```swift
  // Owner can modify:
  @Reducer struct UserSettingsFeature {
    @Shared var theme: Theme
    // Can modify state.theme
  }
  // Reader only accesses:
  @Reducer struct ThemeDisplayFeature {
    @Shared var theme: Theme
    // Only reads state.theme
  }
  ```
- **Notes**: Clear separation between owners (modify) and readers (access only).

### Navigation Patterns (30%)

#### 6. Stack-Based Navigation
- **Problem**: Navigate between screens with proper TCA state management
- **Solution**: Use NavigationStack with path-based navigation
- **Code**:
  ```swift
  @Reducer struct NavigationFeature {
    @ObservableState struct State {
      var path = NavigationPath()
    }

    NavigationStack(path: store.scope(state: \.path)) {
      DetailView(store: store.scope(state: \.detail))
    }
  }
  ```
- **Notes**: Standard navigation pattern for TCA + SwiftUI integration.

### Testing Patterns

#### 7. TestStore @Shared Testing
- **Problem**: Test features that use @Shared state sharing
- **Solution**: Use TestStore to test shared state changes
- **Code**:
  ```swift
  @Test
  func testSharedStateBetweenFeatures() async {
    let store = TestStore(initialState: ParentFeature.State())
    await store.send(.incrementCount)

    let childState = await store.scope(state: \.child.state)
    XCTAssertEqual(childState.count, 1)
  }
  ```
- **Notes**: TestStore handles @Shared state synchronously during tests.

## 📊 Pattern Summary

- **Total Patterns**: 7 core patterns extracted
- **Domains**: TCA (100%)
- **Sources**: Official TCA DocC documentation
- **Freshness**: Current (TCA 1.17+)

## 🔗 Canonical Sources

All patterns reference the official TCA documentation:
- **Primary**: [GitHub TCA Documentation](https://github.com/pointfreeco/swift-composable-architecture)
- **Secondary**: [Point-Free TCA Videos](https://www.pointfree.co/collections/composable-architecture)
- **Specific**: Articles/SharingState.md in DocC

## 🚀 Usage in Maxwell

These patterns are ready for insertion into Maxwell's pattern database using:

```swift
let database = try SimpleDatabase(databasePath: path)

try database.insertPattern(
    name: "@Shared In-Memory Sharing",
    domain: "TCA",
    problem: "...",
    solution: "...",
    codeExample: "...",
    notes: "..."
)
```

## 📝 Next Steps

1. **Database Population**: Add patterns to Maxwell SQLite database
2. **Skill Integration**: Update skill-tca to reference patterns by name
3. **Cross-Domain Integration**: Connect TCA patterns with SharePlay patterns
4. **Freshness Tracking**: Manual validation when TCA versions change

## 🔄 Update Policy

These patterns should be reviewed and updated when:
- New TCA versions introduce breaking changes
- New @Shared persistence strategies are added
- Navigation patterns evolve with SwiftUI updates
- Testing patterns change with new TestStore features

**Last Updated**: 2025-01-22
**TCA Version**: 1.17+
**Source**: Official TCA DocC Documentation