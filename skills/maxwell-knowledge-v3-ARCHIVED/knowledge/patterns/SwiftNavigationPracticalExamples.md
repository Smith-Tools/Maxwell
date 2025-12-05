# Swift Navigation API - Practical Implementation Examples

## Real-World Examples from Point-Free Case Studies

### Example 1: Comprehensive Enum Navigation
**File**: `EnumNavigation.swift`

This example demonstrates a complete navigation system using a single enum to drive all forms of navigation:

```swift
@CasePathable
enum Destination {
  case alert(String)
  case drillDown(Int)
  case confirmationDialog(String)
  case fullScreenCover(Int)
  case popover(Int)
  case sheet(Int)
  case sheetWithoutPayload
}

struct EnumNavigation: View {
  @State var destination: Destination?

  var body: some View {
    Section {
      // Alert presentation
      Button("Alert is presented: \(destination.is(\.alert) ? "✅" : "❌")") {
        destination = .alert("This is an alert!")
      }
      .alert(item: $destination.alert) { title in
        Text(title)
      } actions: { _ in
      }

      // Sheet with payload
      Button("Sheet (with payload) is presented: \(destination.is(\.sheet) ? "✅" : "❌")") {
        destination = .sheet(.random(in: 1...1_000))
      }
      .sheet(item: $destination.sheet, id: \.self) { $count in
        Form {
          Text(count.description)
          Button("Change count") {
            count = .random(in: 1...1_000)
          }
        }
        .navigationTitle("Sheet")
        .presentationDetents([.medium])
      }

      // Sheet without payload (Boolean binding)
      Button("Sheet (no payload) is presented: \(destination.is(\.sheetWithoutPayload) ? "✅" : "❌")") {
        destination = .sheetWithoutPayload
      }
      .sheet(isPresented: Binding($destination.sheetWithoutPayload)) {
        Form {
          Text("Hello!")
        }
        .navigationTitle("Sheet with payload")
        .presentationDetents([.medium])
      }

      // Full-screen cover
      Button("Cover is presented: \(destination.is(\.fullScreenCover) ? "✅" : "❌")") {
        destination = .fullScreenCover(.random(in: 1...1_000))
      }
      .fullScreenCover(item: $destination.fullScreenCover, id: \.self) { $count in
        NavigationStack {
          Form {
            Text(count.description)
            Button("Change count") {
              count = .random(in: 1...1_000)
            }
          }
          .navigationTitle("Full-screen cover")
          .toolbar {
            ToolbarItem {
              Button("Dismiss") {
                destination = nil
              }
            }
          }
        }
      }

      // Drill-down navigation
      Button("Drill-down is presented: \(destination.is(\.drillDown) ? "✅" : "❌")") {
        destination = .drillDown(.random(in: 1...1_000))
      }
      .background {
        EmptyView().navigationDestination(item: $destination.drillDown) { $count in
          Form {
            Text(count.description)
            Button("Change count") {
              count = .random(in: 1...1_000)
            }
          }
          .navigationTitle("Drill-down")
        }
      }
    }
  }
}
```

**Key Insights:**
- Single destination enum prevents invalid states
- Case paths (`$destination.alert`, `$destination.sheet`) provide clean syntax
- Binding transformation for payloadless presentations
- State inspection with `destination.is(\.alert)`

### Example 2: AlertState with Complex Logic
**File**: `AlertDialogState.swift`

This example shows how to model alerts with complex business logic and async operations:

```swift
@MainActor
@Observable
private class FeatureModel {
  var count = 0
  var isLoading = false
  var alert: AlertState<AlertAction>?

  enum AlertAction {
    case getFact
  }

  func numberFactButtonTapped() async {
    await getFact()
  }

  func alertButtonTapped(_ action: AlertAction?) async {
    switch action {
    case .getFact:
      await getFact()
    case nil:
      break
    }
  }

  private func getFact() async {
    isLoading = true
    defer { isLoading = false }
    let fact = await getNumberFact(count)
    alert = AlertState {
      TextState("Fact about \(count)")
    } actions: {
      ButtonState(role: .cancel) {
        TextState("OK")
      }
      ButtonState(action: .getFact) {
        TextState("Get another fact")
      }
    } message: {
      TextState(fact.description)
    }
  }
}

struct AlertDialogState: View {
  @State private var model = FeatureModel()

  var body: some View {
    Section {
      Stepper("Number: \(model.count)", value: $model.count)
      Button {
        Task { await model.numberFactButtonTapped() }
      } label: {
        LabeledContent("Get number fact") {
          if model.isLoading {
            ProgressView()
          }
        }
      }
    }
    .disabled(model.isLoading)
    .alert($model.alert) { action in
      await model.alertButtonTapped(action)
    }
  }
}
```

**Key Insights:**
- AlertState enables testable alert configuration
- Enum actions handle different button interactions
- Loading state management integrated with alert system
- Async operations supported through `@MainActor`

