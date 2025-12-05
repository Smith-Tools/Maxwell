# Swift Navigation API - State-Driven Presentation Patterns

## Core Pattern: Enum-Based Navigation State

The fundamental pattern is using enums to represent navigation destinations instead of multiple optional boolean states. This provides compile-time guarantees and prevents invalid navigation states.

### Before (Problematic - Multiple Optionals)
```swift
@Observable
class FeatureModel {
  var addItem: AddItemModel?
  var deleteItemAlertIsPresented: Bool
  var editItem: EditItemModel?
  // ❌ Allows invalid states: 8 possible combinations, only 4 valid
}
```

### After (Solution - Enum with Case Paths)
```swift
@Observable
class FeatureModel {
  var destination: Destination?

  @CasePathable
  enum Destination {
    case addItem(AddItemModel)
    case deleteItemAlert
    case editItem(EditItemModel)
  }
  // ✅ Compile-time guarantee: only one destination active
}
```

## Pattern 1: State-Driven Alerts

### AlertState Pattern
Model alerts as optional AlertState with enum actions for testability.

```swift
@Observable
class FeatureModel {
  var alert: AlertState<AlertAction>?

  enum AlertAction {
    case confirmDelete
    case cancel
  }

  func deleteButtonTapped() {
    self.alert = AlertState {
      TextState("Are you sure?")
    } actions: {
      ButtonState(role: .destructive, action: .confirmDelete) {
        TextState("Delete")
      }
      ButtonState(role: .cancel) {
        TextState("Nevermind")
      }
    } message: {
      TextState("Deleting this item cannot be undone.")
    }
  }

  func alertButtonTapped(_ action: AlertAction?) {
    switch action {
    case .confirmDelete:
      // Perform deletion logic
    case nil:
      // Cancel button logic
    }
  }
}
```

### Alert Presentation
```swift
.alert($model.alert) { action in
  model.alertButtonTapped(action)
}
```

## Pattern 2: Enum-Based Destination Navigation

### Destination Enum with Alert Case
```swift
@Observable
class FeatureModel {
  var destination: Destination?

  @CasePathable
  enum Destination {
    case alert(AlertState<AlertAction>)
    case addItem(AddItemModel)
    case editItem(EditItemModel)
  }

  enum AlertAction {
    case confirmDelete
  }
}
```

### Case Path Presentation
```swift
.alert($model.destination.alert) { action in
  model.alertButtonTapped(action)
}
.sheet(item: $model.destination.addItem) { model in
  AddItemView(model: model)
}
.navigationDestination(item: $model.destination.editItem) { model in
  EditItemView(model: model)
}
```

## Pattern 3: Sheet Presentation with Binding

### Optional State Sheet
```swift
struct ContentView: View {
  @State var destination: Int?

  var body: some View {
    List {
      // ...
    }
    .sheet(item: $destination, id: \.self) { $number in
      CounterView(number: $number)
    }
  }
}
```

### Enum-Based Sheet with Case Paths
```swift
@State var destination: Destination?

@CasePathable
enum Destination {
  case counter(Int)
  case profile(ProfileModel)
  // More destinations
}

// Usage:
.sheet(item: $destination.counter, id: \.self) { $number in
  CounterView(number: $number)
}
```

## Pattern 4: Confirmation Dialogs

### DialogState Pattern
```swift
@Observable
class FeatureModel {
  var dialog: ConfirmationDialogState<DialogAction>?

  enum DialogAction {
    case confirmDelete
  }

  func deleteButtonTapped() {
    dialog = ConfirmationDialogState(titleVisibility: .visible) {
      TextState("Are you sure?")
    } actions: {
      ButtonState(role: .destructive, action: .confirmDelete) {
        TextState("Delete")
      }
      ButtonState(role: .cancel) {
        TextState("Nevermind")
      }
    } message: {
      TextState("Deleting this item cannot be undone.")
    }
  }
}
```

### Dialog Presentation
```swift
.confirmationDialog($model.dialog) { action in
  model.dialogButtonTapped(action)
}
```

## Pattern 5: Testing Navigation State

### Testable Alert State
```swift
func testDelete() {
  let model = FeatureModel(/* ... */)

  model.deleteButtonTapped()
  XCTAssertEqual(model.alert?.title, TextState("Are you sure?"))

  model.alertButtonTapped(.confirmDelete)
  // Assert that deletion actually occurred
}
```

### Deep Linking Test
```swift
func testDeepLink() {
  let model = FeatureModel()

  // Can construct navigation state directly
  model.destination = .editItem(EditItemModel(item: testItem))

  // Verify destination is set correctly
  XCTAssertNotNil(model.destination)
  if case .editItem(let editModel) = model.destination {
    XCTAssertEqual(editModel.item.id, testItem.id)
  }
}
```

## Benefits of These Patterns

1. **Compile-time Safety**: Enums prevent invalid navigation states
2. **Testability**: All navigation state is modeled and testable
3. **Deep Linking**: Can construct navigation state programmatically
4. **Single Source of Truth**: One piece of state drives all navigation
5. **Mutual Exclusion**: Case paths guarantee only one destination active
6. **Binding Support**: Parent and child can share state through bindings

## Advanced Techniques

### Conditional Alert Actions
```swift
AlertState {
  TextState("Are you sure?")
} actions: {
  if item.isLocked {
    ButtonState(role: .destructive, action: .confirmDelete) {
      TextState("Unlock and delete")
    }
  } else {
    ButtonState(role: .destructive, action: .confirmDelete) {
      TextState("Delete")
    }
  }
  ButtonState(role: .cancel) {
    TextState("Nevermind")
  }
}
```

### Complex Destinations
```swift
@CasePathable
enum Destination {
  case alert(AlertState<AlertAction>)
  case sheet(SheetModel)
  case navigation(DestinationModel)
  case customFlow(CustomFlowState)
}
```

These patterns provide a robust foundation for building complex, testable navigation systems in SwiftUI applications.