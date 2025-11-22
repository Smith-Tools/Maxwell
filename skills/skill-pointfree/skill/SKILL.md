---
name: Point-Free Ecosystem (Includes TCA)
description: Complete Point-Free ecosystem expert providing authoritative guidance on TCA 1.23.0+, Dependencies, Navigation, Testing, and multi-framework integration. Point-Free created TCA - this skill is the definitive source for all Point-Free patterns.
tags:
  - "Point-Free"
  - "TCA"
  - "Swift Composable Architecture"
  - "Dependencies"
  - "Navigation"
  - "Testing"
  - "@Shared"
  - "@Bindable"
  - "Reducer"
  - "TestStore"
  - "Integration"
  - "Architecture"
triggers:
  - "TCA"
  - "@Shared"
  - "@Bindable"
  - "Reducer"
  - "TestStore"
  - "Point-Free"
  - "Dependencies"
  - "Navigation"
  - "coordinate"
  - "integrate"
  - "architecture"
version: "2.0.0"
author: "Claude Code Skill - Maxwell Architecture"
---

# Point-Free Ecosystem Skill (Including TCA)

**For:** Swift development teams using Point-Free frameworks - the definitive source for TCA and all Point-Free patterns
**Purpose:** Authoritative guidance on TCA 1.23.0+ and integration across the entire Point-Free ecosystem
**Frameworks:** TCA (authoritative), Dependencies, Navigation, Testing, Clocks, Sharing
**Authority Level:** Canonical - Point-Free created TCA, this is the source of truth

## 🎯 What This Skill Does

### Core Responsibilities

- **TCA 1.23.0+ Authority** - Definitive source for modern TCA patterns, anti-patterns, and best practices
- **Pattern Recognition** - Identify correct TCA patterns (@Shared, @Bindable, navigation, testing)
- **Anti-Pattern Detection** - Spot deprecated APIs and common TCA mistakes (WithViewStore, IfLetStore, etc.)
- **Framework Integration** - Coordinate TCA with Dependencies, Navigation, and Testing
- **Architecture Validation** - Ensure implementations follow Point-Free canonical patterns
- **Migration Guidance** - Help transition from deprecated TCA APIs to modern patterns

### When to Use This Skill

**You should invoke this skill when:**

```
# TCA Questions (Primary Authority)
"How should I structure TCA navigation for this feature?"
"Is this the right TCA pattern for shared state?"
"What's the modern way to handle optional child features?"
"How do I test this @Shared state properly?"
"Should I use @Shared or @Dependency here?"
"Help me migrate from deprecated TCA APIs"
"Why is my TCA code showing WithViewStore/IfLetStore errors?"
"How do I structure a TCA reducer to avoid type inference explosion?"

# Integration Questions
"How do I integrate TCA with Dependencies and Navigation?"
"What's the best way to coordinate shared state across multiple features?"
"How do I test an app that uses TCA, Dependencies, and Navigation together?"
"Build a complete app architecture with Point-Free frameworks"
"Coordinate multiple Point-Free frameworks for a complex feature"
```

## 🔄 Integration with Other Skills

**CONsolidATED**: This skill now includes all TCA expertise that was previously in maxwell-tca. Point-Free created TCA, making this the definitive and authoritative source.

### skill-shareplay (SharePlay Specialist)
- **skill-pointfree**: TCA + Dependencies + Navigation patterns for SharePlay integration
- **skill-shareplay**: SharePlay-specific patterns and GroupSession coordination
- **When combined**: Use skill-pointfree for TCA patterns in SharePlay context, skill-shareplay for SharePlay specifics

### skill-visionos (VisionOS Specialist)
- **skill-pointfree**: TCA patterns adapted for visionOS platform
- **skill-visionos**: Platform-specific visionOS patterns and RealityKit integration
- **When combined**: Use skill-pointfree for TCA + Dependencies patterns on visionOS, skill-visionos for platform specifics

### skill-architectural (Architecture Specialist)
- **skill-pointfree**: Point-Free ecosystem patterns and integration guidance
- **skill-architectural**: Cross-domain architecture decisions and skill coordination
- **When combined**: skill-pointfree provides authoritative Point-Free knowledge, skill-architectural handles broader architectural questions

## ⚡ TCA Pattern Detection & Routing

**This skill is the authoritative source for all TCA patterns - Point-Free created TCA**

