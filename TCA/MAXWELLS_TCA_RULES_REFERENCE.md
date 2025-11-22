# Maxwells TCA Rules Reference

## Overview

Maxwells TCA provides comprehensive architectural validation for The Composable Architecture (TCA) projects. These rules detect anti-patterns, enforce best practices, and help maintain clean, maintainable TCA codebases.

## Rule 1.1: Monolithic Features

### Purpose
Detects when State structs or Action enums become too large, indicating a feature has too many responsibilities.

### Detection Criteria
- **State Structs**: More than 15 properties
- **Action Enums**: More than 40 cases
- **Thresholds**: Based on real-world TCA project analysis

### Violation Example
```swift
@Reducer
struct Feature: Reducer {
    struct State {
        // 🚨 Too many properties (>15)
        let navigation: NavigationState
        let data: DataState
        let ui: UIState
        let search: SearchState
        let filter: FilterState
        let settings: SettingsState
        let analytics: AnalyticsState
        let cache: CacheState
        let network: NetworkState
        let error: ErrorState
        let loading: LoadingState
        let validation: ValidationState
        let export: ExportState
        let import: ImportState
        let share: ShareState
        let backup: BackupState
        let debug: DebugState
        let performance: PerformanceState
    }
}
```

### Recommendations
- Split large features into smaller, focused child features
- Extract related properties into separate child features
- Use parent-child communication between features
- Consider feature boundaries based on user workflows

## Rule 1.2: Proper Dependency Injection

### Purpose
Validates that dependencies are properly injected using TCA's `@Dependency` macro rather than direct instantiation.

### Detection Criteria
- Direct instantiation of dependencies (`DependencyClient()`)
- Missing `@Dependency` declarations
- Hardcoded dependency creation
- Anti-patterns in dependency management

### Violation Example
```swift
@Reducer
struct Feature: Reducer {
    @Dependency(\.apiClient) var apiClient  // ✅ Correct
    let databaseClient = DatabaseClient()        // 🚨 Direct instantiation
    let analytics = AnalyticsClient()            // 🚨 Hardcoded dependency

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadData:
                // ✅ Using injected dependency
                return .run { send in
                    let data = try await apiClient.fetchData()
                    await send(.dataLoaded(data))
                }

            case .saveToDatabase:
                // 🚨 Direct dependency usage
                databaseClient.save(state.data)
                return .none

            case .trackEvent:
                // 🚨 Hardcoded dependency
                analytics.track(event)
                return .none
            }
        }
    }
}
```

### Recommendations
- Declare all dependencies using `@Dependency`
- Use proper TCA dependency injection patterns
- Avoid direct client instantiation in reducers
- Mock dependencies for testing purposes

## Rule 1.3: Code Duplication

### Purpose
Identifies duplicate code patterns, logic, and structures that violate DRY principles.

### Detection Criteria
- Duplicate action case implementations
- Repeated validation logic
- Similar reducer patterns
- Duplicate state transformations

### Violation Example
```swift
@Reducer
struct Feature1: Reducer {
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .increment:
                // 🚨 Duplicate increment logic
                state.count += 1
                if state.count > 100 {
                    state.count = 100
                }
                return .none
            case .decrement:
                // 🚨 Duplicate decrement logic
                state.count -= 1
                if state.count < 0 {
                    state.count = 0
                }
                return .none
            }
        }
    }
}

@Reducer
struct Feature2: Reducer {
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .increment:
                // 🚨 Same duplicate logic
                state.count += 1
                if state.count > 100 {
                    state.count = 100
                }
                return .none
            case .decrement:
                // 🚨 Same duplicate logic
                state.count -= 1
                if state.count < 0 {
                    state.count = 0
                }
                return .none
            }
        }
    }
}
```

### Recommendations
- Extract common logic into shared utilities
- Create reusable action and state components
- Use child features for shared functionality
- Implement proper abstraction layers

## Rule 1.4: Unclear Organization

### Purpose
Detects unclear naming, poor organization, and confusing code structure that impacts maintainability.

### Detection Criteria
- Vague method names (`handleAction`, `processEvent`)
- Unclear state property names (`data`, `stuff`, `temp`)
- Poorly organized action cases
- Missing documentation for complex logic

### Violation Example
```swift
@Reducer
struct Feature: Reducer {
    struct State {
        // 🚨 Unclear property names
        let data: SomeData
        let stuff: [String: Any]
        let temp: String
        let value1: Int
        let value2: String
        let result: Result<Bool, Error>
    }

    enum Action {
        // 🚨 Unclear action cases
        case action1
        case action2
        case doSomething
        case handleEvent
        case processThing
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .action1:
                // 🚨 Unclear method logic
                if state.value1 > 0 {
                    state.data = processData(state.stuff)
                    state.temp = generateValue(state.value2)
                }
                return .none

            case .doSomething:
                // 🚨 No clear purpose
                state.result = .success(true)
                return .none
            }
        }
    }

    // 🚨 Vague method names
    private func processData(_ input: [String: Any]) -> SomeData {
        // Implementation
    }

    private func generateValue(_ input: String) -> String {
        // Implementation
    }
}
```

