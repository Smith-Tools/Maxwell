---
name: TCA Composable Architecture
description: Specialized expertise for The Composable Architecture (TCA) development, including modern patterns, anti-pattern detection, testing strategies, and architectural decision support for Swift development teams.
tags:
  - TCA
  - "Composable Architecture"
  - Swift
  - Architecture
  - State Management
  - Testing
  - iOS
  - macOS
  - visionOS
  - "Swift 6.2"
  - "TCA 1.23.0"
triggers:
  - "TCA"
  - "Composable Architecture"
  - "reducer"
  - "store"
  - "@Bindable"
  - "@Shared"
  - "navigation"
  - "dependencies"
  - "testing"
  - "Swift Testing"
version: "1.0.0"
author: "Claude Code Skill"
---

# TCA Composable Architecture Skill

**For:** Swift development teams using The Composable Architecture (TCA) 1.23.0+
**Purpose:** Production-ready guidance for modern TCA patterns, testing, and architectural decisions
**Swift Versions:** 6.2+ (strict concurrency required)
**Platforms:** iOS, macOS, visionOS, watchOS

This skill provides comprehensive TCA expertise for Claude Code, covering modern TCA 1.23.0+ patterns, anti-pattern detection, architectural decision trees, and testing strategies.

---

## 🎯 What This Skill Does

### Core Responsibilities

- **Modern TCA Patterns** - TCA 1.23.0+ canonical patterns with current best practices
- **Anti-Pattern Detection** - Deprecated APIs, common mistakes, and migration paths
- **State Management Guidance** - Feature-local vs @Shared vs @Dependency decisions
- **Navigation Patterns** - Sheets, popovers, navigation stacks, multiple destinations
- **Testing Excellence** - Swift Testing framework integration, TestStore patterns, @Shared testing
- **Platform Integration** - iOS, macOS, visionOS specific TCA patterns
- **Architectural Decisions** - Decision trees for complex scenarios (shared state, dependencies, testing)

### When to Use This Skill

**You should invoke this skill when:**

```
"How should I structure TCA navigation for this feature?"
"Is this the right TCA pattern for shared state?"
"What's the modern way to handle optional child features?"
"How do I test this @Shared state properly?"
"Should I use @Shared or @Dependency here?"
"Help me migrate from deprecated TCA APIs"
"How do I structure a TCA reducer to avoid type inference explosion?"
"Is my dependency injection pattern correct?"
```

---

## 🔄 Integration with Other Skills

### smith-skill (Swift Architecture Validation)
- **smith-skill**: General Swift architecture validation, tool integration, Swift concurrency patterns
- **tca-guidance** (this skill): Specialized TCA pattern expertise
- **When validation is needed**: smith-skill defers to smith-validation's `smith-cli validate --tca` command

### sosumi-skill (Apple Documentation)
- **tca-guidance**: TCA architectural patterns and decision-making
- **sosumi-skill**: Apple platform documentation and WWDC content
- **When combined**: Use both for platform-specific TCA questions (visionOS SharePlay + TCA, etc.)

---

## ⚡ Quick Reference: Modern vs Deprecated

| ❌ Deprecated/Wrong | ✅ Modern Alternative | TCA Version | Why |
|---|---|---|---|
| `WithViewStore` | `@Bindable` + direct property access | 1.5+ | Removed; direct observation is simpler |
| `IfLetStore` | `.sheet(item:)` with `.scope()` | 1.5+ | Optional navigation built into SwiftUI |
| `@Perception.Bindable` | `@Bindable` (from TCA) | 1.0+ | @Perception not needed; TCA's works everywhere |
| `Shared(value: x)` | `Shared(x)` or `Shared(wrappedValue: x, key:)` | 1.8+ | Correct argument label required |
| Manual `.onReceive()` | `@Bindable` with `@ObservableState` | 1.5+ | Observation is automatic |
| Multiple writers to `@Shared` | Single owner + `@SharedReader` | 1.8+ | Reference semantics require discipline |

---

## 📖 Core Pattern Areas

