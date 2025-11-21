# TCA Guides - Complete Index

This directory contains comprehensive guides for The Composable Architecture (TCA) 1.23.0+ development.

---

## 📖 Guide Structure

### **Foundation Guides** (Start here for basic patterns)

#### [TCA-PATTERNS.md](./TCA-PATTERNS.md) - Core Patterns
**Purpose:** Master the 5 canonical TCA patterns used across all applications

**Contents:**
- Pattern 1: Observing state in views with `@Bindable`
- Pattern 2: Optional child features with sheets
- Pattern 3: Multiple navigation destinations
- Pattern 4: Form input bindings
- Pattern 5: Shared state with `@Shared` and `@SharedReader`
- Common mistakes and how to avoid them
- Type inference anti-patterns and performance

**Read this when:**
- Starting TCA development
- Building views that observe state
- Implementing navigation
- Using shared state
- Debugging reducer-view communication

**Key concepts:**
- `@ObservableState` on state
- `@Bindable` for view property access
- `.sheet(item:)` for optional children
- `@Shared` single owner discipline
- Verification checklists

---

#### [TCA-NAVIGATION.md](./TCA-NAVIGATION.md) - All Navigation Patterns
**Purpose:** Master all navigation scenarios in TCA

**Contents:**
- Sheet-based optional child features
- Multiple enum-based destinations
- Popover and alert presentations
- Navigation stack integration
- Lifecycle management and cleanup
- State persistence across navigation

**Read this when:**
- Designing feature navigation flows
- Implementing optional features
- Handling multiple presentation scenarios
- Debugging navigation state
- Cleaning up after dismissal

**Key concepts:**
- Navigation stack vs sheets vs popovers
- Scope lifecycle
- Proper state cleanup
- Destination routing

---

### **Advanced Guides** (Deep dives into specific areas)

#### [TCA-SHARED-STATE.md](./TCA-SHARED-STATE.md) - @Shared Discipline
**Purpose:** Master shared state patterns and avoid race conditions

**Contents:**
- Single owner pattern
- `@SharedReader` for read-only access
- Persistence integration
- Testing @Shared state
- Race condition prevention
- Fixture management

**Read this when:**
- Multiple features need same state
- Implementing authentication state
- Persisting user settings
- Testing features with @Shared
- Debugging shared state mutations

**Key concepts:**
- Single owner writes, others read
- Persistence keys and strategies
- @SharedReader discipline
- Test fixtures for @Shared
- Reference semantics

---

#### [TCA-DEPENDENCIES.md](./TCA-DEPENDENCIES.md) - Dependency Injection
**Purpose:** Master modern dependency injection patterns

**Contents:**
- `@DependencyClient` pattern
- Swift 6.2 strict concurrency
- Test and preview values
- Mocking strategies
- Platform-specific injection
- Common anti-patterns

**Read this when:**
- Creating dependencies for services
- Mocking APIs for testing
- Integrating external systems
- Overriding system dependencies
- Testing side effects

**Key concepts:**
- `@DependencyClient` macro
- `testValue` and `previewValue`
- Dependency overrides
- Proper async/await handling
- Test-specific implementations

---

#### [TCA-TESTING.md](./TCA-TESTING.md) - Testing Strategies
**Purpose:** Master TCA testing with Swift Testing framework

**Contents:**
- Swift Testing framework setup
- TestStore patterns and assertions
- Testing reducers and effects
- @Shared state testing
- Deterministic time with TestClock
- Common testing mistakes

**Read this when:**
- Writing tests for TCA features
- Testing async effects
- Testing @Shared mutations
- Debugging test failures
- Setting up test fixtures

**Key concepts:**
- `@Test` and `#expect()`
- TestStore setup and assertions
- `TestClock` for deterministic time
- Effect testing patterns
- @Shared test fixtures

---

### **Reference Guides** (Decision trees and troubleshooting)

#### [TCA-TRIGGERS.md](./TCA-TRIGGERS.md) - Action Routing & Effects
**Purpose:** Master action routing, effect composition, and cancellation

**Contents:**
- Action routing patterns
- Effect composition and chaining
- Proper cancellation
- Long-running task management
- Async/await in effects

**Read this when:**
- Complex action routing
- Composing multiple effects
- Canceling long-running tasks
- Debugging effect flows
- Managing async operations

**Key concepts:**
- Effect chaining
- Cancellation tokens
- Task lifecycle
- Action composition

---

## 🎯 Quick Navigation by Task

### **I want to...**

#### **...understand TCA basics**
→ Start with [TCA-PATTERNS.md](./TCA-PATTERNS.md) Pattern 1

#### **...implement navigation**
→ Read [TCA-NAVIGATION.md](./TCA-NAVIGATION.md)

#### **...work with shared state**
→ Read [TCA-SHARED-STATE.md](./TCA-SHARED-STATE.md)

#### **...create dependencies**
→ Read [TCA-DEPENDENCIES.md](./TCA-DEPENDENCIES.md)

#### **...write tests**
→ Read [TCA-TESTING.md](./TCA-TESTING.md)

#### **...debug a complex reducer**
→ Read [TCA-TRIGGERS.md](./TCA-TRIGGERS.md)

#### **...understand type inference issues**
→ Read [TCA-PATTERNS.md](./TCA-PATTERNS.md) Critical Section