## Advanced Implementation Patterns

### Pattern 1: Nested Destinations
For complex apps with feature-specific navigation:

```swift
@CasePathable
enum AppDestination {
  case home(HomeDestination)
  case profile(ProfileDestination)
  case settings(SettingsDestination)
}

@CasePathable
enum HomeDestination {
  case alert(AlertState<HomeAlertAction>)
  case sheet(DetailModel)
  case navigation(DetailModel)
}

@CasePathable
enum ProfileDestination {
  case edit(ProfileEditModel)
  case confirmDelete(AlertState<DeleteAction>)
}
```

### Pattern 2: Deep Linking Support
Programmatic navigation construction:

```swift
extension AppModel {
  func handleDeepLink(_ url: URL) {
    switch url.path {
    case "/profile/edit":
      destination = .profile(.edit(ProfileEditModel(user: currentUser)))
    case "/home/detail/123":
      if let item = findItem(id: "123") {
        destination = .home(.navigation(DetailModel(item: item)))
      default:
        break
    }
  }
}

// Testability
func testDeepLinkToProfile() {
  let model = AppModel()
  model.handleDeepLink(URL(string: "myapp://profile/edit")!)

  if case .profile(.edit(let editModel)) = model.destination {
    XCTAssertNotNil(editModel.user)
  } else {
    XCTFail("Expected profile edit destination")
  }
}
```

### Pattern 3: Conditional Destinations
Dynamic destination logic:

```swift
extension Destination {
  static func forFeature(_ feature: Feature, user: User) -> Self? {
    switch feature.type {
    case .premium where !user.isPremium:
      return .upgradePrompt(AlertState {
        TextState("Premium Feature")
      } actions: {
        ButtonState(action: .upgrade) {
          TextState("Upgrade Now")
        }
        ButtonState(role: .cancel) {
          TextState("Maybe Later")
        }
      })

    case .restricted where !user.hasAccess:
      return .accessDenied(AlertState {
        TextState("Access Denied")
      })

    default:
      return .content(ContentModel(feature: feature))
    }
  }
}
```

### Pattern 4: State Persistence
Saving and restoring navigation state:

```swift
extension Destination: Codable {
  enum CodingKeys: CodingKey {
    case type, payload
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .alert(let string):
      try container.encode("alert", forKey: .type)
      try container.encode(string, forKey: .payload)
    case .sheet(let int):
      try container.encode("sheet", forKey: .type)
      try container.encode(int, forKey: .payload)
    // ... other cases
    }
  }
}

// Usage
class AppModel: Observable {
  @Published var destination: Destination? {
    didSet {
      UserDefaults.standard.set(
        try? JSONEncoder().encode(destination),
        forKey: "savedDestination"
      )
    }
  }

  func restoreSavedState() {
    if let data = UserDefaults.standard.data(forKey: "savedDestination"),
       let saved = try? JSONDecoder().decode(Destination.self, from: data) {
      destination = saved
    }
  }
}
```

### Pattern 5: Analytics Integration
Track navigation events automatically:

```swift
extension Destination {
  var analyticsEvent: AnalyticsEvent? {
    switch self {
    case .alert:
      return .alertPresented
    case .sheet:
      return .sheetPresented
    case .navigation:
      return .navigationPushed
    case nil:
      return .navigationDismissed
    }
  }
}

class AppModel: Observable {
  @Published var destination: Destination? {
    didSet {
      if let event = destination.analyticsEvent {
        Analytics.track(event)
      }
    }
  }
}
```

## Testing Strategies

### Unit Testing Navigation Logic
```swift
func testAlertFlow() async {
  let model = FeatureModel()

  // Initial state
  XCTAssertNil(model.alert)

  // Trigger alert
  await model.numberFactButtonTapped()
  XCTAssertNotNil(model.alert)

  if case .title(let title) = model.alert?.title {
    XCTAssertEqual(title, TextState("Fact about 0"))
  }

  // Test alert action
  await model.alertButtonTapped(.getFact)
  // Verify getFact was called again
}

func testDeepLinkConstruction() {
  var destination: Destination?

  // Construct navigation state programmatically
  destination = .sheet(42)

  if case .sheet(let number) = destination {
    XCTAssertEqual(number, 42)
  } else {
    XCTFail("Expected sheet destination")
  }
}
```

## Performance Considerations

1. **Minimize Destination Payloads**: Keep associated data lightweight
2. **Use Identifiable**: For complex payloads, implement `Identifiable` protocol
3. **Avoid Deep Nesting**: Keep enum hierarchy reasonable
4. **Lazy Loading**: Load heavy data only when destination becomes active

## Common Pitfalls

1. **Missing @CasePathable**: Required for case path syntax
2. **Circular References**: Avoid destinations that can create infinite loops
3. **Large Payloads**: Enum associated values are copied
4. **State Inconsistency**: Ensure destination state matches UI state