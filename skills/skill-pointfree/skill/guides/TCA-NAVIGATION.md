# TCA Navigation Patterns

> **Comprehensive guidance for navigation in The Composable Architecture (TCA)**

## SwiftUI + TCA Navigation Patterns

### Optional Child Features (Sheet-based)
```swift
@Reducer
struct ParentFeature {
  @ObservableState
  struct State {
    var childFeature: ChildFeature.State?
  }

  enum Action {
    case childFeature(ChildFeature.Action)
    case showChildTapped
    case childDismissed
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .showChildTapped:
        state.childFeature = ChildFeature.State()
        return .none

      case .childDismissed:
        state.childFeature = nil
        return .none

      case .childFeature:
        return .none
      }
    }
    .ifLet(\.childFeature, action: \.childFeature) {
      ChildFeature()
    }
  }
}
```

### SwiftUI View Integration
```swift
struct ParentView: View {
  @Bindable var store: StoreOf<ParentFeature>

  var body: some View {
    VStack {
      Button("Show Child") {
        store.send(.showChildTapped)
      }
    }
    .sheet(item: $store.scope(state: \.childFeature, action: \.childFeature)) { store in
      ChildView(store: store)
    }
  }
}
```

## Multiple Destinations Pattern

### Using Enum for Navigation
```swift
@Reducer
struct NavigationFeature {
  @ObservableState
  struct State {
    var destination: Destination?
  }

  enum Action {
    case destination(Destination.Action)
    case showSettings
    case showProfile
    case dismiss
  }

  enum Destination {
    case settings(SettingsFeature.State)
    case profile(ProfileFeature.State)
  }
}
```

### Navigation Implementation
```swift
var body: some ReducerOf<Self> {
  Reduce { state, action in
    switch action {
    case .showSettings:
      state.destination = .settings(SettingsFeature.State())
      return .none

    case .showProfile:
      state.destination = .profile(ProfileFeature.State())
      return .none

    case .dismiss:
      state.destination = nil
      return .none

    case .destination:
      return .none
    }
  }
  .ifLet(\.destination, action: \.destination) { _, destination in
    Scope(state: destination, action: \.self) {
      DestinationBody()
    }
  }
}
```

### SwiftUI Navigation
```swift
struct NavigationView: View {
  @Bindable var store: StoreOf<NavigationFeature>

  var body: some View {
    VStack {
      Button("Settings") {
        store.send(.showSettings)
      }
      Button("Profile") {
        store.send(.showProfile)
      }
    }
    .sheet(item: $store.scope(state: \.destination, action: \.destination)) { store in
      DestinationView(store: store)
    }
  }
}
```

## Navigation with @Shared State

### Shared Navigation State
```swift
@Reducer
struct AppFeature {
  @ObservableState
  struct State {
    var path = StackState<Path.State>()
    var selectedTab: Tab = .home
  }

  enum Action {
    case path(Path.Action)
    case selectTab(Tab)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .selectTab(let tab):
        state.selectedTab = tab
        return .none

      case .path:
        return .none
      }
    }
    .forEach(\.path, action: \.path) {
      Path()
    }
  }
}
```

## Tab Navigation with TCA

### Tab-based Architecture
```swift
@Reducer
struct TabFeature {
  @ObservableState
  struct State {
    var selectedTab: Tab = .home
    var homeState = HomeFeature.State()
    var searchState = SearchFeature.State()
    var profileState = ProfileFeature.State()
  }

  enum Action {
    case selectTab(Tab)
    case home(HomeFeature.Action)
    case search(SearchFeature.Action)
    case profile(ProfileFeature.Action)
  }

  enum Tab: String, CaseIterable {
    case home, search, profile
  }
}
```

## Navigation Anti-Patterns

### ❌ Don't Do This: Manual Navigation
```swift
// Bad: Direct navigation controller manipulation
@Reducer
struct BadFeature {
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .navigateToDetail:
        // Don't do this - breaks TCA principles
        navigationController.pushViewController(DetailViewController(), animated: true)
        return .none
      }
    }
  }
}
```