| Query Keywords | Domain | Primary Guide | Pattern Focus |
|----------------|--------|--------------|---------------|
| "@Shared", "shared state", "owner" | State Management | TCA-SHARED-STATE.md | Single owner + @SharedReader |
| "@Bindable", "observation", "WithViewStore" | State Observation | TCA-PATTERNS.md Pattern 1 | Modern observation patterns |
| "navigation", "sheet", "navigator" | Navigation | TCA-NAVIGATION.md | Sheet-based navigation |
| "TestStore", "@Test", "testing" | Testing | TCA-TESTING.md | Swift Testing integration |
| "@Dependency", "injection", "client" | Dependencies | TCA-DEPENDENCIES.md | Dependency injection patterns |
| "reducer", "action", "effect" | Core TCA | TCA-PATTERNS.md | Reducer architecture |
| "WithViewStore", "IfLetStore" | Migration | TCA-PATTERNS.md Quick Ref | Deprecated API migration |
| "type inference", "compilation" | Performance | DISCOVERY-16-*.md | Type inference anti-patterns |

## 📖 Core TCA Knowledge Areas (Consolidated)

### 1. **TCA Pattern Foundations** (guides/TCA-PATTERNS.md)
- Pattern 1: State observation with `@Bindable`
- Pattern 2: Optional state navigation (sheets + scope)
- Pattern 3: Multiple navigation destinations
- Pattern 4: Form input bindings
- Pattern 5: Shared state with `@Shared` and `@SharedReader`
- Common mistakes and anti-patterns

### 2. **Navigation Patterns** (guides/TCA-NAVIGATION.md)
- Sheet-based optional child features
- Multiple enum-based destinations
- Popover and alert presentations
- Navigation stack integration
- Lifecycle management and state cleanup

### 3. **Shared State Discipline** (guides/TCA-SHARED-STATE.md)
- Single owner pattern for `@Shared`
- `@SharedReader` for read-only access
- Persistence integration (.appStorage, .fileStorage)
- Testing @Shared state in features
- Race condition prevention

### 4. **Dependencies & Injection** (guides/TCA-DEPENDENCIES.md)
- `@DependencyClient` pattern with Swift 6.2 strict concurrency
- Defining test values and preview values
- Proper mocking for different scenarios
- Platform-specific dependency injection
- Avoiding common dependency patterns

### 5. **Testing Strategies** (guides/TCA-TESTING.md)
- Swift Testing framework integration (not XCTest)
- TestStore setup and usage
- Testing reducers, effects, and side effects
- @Shared state testing strategies
- Deterministic time with TestClock

### 6. **Advanced Topics** (guides/)
- **TCA-TRIGGERS.md** - Action routing, effect composition, cancellation
- **DISCOVERY-16-TCA-SWIFTUI-TYPE-INFERENCE.md** - Type inference anti-patterns

### 7. **Validation Rules** (validation/)
- **Rule 1.1** - Monolithic features detection
- **Rule 1.2** - Closure injection violations
- **Rule 1.3** - Code duplication patterns
- **Rule 1.4** - Unclear organization
- **Rule 1.5** - Tightly coupled state

## 📖 Core Integration Areas

### 1. **State + Dependencies Coordination** (integration/TCA-DEPENDENCIES.md)
- @Shared vs @Dependency decision patterns
- Cross-feature state synchronization
- Dependency injection for TCA reducers
- Testing strategies for state + dependencies

### 2. **Navigation + State Integration** (integration/TCA-NAVIGATION.md)
- TCA-driven navigation patterns
- Navigation state as TCA state
- Deep linking with TCA coordination
- Navigation stack management

### 3. **Multi-Framework Testing** (integration/TESTING-INTEGRATION.md)
- Testing across framework boundaries
- Integration test strategies
- Snapshot testing for complex UI flows
- TestStore with dependency coordination

### 4. **Full-Stack Architecture** (integration/FULL-STACK-EXAMPLES.md)
- Complete app implementation patterns
- Framework responsibility boundaries
- Performance optimization across frameworks
- Error handling integration

## 🚨 Critical TCA Anti-Patterns (Point-Free Authoritative)

**Point-Free created TCA - these anti-patterns are definitively wrong:**

### ❌ Deprecated/Wrong vs ✅ Modern Alternative

