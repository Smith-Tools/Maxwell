# TCA Shared State Patterns

> **Guidance for @Shared state management in The Composable Architecture**

## Shared State (@Shared)

- **[STANDARD] Use `@Shared` for cross-feature state** when multiple features need simultaneous access to mutable state without prop drilling.
  - When: Authentication data, onboarding status, user info, feature flags shared across unrelated features
  - Why: Eliminates prop drilling complexity; maintains value-type semantics; integrates with persistence (UserDefaults, file storage)
  - Not: Don't use for simple feature-local state (use @ObservableState) or when clear parent-child hierarchy exists (use @DependencyClient)
- **[STANDARD] `@Shared` requires discipline and exhaustive testing** - Reference semantics under the hood mean mutations affect all holders instantly.
- **[STANDARD] Prefer `@SharedReader`** when a feature only needs to read shared state (no mutations).
- **[GUIDANCE] Consider `@Shared` with persistence** (`.appStorage`, `.fileStorage`) for user preferences and system-of-record data.
- **Example Use Case:** Leaf reducers (unrelated features) both need current user info and authentication status
  ```swift
  // Define shared state at root
  @Shared(.appStorage("currentUser")) var currentUser: User?

  // Both features can read/write without explicit dependency chain
  @Reducer
  struct FeatureA {
    @Shared(.appStorage("currentUser")) var currentUser: User?
    // Can read and mutate currentUser
  }

  @Reducer
  struct FeatureB {
    @Shared(.appStorage("currentUser")) var currentUser: User?
    // Also has access, mutations visible to FeatureA instantly
  }
  ```

**Reference:** Point-Free blog post 135 "Shared State in the Composable Architecture" (https://www.pointfree.co/blog/posts/135-shared-state-in-the-composable-architecture)

## Critical @Shared Discipline

### Single Owner Pattern
- **[CRITICAL] Single writer, multiple readers** - Only one feature should own and mutate @Shared state
- **[STANDARD] Use `@SharedReader`** for all features that only need read access
- **[ANTI-PATTERN] Multiple writers** - Avoid having multiple features directly mutate the same @Shared instance

### Persistence Integration
- **[STANDARD] Use appropriate persistence** for @Shared state:
  - `.appStorage()` - User preferences, settings (UserDefaults)
  - `.fileStorage()` - Documents, complex data structures (Files)
  - `.inMemory()` - Temporary session data (Memory only)

### Testing @Shared State
- **[STANDARD] Test mutation ripple effects** - Verify that changes in one feature propagate to others
- **[CRITICAL] Test race conditions** - Multiple features accessing @Shared simultaneously
- **[GUIDANCE] Use TestStore** with @Shared state fixtures