### 1. **Pattern Foundations** (guides/TCA-PATTERNS.md)
- Pattern 1: Observing state in views with `@Bindable`
- Pattern 2: Optional state navigation (sheets + scope)
- Pattern 3: Multiple navigation destinations
- Pattern 4: Form input bindings
- Pattern 5: Shared state with `@Shared` and `@SharedReader`
- Common mistakes and how to avoid them

### 2. **Navigation Patterns** (guides/TCA-NAVIGATION.md)
- Sheet-based optional child features
- Multiple enum-based destinations
- Popover and alert presentations
- Navigation stack integration
- Lifecycle management and state cleanup

### 3. **Shared State Discipline** (guides/TCA-SHARED-STATE.md)
- Single owner pattern for `@Shared`
- `@SharedReader` for read-only access
- Persistence integration (.appStorage, .fileStorage, custom keys)
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
- **DISCOVERY-16-TCA-SWIFTUI-TYPE-INFERENCE.md** - Type inference anti-patterns and performance

---

## 🏗️ Architecture Principles

### Modern TCA Feature Structure (TCA 1.23.0+)

```swift
@Reducer
struct Feature {
  @ObservableState
  struct State: Equatable {
    // Feature-local state only
    var count = 0
    @Shared var globalAuth: AuthState  // External shared state
  }

  enum Action {
    case userAction
    case internalAction
    case delegate(DelegateAction)

    enum DelegateAction {
      case parentNeedsToKnow
    }
  }

  @Dependency(\.dateClient) var dateClient
  @Dependency(\.serviceClient) var serviceClient

  var body: some ReducerOf<Self> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .userAction:
        // Logic here
        return .none
      case .internalAction:
        return .none
      case .delegate:
        return .none
      }
    }

    // Child features as scoped reducers
    .ifLet(\._child, action: \.child) {
      ChildFeature()
    }
  }
}
```

### Integration with SwiftUI

```swift
struct FeatureView: View {
  @Bindable var store: StoreOf<Feature>

  var body: some View {
    VStack {
      Text(store.title)
      TextField("Enter text", text: $store.text)
        .onSubmit { store.send(.submitButtonTapped) }
    }
    .sheet(item: $store.scope(state: \.child, action: \.child)) { childStore in
      ChildView(store: childStore)
    }
  }
}
```

---

## 🚨 Red Flags: Stop and Re-Read

If you see yourself about to write any of these, **stop immediately**:

| Red Flag | Read This Section | Why |
|----------|-------------------|-----|
| Using `WithViewStore` in code | TCA-PATTERNS.md Pattern 1 | Deprecated since TCA 1.5 |
| `Shared(value: x)` constructor | TCA-SHARED-STATE.md | Wrong label in TCA 1.23.0+ |
| Multiple features mutating `@Shared` | TCA-SHARED-STATE.md Discipline | Race condition guaranteed |
| Calling `Date()` directly in reducer | TCA-DEPENDENCIES.md | Override through dependency client |
| Testing view store internals | TCA-TESTING.md | Test public interface only |
| `@Perception.Bindable` in SwiftUI | TCA-PATTERNS.md | Use TCA's `@Bindable` instead |
| Nested `CombineReducers` in body | DISCOVERY-16 Type Inference | Causes compilation hangs |
| Using `Task.detached` | TCA-DEPENDENCIES.md | Use `Task { @MainActor in ... }` |

---

## 🎓 Before You Implement

Every TCA task should follow this checklist:

1. **Check TCA Version** - Are you targeting TCA 1.23.0+?
2. **Verify Swift Version** - Swift 6.2+ for strict concurrency?
3. **Identify Pattern** - Which pattern applies? (state observation, navigation, shared state, testing?)
4. **Review Relevant Guide** - Read the complete guide for that pattern
5. **Check Verification Checklist** - Each guide has a verification checklist—review it before coding
6. **Implement Against Checklist** - Code should pass checklist items by design, not after debugging

---

## 📚 Documentation Organization

