# TCA Dependency Injection Guide

> **Modern dependency injection patterns for The Composable Architecture - See canonical documentation**

## 📖 **Canonical Source: AGENTS-AGNOSTIC.md**

All comprehensive dependency injection patterns for TCA have been consolidated into the canonical documentation:

### **Complete Dependency Coverage →** `knowledge/concepts/universal-principles.md`

**Key Sections:**
- **Dependency Injection & Modern TCA Patterns** - Swift 6.2 strict concurrency requirements
- **@DependencyClient Best Practices** - Modern macro-based dependency definition
- **Dependency Usage Patterns** - Proper usage in reducers and features
- **Anti-Patterns to Avoid** - Common mistakes and why they're problematic
- **Testable Logging with Dependency Injection** - Production logging patterns

---

## 🎯 **Quick Navigation**

**For Complete TCA Dependency Injection:**
```bash
# Open the comprehensive dependency guide
open knowledge/concepts/universal-principles.md
# Search for "Dependency Injection & Modern TCA Patterns"
```

**Essential Patterns Include:**
- ✅ **@DependencyClient** macro for Sendable-compliant dependencies
- ✅ **Swift 6.2 strict concurrency** requirements and enforcement
- ✅ **Proper dependency definition** with live and test values
- ✅ **@Shared dependencies** for cross-feature state management
- ✅ **Anti-pattern detection** to avoid common mistakes
- ✅ **Testable dependency patterns** for reliable testing

---

## 🔄 **Why This Was Consolidated**

**Benefits of Canonical Documentation:**
- **Single Source of Truth** - No conflicting dependency guidance
- **Swift 6.2 Compliance** - All patterns meet strict concurrency requirements
- **Comprehensive Coverage** - All dependency patterns in one location
- **Better Maintenance** - Updates only needed in one place
- **Testability Focus** - Emphasis on testable dependency injection

---

## 🚨 **Critical: Swift 6.2 Requirements**

**This is not optional - it's a language requirement:**

```swift
// ❌ Old patterns (don't compile with strict concurrency)
@Perception.Bindable
Manual DependencyKey + extension DependencyValues

// ✅ Modern patterns (TCA 1.23.0+ with Swift 6.2)
@DependencyClient  // Macro handles Sendable + concurrency
@Bindable          // Optimized for strict concurrency
@ObservableState   // Works with Sendable requirements
```

---

**📂 See Also:**
- [`AGENTS-DECISION-TREES.md`](../../../patterns/AGENTS-DECISION-TREES.md) - When to use @DependencyClient vs Singleton
- [`TCA_SKILL_EXPERTISE`](../../../routing.yaml) - Complete TCA skill routing
- [`@Shared State Patterns`](../../../concepts/universal-principles.md#shared-state-shared) - Cross-feature state management