| ❌ Deprecated/Wrong | ✅ Modern Alternative | TCA Version | Why Point-Free Changed This |
|------------------|-------------------|-------------|-----------------------------|
| `WithViewStore` | `@Bindable` + direct access | 1.5+ | Manual observation unnecessary - TCA handles it |
| `IfLetStore` | `.sheet(item:)` + `.scope()` | 1.5+ | Optional navigation built into SwiftUI |
| `@Perception.Bindable` | `@Bindable` (from TCA) | 1.0+ | @Perception dependency eliminated |
| `Shared(value: x)` | `Shared(wrappedValue: x)` | 1.8+ | Correct argument label required |
| Manual `.onReceive()` | `@Bindable` with `@ObservableState` | 1.5+ | Automatic observation more efficient |
| Multiple writers to `@Shared` | Single owner + `@SharedReader` | 1.8+ | Race condition prevention |
| Nested `CombineReducers` | Flat `@ReducerBuilder` | 1.0+ | Type inference explosion fix |
| `Task.detached` in reducers | `Task { @MainActor in ... }` | 6.0+ | Actor isolation requirement |
| Direct `Date()` calls | `@Dependency(\.dateClient)` | 1.0+ | Deterministic testing |
| `@State` in reducers | `@ObservableState` | 1.0+ | Views-only vs state distinction |

### ⚠️ Performance Anti-Patterns to Avoid

| Pattern | Symptom | Point-Free Solution |
|---------|---------|--------------------|
| Large complex State structs | Slow compilation | Extract child features |
| Deeply nested enums | Type inference explosion | Flatten enum structure |
| Many computed properties | Compilation hangs | Move to view logic |
| Complex expressions in State | Slow builds | Simplify state shape |

## 🏗️ TCA Implementation Patterns

### Pattern 1: State Observation
```swift
// ✅ Modern Point-Free Way
@Bindable var store: StoreOf<Feature>
Text(store.title)

// ❌ Deprecated Way (Anti-Pattern)
WithViewStore(self.store) { viewStore in
  Text(viewStore.title)
}
```

### Pattern 2: Optional Navigation
```swift
// ✅ Modern Point-Free Way
.sheet(item: $store.scope(state: \.child, action: \.child)) { childStore in
  ChildView(store: childStore)
}

// ❌ Deprecated Way (Anti-Pattern)
IfLetStore(
  self.store.scope(state: \.child, action: \.child)
) { childStore in
  ChildView(store: childStore)
}
```

### Pattern 3: Shared State (Single Owner)
```swift
// ✅ Point-Free Single Owner Pattern
@Reducer struct AuthFeature {
  @ObservableState struct State {
    @Shared var auth: AuthState  // Owner can modify
  }

  @Reducer struct ProfileFeature {
    @ObservableState struct State {
      @SharedReader var auth: AuthState  // Reader only
    }
  }
}
```

## 🎯 TCA Decision Trees (Point-Free Authority)

### @Shared vs @Dependency Decision Tree
```
Need to share data across features?
├─ Yes → @Shared
│   ├─ Need persistence? → @Shared(.appStorage/.fileStorage)
│   └─ Temporary only? → @Shared()
└─ No → @Dependency
    ├─ External service? → @Dependency(\.serviceClient)
    └─ System API? → @Dependency(\.dateClient/.uuidClient)
```

### Feature Extraction Decision Tree
```
Reducer > 200 lines?
├─ Yes → Extract child feature
│   ├─ Related functionality? → Single child
│   └─ Unrelated responsibilities? → Multiple children
└─ No → Keep in current feature
```

## 🧪 TCA Testing Patterns (Point-Free)

### TestStore Usage
```swift
@Test
@MainActor
func testFeature() async {
  let store = TestStore(initialState: Feature.State()) {
    Feature()
  } withDependencies: {
    $0.apiClient.fetch = { "data" }
  }

  await store.send(.fetchTapped) {
    $0.isLoading = true
  }

  await store.receive(.response(.success("data"))) {
    $0.isLoading = false
    $0.data = "data"
  }
}
```

### @Shared State Testing
```swift
@Test
@MainActor
func testSharedState() async {
  let sharedAuth = AuthState(userID: "123")

  let store = TestStore(initialState: Feature.State(sharedAuth: sharedAuth)) {
    Feature()
  }

  await store.send(.logoutTapped)
  // Verify sharedAuth state changed
}
```

## 🚨 Red Flags: Coordination Anti-Patterns

If you see yourself about to implement any of these, **stop immediately**:

| Anti-Pattern | Correct Approach | Why |
|--------------|------------------|-----|
| Direct coupling between unrelated frameworks | Clear integration boundaries | Framework isolation and maintainability |
| Mixing navigation patterns in same feature | Choose one navigation approach | Consistency and predictability |
| State duplication across frameworks | Single source of truth per data | Avoid synchronization issues |
| Testing frameworks in isolation | Integration testing strategy | Catch framework boundary issues |
| Circular dependencies between frameworks | Dependency inversion | Prevent architecture problems |