### ✅ Do This Instead: State-driven Navigation
```swift
// Good: State-driven navigation
@Reducer
struct GoodFeature {
  @ObservableState
  struct State {
    var detailState: DetailFeature.State?
  }

  enum Action {
    case navigateToDetail
    case detail(DetailFeature.Action)
    case dismissDetail
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .navigateToDetail:
        state.detailState = DetailFeature.State()
        return .none

      case .dismissDetail:
        state.detailState = nil
        return .none

      case .detail:
        return .none
      }
    }
    .ifLet(\.detailState, action: \.detail) {
      DetailFeature()
    }
  }
}
```

## Deep Linking Navigation

### URL-based Navigation
```swift
@Reducer
struct DeepLinkFeature {
  @ObservableState
  struct State {
    var path = StackState<Path.State>()
  }

  enum Action {
    case path(Path.Action)
    case openURL(URL)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .openURL(let url):
        // Parse URL and navigate accordingly
        if url.pathComponents.contains("profile") {
          state.path.append(.profile(ProfileFeature.State()))
        }
        return .none

      case .path:
        return .none
      }
    }
    .forEach(\.path, action: \.path) {
      Path()
    }
  }
}
```

## Platform-Specific Navigation

### iOS Navigation Stack
```swift
struct iOSNavigationView: View {
  @Bindable var store: StoreOf<NavigationFeature>

  var body: some View {
    NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
      VStack {
        // Main content
      }
      .navigationDestination(for: Path.State.self) { state in
        PathView(store: Store(initialState: state, reducer: Path()))
      }
    }
  }
}
```

### macOS Sidebar Navigation
```swift
struct macOSNavigationView: View {
  @Bindable var store: StoreOf<SidebarFeature>

  var body: some View {
    NavigationSplitView {
      // Sidebar
      List(SidebarFeature.Tab.allCases, id: \.self, selection: $store.selectedTab) { tab in
        Label(tab.rawValue.capitalized, systemImage: tab.systemImage)
      }
    } detail: {
      // Detail view based on selection
      TabContentView(store: store.scope(state: \.currentTabState, action: \.currentTabAction))
    }
  }
}
```

## Navigation Testing

### Testing Navigation Flows
```swift
@Test("Navigation flow opens and dismisses correctly")
@MainActor
func navigationFlow() async {
  let store = TestStore(initialState: NavigationFeature.State()) {
    NavigationFeature()
  }

  // Navigate to child
  await store.send(.showChildTapped) {
    $0.childFeature = ChildFeature.State()
  }

  // Dismiss child
  await store.send(.childDismissed) {
    $0.childFeature = nil
  }

  // Verify state is back to initial
  await store.receive(.childFeature(.dismiss)) {
    // Child feature cleanup
  }
}
```

## Performance Considerations

### Lazy Feature Initialization
```swift
// Don't initialize features until needed
.ifLet(\.childFeature, action: \.childFeature) {
  ChildFeature() // Only initialized when childFeature is non-nil
}
```

### Memory Management
- Use weak references for complex navigation graphs
- Clean up resources in .onDisappear
- Consider @StateObject for expensive view models

## Common Navigation Scenarios

### Form Wizards
```swift
@Reducer
struct WizardFeature {
  @ObservableState
  struct State {
    var currentStep: Step = .step1
    var step1State = Step1Feature.State()
    var step2State = Step2Feature.State()
    var step3State = Step3Feature.State()
  }

  enum Action {
    case nextStep
    case previousStep
    case finish
    case step1(Step1Feature.Action)
    case step2(Step2Feature.Action)
    case step3(Step3Feature.Action)
  }

  enum Step: CaseIterable {
    case step1, step2, step3
  }
}
```

### Modal Presentations
```swift
.sheet(item: $store.scope(state: \.modalState, action: \.modal)) { store in
  ModalView(store: store)
    .presentationDetents([.medium, .large])
    .presentationDragIndicator(.visible)
}
```

## Quick Reference

| Navigation Type | Pattern | When to Use |
|-----------------|---------|-------------|
| **Sheet/Modal** | Optional state + `.sheet()` | Temporary, interrupting flows |
| **Navigation Stack** | StackState + `.navigationDestination()` | Hierarchical navigation |
| **Tab Navigation** | Enum + switch | Parallel top-level sections |
| **Sidebar (macOS)** | Selection state + NavigationSplitView | Content/app navigation |
| **Deep Links** | URL parsing + state changes | External navigation entry points |