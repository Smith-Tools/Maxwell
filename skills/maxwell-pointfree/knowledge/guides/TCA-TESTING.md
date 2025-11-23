# TCA Testing Guide

> **Testing guidance for The Composable Architecture - See canonical documentation**

## 📖 **Canonical Source: AGENTS-AGNOSTIC.md**

All comprehensive TCA testing patterns have been consolidated into the canonical testing documentation:

### **Complete Testing Coverage →** `knowledge/concepts/universal-principles.md`

**Key Sections:**
- **Swift Testing Framework (Required)** - Modern @Test and #expect() patterns
- **TCA-Specific Testing Patterns** - Complete test examples and coverage requirements
- **@Shared State Testing** - Multi-feature state testing patterns
- **Effect Testing with Cancellation** - Async effect testing strategies
- **Testing Anti-Patterns** - What to avoid and why
- **Dependency Injection in Tests** - @TestDependency patterns

---

## 🎯 **Quick Navigation**

**For Complete TCA Testing:**
```bash
# Open the comprehensive testing guide
open knowledge/concepts/universal-principles.md
# Search for "TCA-Specific Testing Patterns"
```

**Key Testing Patterns Include:**
- ✅ **80%+ Test Coverage** standards for reducers and business logic
- ✅ **100% Coverage** required for public APIs and critical business logic
- ✅ **Comprehensive Test Examples** with full reducer flows
- ✅ **@Shared State Testing** for multi-feature applications
- ✅ **Effect Testing** with proper cancellation handling
- ✅ **Anti-Pattern Detection** to avoid common testing mistakes

---

## 🔄 **Why This Was Consolidated**

**Benefits of Canonical Documentation:**
- **Single Source of Truth** - No conflicting testing guidance
- **Comprehensive Coverage** - All testing patterns in one location
- **Enhanced Content** - Combined TCA-specific examples with general testing framework
- **Better Maintenance** - Updates only needed in one place
- **Improved Navigation** - Clear structure from general → TCA-specific

---

**📂 See Also:**
- [`AGENTS-TCA-PATTERNS.md`](../../../patterns/AGENTS-TCA-PATTERNS.md#testing) - TCA pattern testing
- [`TCA_SKILL_EXPERTISE`](../../../routing.yaml) - Complete TCA skill routing
- [`@MainActor Testing`](../../../concepts/universal-principles.md#testing-do--dont) - Threading requirements