```
/Volumes/Plutonian/_Developer/Maxwells/source/TCA/
├── skill/
│   ├── SKILL.md                    ← You are here
│   ├── guides/
│   │   ├── TCA-PATTERNS.md         ← Core patterns (observation, navigation, shared)
│   │   ├── TCA-NAVIGATION.md       ← All navigation scenarios
│   │   ├── TCA-SHARED-STATE.md     ← @Shared discipline and testing
│   │   ├── TCA-DEPENDENCIES.md     ← Dependency injection patterns
│   │   ├── TCA-TESTING.md          ← Swift Testing integration
│   │   └── TCA-TRIGGERS.md         ← Effect composition and routing
│   ├── references/
│   │   └── DISCOVERY-16-...md      ← Type inference anti-patterns
│   ├── snippets/                   ← Code examples (coming soon)
│   ├── examples/                   ← Full feature examples (coming soon)
│   └── resources/                  ← Reference materials (coming soon)
├── agent/
│   ├── AGENTS-TCA-PATTERNS.md      ← Agent implementation guidance
│   └── SMITH-TCA.md                ← Smith validation integration
└── README.md                        ← Project overview
```

---

## 🔗 Related Resources

### Official TCA Repository
- [Swift Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
- [Point-Free Documentation](https://www.pointfree.co)

### Apple Documentation
- Use sosumi-skill for platform-specific guidance
- WWDC sessions on TCA and SwiftUI patterns

### Validation Tools
- `smith-cli validate --tca` for architectural validation
- Swift compiler strict concurrency checks

---

## 🧪 Testing Knowledge

Before implementing TCA patterns, verify you can answer:

1. **What's the difference between `@Bindable` and `@Perception.Bindable`?**
   - Only use TCA's `@Bindable`; @Perception is not needed in TCA 1.5+

2. **When should I use `.sheet(item:)` instead of `IfLetStore`?**
   - Always use `.sheet(item:)` with `.scope()`; IfLetStore is deprecated

3. **How do I test `@Shared` state in a feature?**
   - Use fixture setup in test, mutate in reducer, verify in assertions

4. **What's the single owner pattern for `@Shared`?**
   - One feature owns and writes; others read via `@SharedReader`

5. **Should this be `@Shared` or `@Dependency`?**
   - `@Shared`: Cross-feature state, authentication, global settings
   - `@Dependency`: Service layer, external APIs, platform integration

---

## 🚀 Quick Start Examples

### Example 1: Simple Feature with State Observation
See `guides/TCA-PATTERNS.md` Pattern 1

### Example 2: Navigation with Optional Child
See `guides/TCA-NAVIGATION.md` Sheet-based pattern

### Example 3: Shared State with Single Owner
See `guides/TCA-SHARED-STATE.md` Discipline section

### Example 4: Testing a Reducer
See `guides/TCA-TESTING.md` TestStore patterns

---

## 📋 Verification Checklist (All Patterns)

Before submitting any TCA code:

- [ ] Uses TCA 1.23.0+ patterns (no deprecated APIs)
- [ ] State marked with `@ObservableState`
- [ ] Reducers marked with `@Reducer`
- [ ] Views use `@Bindable` for state observation
- [ ] Navigation uses `.sheet(item:)` or navigation stack, not `IfLetStore`
- [ ] All side effects through `@Dependency`, never direct system calls
- [ ] `@Shared` follows single owner + `@SharedReader` pattern
- [ ] Tests use Swift Testing framework (not XCTest)
- [ ] Tests marked `@MainActor`
- [ ] No nested `CombineReducers` in reducer body
- [ ] All reducer functions use `@ReducerBuilder`
- [ ] Type checking passes without infinite compilation

---

## 📞 Getting Help

### For Pattern Questions
1. Identify the pattern (state observation, navigation, shared state, testing, dependencies)
2. Read the relevant guide in `guides/`
3. Check the verification checklist at the end of the guide
4. Review examples if available

### For Bug Fixes
1. Search `references/DISCOVERY-*.md` for similar symptoms
2. Read the matching DISCOVERY document (5-10 min usually)
3. Follow the fix described

### For Architectural Decisions
1. Check `guides/` for decision trees
2. Review agent documents for specialized guidance

---

**tca-guidance v1.0.0 - Production Ready**

Specialized TCA expertise for modern Swift development teams.

*Last updated: November 20, 2025*