---

## 📋 Reading Recommendations by Experience Level

### **Beginner (New to TCA)**
1. [TCA-PATTERNS.md](./TCA-PATTERNS.md) Pattern 1 (10 min)
2. [TCA-NAVIGATION.md](./TCA-NAVIGATION.md) Sheet-based pattern (10 min)
3. [TCA-TESTING.md](./TCA-TESTING.md) Basic setup (15 min)

**Total time: ~35 minutes to be productive**

### **Intermediate (Familiar with basics)**
1. [TCA-PATTERNS.md](./TCA-PATTERNS.md) All patterns (30 min)
2. [TCA-SHARED-STATE.md](./TCA-SHARED-STATE.md) (20 min)
3. [TCA-DEPENDENCIES.md](./TCA-DEPENDENCIES.md) (25 min)

**Total time: ~75 minutes for comprehensive understanding**

### **Advanced (Production code)**
1. Review all guides (60 min)
2. Focus on verification checklists
3. Reference DISCOVERY docs for edge cases

---

## 🔍 Common Patterns Quick Reference

| Pattern | Guide | Section |
|---------|-------|---------|
| Observing state in views | TCA-PATTERNS.md | Pattern 1 |
| Optional child features | TCA-NAVIGATION.md | Sheet-based |
| Multiple destinations | TCA-NAVIGATION.md | Multiple enum |
| Form bindings | TCA-PATTERNS.md | Pattern 4 |
| Shared authentication | TCA-SHARED-STATE.md | Single owner |
| Global settings | TCA-SHARED-STATE.md | Persistence |
| API client | TCA-DEPENDENCIES.md | @DependencyClient |
| Testing reducers | TCA-TESTING.md | TestStore |
| Testing effects | TCA-TESTING.md | Async effects |
| Complex routing | TCA-TRIGGERS.md | Action routing |

---

## ⚠️ Red Flags by Guide

Each guide contains a "Red Flags" section identifying common mistakes:

- **TCA-PATTERNS.md:** `WithViewStore`, `Shared(value:)`, nested composition
- **TCA-NAVIGATION.md:** Missing scope lifecycle, improper cleanup
- **TCA-SHARED-STATE.md:** Multiple writers, missing `@SharedReader`
- **TCA-DEPENDENCIES.md:** Direct system calls, no test overrides
- **TCA-TESTING.md:** Using XCTest, missing `@MainActor`, mocking mistakes

---

## 📊 Document Size Reference

| Document | Lines | Read Time |
|----------|-------|-----------|
| TCA-PATTERNS.md | ~800 | 30 min |
| TCA-NAVIGATION.md | ~500 | 20 min |
| TCA-SHARED-STATE.md | ~400 | 15 min |
| TCA-DEPENDENCIES.md | ~450 | 18 min |
| TCA-TESTING.md | ~400 | 15 min |
| TCA-TRIGGERS.md | ~350 | 13 min |

---

## 🔗 Cross-References

Most guides reference each other:

```
TCA-PATTERNS.md (core)
├── References TCA-NAVIGATION.md for navigation patterns
├── References TCA-SHARED-STATE.md for @Shared
├── References TCA-DEPENDENCIES.md for DependencyClient
└── References TCA-TESTING.md for testing patterns

TCA-NAVIGATION.md
├── Uses patterns from TCA-PATTERNS.md
├── References TCA-TESTING.md for navigation testing
└── References TCA-DEPENDENCIES.md for nested dependencies

TCA-SHARED-STATE.md
├── Uses patterns from TCA-PATTERNS.md
├── References TCA-TESTING.md for @Shared testing
└── References TCA-DEPENDENCIES.md for persistence

TCA-TESTING.md
├── References all guides
└── Provides testing strategies for all patterns

TCA-DEPENDENCIES.md
├── Uses patterns from TCA-PATTERNS.md
├── References TCA-TESTING.md for mocking
└── Integrates with TCA-SHARED-STATE.md
```

---

## 📝 Verification Checklists

Every guide ends with a verification checklist. Before submitting code:

1. **Identify which patterns you're using**
2. **Find the relevant guide**
3. **Review the verification checklist**
4. **Ensure your code passes every item**

This is how we prevent bugs.

---

## 🎓 Study Strategy

### **Quick (15 min) - Single feature addition**
- Identify pattern (e.g., "adding optional child feature")
- Read relevant section in one guide
- Check verification checklist
- Implement

### **Medium (45 min) - Multiple patterns**
- Read one complete guide relevant to task
- Check cross-references
- Review verification checklist
- Implement

### **Deep (2+ hours) - Complex architecture**
- Read multiple guides in order
- Study patterns and anti-patterns
- Review all verification checklists
- Design before implementing

---

## 🚀 Next Steps

1. **Identify your current skill level** (Beginner/Intermediate/Advanced)
2. **Follow the reading recommendations** for your level
3. **Use the verification checklists** when writing code
4. **Reference guides** when you encounter unfamiliar patterns
5. **Check the Red Flags section** when debugging

---

**Last updated:** November 20, 2025

**Related documents:**
- `../SKILL.md` - How to use TCA Skill in Claude Code
- `../references/` - DISCOVERY docs for specific issues
- `../../agent/` - Agent implementations and decision support