### Recommendations
- Use descriptive, meaningful names
- Document complex logic with clear comments
- Organize actions by responsibility
- Group related state properties
- Use proper type annotations

## Rule 1.5: Tightly Coupled State

### Purpose
Identifies when State structs are too tightly coupled, with multiple unrelated features combined.

### Detection Criteria
- State contains unrelated domain concepts
- Multiple responsibilities in single State
- Child feature state mixing
- Poor separation of concerns

### Violation Example
```swift
@Reducer
struct MassiveFeature: Reducer {
    struct State {
        // 🚨 Unrelated features mixed together

        // User Profile
        let userId: String
        let userName: String
        let userEmail: String

        // Shopping Cart
        let cartItems: [Product]
        let cartTotal: Decimal
        let shippingAddress: Address

        // Settings
        let appTheme: Theme
        let notificationsEnabled: Bool
        let language: String

        // Analytics
        let sessionStartTime: Date
        let userActions: [AnalyticsEvent]
        let pageViews: [PageView]

        // Cache
        let cachedImages: [URL: Data]
        let cachedResponses: [String: Response]

        // UI State
        let isLoading: Bool
        let showingAlert: Bool
        let selectedTab: Int
    }

    enum Action {
        // 🚨 Actions for multiple unrelated concerns
        case updateUserProfile(name: String, email: String)
        case addToCart(product: Product)
        case removeItemFromCart(productId: String)
        case setTheme(_ theme: Theme)
        case toggleNotifications
        case trackUserAction(_ action: AnalyticsEvent)
        case cacheImage(url: URL, data: Data)
        case setLoading(_ loading: Bool)
        case showAlert(_ message: String)
        case selectTab(_ index: Int)
    }
}
```

### Recommendations
- Split into separate child features
- Use parent-child relationships between features
- Create focused state for each responsibility
- Implement proper feature boundaries
- Use TCA's scoped state for cross-feature communication

## Rule Severity Levels

- **🔴 Critical**: System-breaking architectural issues
- **🔴 High**: Significant architectural violations affecting maintainability
- **🟠 Medium**: Minor issues that should be addressed
- **🟡 Low**: Style and organization improvements
- **🔵 Info**: Informational findings

## Usage Examples

### Creating Custom Rules

```swift
struct CustomTCARule: ValidatableRule {
    func validate(context: SourceFileContext) -> ViolationCollection {
        var violations: [ArchitecturalViolation] = []

        // Custom validation logic
        let reducers = context.syntax.findTCAReducers()

        for reducer in reducers {
            if hasCustomViolation(reducer) {
                let violation = ArchitecturalViolation.medium(
                    rule: "Custom-TCA-Rule",
                    file: context.relativePath,
                    line: reducer.lineNumber,
                    message: "Custom violation detected",
                    recommendation: "Fix this specific issue"
                )
                violations.append(violation)
            }
        }

        return ViolationCollection(violations: violations)
    }
}
```

### Batch Validation

```swift
let engine = ValidationEngine()
let maxwellsRules = [
    TCARule_1_1_MonolithicFeatures(),
    TCARule_1_2_ClosureInjection(),
    TCARule_1_3_CodeDuplication(),
    TCARule_1_4_UnclearOrganization(),
    TCARule_1_5_TightlyCoupledState()
]

let violations = try engine.validate(
    rules: maxwellsRules,
    directory: "/path/to/tca-project"
)

print("Found \(violations.count) violations")
print("Critical: \(violations.criticalCount)")
print("High: \(violations.highCount)")
```

## Best Practices

1. **Start Early**: Apply rules from the beginning of development
2. **Fix Incrementally**: Address violations as they are discovered
3. **Review Regularly**: Run validation frequently during development
4. **Team Standards**: Establish clear architectural guidelines
5. **Documentation**: Document architectural decisions and rule exceptions

## Integration with CI/CD

### GitHub Actions Example
```yaml
name: TCA Validation

on: [push, pull_request]

jobs:
  validate:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    - name: Run TCA Validation
      run: |
        cd path/to/smith-validation
        swift run smith-validation ./Sources
```

### Pre-commit Hook
```bash
#!/bin/sh
swift run smith-validation ./Sources
if [ $? -ne 0 ]; then
  echo "❌ TCA validation failed. Fix violations before committing."
  exit 1
fi
```

This reference provides comprehensive guidance for understanding, using, and extending Maxwells TCA validation rules.