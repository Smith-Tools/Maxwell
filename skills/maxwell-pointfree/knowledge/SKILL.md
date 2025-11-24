---
name: Point-Free Ecosystem
description: Point-Free framework coordination expert that analyzes requirements, delegates to framework specialists, and synthesizes integrated solutions across TCA, Dependencies, Navigation, Testing, and other Point-Free frameworks.
tags:
  - "Point-Free"
  - "Coordination"
  - "Integration"
  - "Architecture"
  - "TCA"
  - "Dependencies"
  - "Navigation"
  - "Testing"
  - "Multi-framework"
  - "Swift Composable Architecture"
author: "Claude Code Skill - Maxwell Architecture"
---

# Point-Free Ecosystem Coordination Skill

**For:** Swift development teams using multiple Point-Free frameworks
**Purpose:** Expert coordination and integration across the entire Point-Free ecosystem
**Frameworks:** TCA, Dependencies, Navigation, Testing, Clocks, Sharing
**Integration Level:** Multi-framework architecture coordination

## 🎯 What This Skill Does

### Core Responsibilities

- **Framework Detection** - Automatically identify which Point-Free frameworks are needed
- **Specialist Delegation** - Route questions to appropriate framework specialists
- **Integration Synthesis** - Combine specialist responses into cohesive solutions
- **Pattern Coordination** - Provide cross-framework best practices and patterns
- **Architecture Validation** - Ensure multi-framework implementations follow best practices
- **Testing Strategy** - Coordinate testing approaches across framework boundaries

### When to Use This Skill

**You should invoke this skill when:**

```
"How do I integrate TCA with navigation and API calls?"
"What's the best way to coordinate shared state across multiple features?"
"Should I use @Shared or @Dependency for this use case?"
"How do I test an app that uses TCA, Dependencies, and Navigation together?"
"Build a complete app architecture with Point-Free frameworks"
"I need to coordinate multiple Point-Free frameworks for a complex feature"
```

## 🔄 Integration with Other Skills

### maxwell-tca (TCA Specialist)
- **maxwell-pointfree**: High-level coordination and routing
- **maxwell-tca**: Deep TCA pattern expertise and implementation details
- **When combined**: Use maxwell-pointfree for TCA + other frameworks, maxwell-tca for pure TCA questions

### maxwell-dependencies (Dependencies Specialist)
- **maxwell-pointfree**: Integration decisions and cross-framework coordination
- **maxwell-dependencies**: Dependency injection patterns and @DependencyClient expertise
- **When combined**: Use maxwell-pointfree for architecture decisions, maxwell-dependencies for implementation details

### maxwell-navigation (Navigation Specialist)
- **maxwell-pointfree**: Navigation as part of larger architecture
- **maxwell-navigation**: Deep navigation patterns and state coordination
- **When combined**: Use maxwell-pointfree for full app architecture, maxwell-navigation for navigation specifics

## ⚡ Framework Detection Matrix

| Query Keywords | Primary Framework | Secondary Frameworks | Routing Strategy |
|----------------|-------------------|----------------------|------------------|
| "TCA state", "reducer", "@Bindable" | maxwell-tca | - | Direct routing |
| "dependency", "@Dependency", "injection" | maxwell-dependencies | - | Direct routing |
| "navigation", "routing", "Navigator" | maxwell-navigation | maxwell-tca | Coordinate specialists |
| "test", "TestStore", "snapshot" | maxwell-pointfree-testing | maxwell-tca | Coordinate specialists |
| "integrate", "together", "combine" | maxwell-pointfree | Multiple | Parallel delegation |
| "architecture", "full stack", "complete app" | maxwell-pointfree | All relevant | Sequential coordination |

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

## 🏗️ Coordination Patterns

### Pattern 1: Parallel Specialist Delegation
```
User: "How do I handle API calls with TCA state and navigation?"

→ maxwell-pointfree analyzes query
→ Detects: TCA + Dependencies + Navigation
→ Delegates in parallel:
  - maxwell-tca: "TCA state management for API responses"
  - maxwell-dependencies: "Dependency injection for API clients"
  - maxwell-navigation: "Navigation based on API state"
→ Synthesizes integrated solution
```

### Pattern 2: Sequential Coordination
```
User: "Build an authentication flow"

→ maxwell-pointfree: Architecture planning
→ Delegates to maxwell-tca: "Auth state management"
→ Delegates to maxwell-dependencies: "Auth client dependencies"
→ Delegates to maxwell-navigation: "Navigation flow coordination"
→ Combines into complete implementation
```

### Pattern 3: Decision Tree Routing
```
User: "Should I use @Shared or @Dependency?"

→ maxwell-pointfree: Decision tree analysis
→ Based on: Scope, mutability, testing needs, lifecycle
→ Provides specific recommendation with rationale
→ Optionally delegates to specialist for implementation details
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