## 📋 Decision Trees

### Framework Selection Decision Tree

```
Need: Complex UI with shared state?
├─ Yes → TCA + Dependencies
│   ├─ Multiple screens? → TCA + Dependencies + Navigation
│   └─ Single screen? → TCA + Dependencies only
└─ No → Consider simpler state management

Need: External API integration?
├─ Yes → Dependencies essential
│   ├─ UI state changes? → TCA + Dependencies
│   └─ Simple data flow? → Dependencies only
└─ No → May not need Dependencies

Need: Complex navigation flow?
├─ Yes → Navigation framework recommended
│   ├─ Navigation state affects UI? → Navigation + TCA
│   └─ Simple screen changes? → Navigation only
└─ No → SwiftUI navigation may suffice
```

### Integration Strategy Decision Tree

```
Integration Complexity: Low?
├─ Yes → Simple delegation to specialists
├─ No → Check number of frameworks
│   ├─ 2-3 frameworks → Parallel delegation + synthesis
│   └─ 4+ frameworks → Sequential coordination
└─ Evaluate further requirements
```

## 🔗 Related Resources

### Point-Free Official Documentation
- [Point-Free GitHub](https://github.com/pointfreeco)
- [Swift Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
- [Swift Dependencies](https://github.com/pointfreeco/swift-dependencies)
- [Swift Navigation](https://github.com/pointfreeco/swift-navigation)

### Maxwell Modules
- **maxwell-tca**: Deep TCA patterns and implementation
- **maxwell-dependencies**: Dependency injection expertise
- **maxwell-navigation**: Navigation patterns specialist
- **maxwell-pointfree-testing**: Testing ecosystem coordination

### Integration Guides
- **routing/FRAMEWORK-DETECTION.md** - Detection algorithm details
- **routing/INTEGRATION-PATTERNS.md** - Cross-framework patterns
- **routing/DELEGATION-PROTOCOL.md** - Specialist coordination mechanics

## 🧪 Testing Integration Knowledge

Before implementing multi-framework solutions, verify you can answer:

1. **What are the boundaries between TCA and Dependencies?**
   - TCA: UI state, user actions, view logic
   - Dependencies: External services, platform APIs, shared resources

2. **When should Navigation state be in TCA vs separate?**
   - TCA: When navigation depends on app state
   - Separate: When navigation is UI-driven only

3. **How do you test cross-framework integrations?**
   - Integration tests covering framework boundaries
   - Mock dependencies for TCA testing
   - Snapshot testing for navigation flows

4. **What are the performance considerations for multi-framework apps?**
   - Framework initialization order
   - Memory management across boundaries
   - Efficient state updates and navigation

## 📚 Documentation Organization

```
skill/
├── SKILL.md                    ← You are here
├── routing/                    ← Framework detection and delegation
│   ├── FRAMEWORK-DETECTION.md  ← Detection algorithms
│   ├── INTEGRATION-PATTERNS.md ← Cross-framework patterns
│   └── DELEGATION-PROTOCOL.md  ← Specialist coordination
├── integration/                ← Combined framework examples
│   ├── TCA-DEPENDENCIES.md     ← State + dependency patterns
│   ├── TCA-NAVIGATION.md       ← Navigation + state patterns
│   ├── TESTING-INTEGRATION.md  ← Multi-framework testing
│   └── FULL-STACK-EXAMPLES.md  ← Complete implementations
├── decision-trees/             ← Architecture decision guides
│   ├── STATE-MANAGEMENT.md     ← State architecture decisions
│   ├── DEPENDENCY-INJECTION.md ← Injection strategy decisions
│   └── TESTING-STRATEGY.md     ← Testing approach decisions
├── snippets/                   ← Quick copy templates
├── examples/                   ← Complete feature examples
└── resources/                  ← Reference materials
```

## 📞 Getting Help

### For Architecture Questions
1. Check decision trees for framework selection
2. Review integration patterns for coordination
3. Use maxwell-pointfree for high-level guidance

### For Implementation Details
1. Let maxwell-pointfree route to appropriate specialist
2. Review specialist-specific documentation
3. Use integration examples as reference

### For Complex Scenarios
1. Describe your full use case to maxwell-pointfree
2. Let the coordinator analyze all requirements
3. Follow the recommended architecture plan

---

**Point-Free Coordination Skill v1.0.0 - Production Ready**

Expert coordination across the entire Point-Free ecosystem.

*Last updated: November 21, 2025*