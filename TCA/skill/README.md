# TCA Skill - The Composable Architecture for Claude Code

**Comprehensive TCA 1.23.0+ expertise for Swift development teams**

---

## 📖 What is This Skill?

This is a Claude Code Skill providing production-ready guidance for The Composable Architecture (TCA), a modern state management framework for Swift applications on iOS, macOS, visionOS, and watchOS.

**This skill includes:**

- ✅ **Modern TCA 1.23.0+ Patterns** - Current best practices and canonical patterns
- ✅ **Anti-Pattern Detection** - Deprecated APIs and common mistakes
- ✅ **Comprehensive Guides** - 2900+ lines of detailed documentation
- ✅ **Decision Trees** - Guidance for architectural choices
- ✅ **DISCOVERY Documents** - Case studies for specific problems
- ✅ **Code Examples** - Real-world patterns and implementations
- ✅ **Testing Strategies** - Swift Testing integration
- ✅ **Verification Checklists** - Ensure code meets standards

---

## 🚀 Quick Start

### **Using in Claude Code**

Invoke this skill when you need TCA guidance:

```
"How should I structure TCA navigation?"
"Is this the right pattern for shared state?"
"How do I test this reducer?"
"My code won't compile—type inference issues"
"Should I use @Shared or @Dependency?"
```

Claude will automatically use this skill and provide TCA-specific guidance with pattern recommendations.

### **Getting Started as a Developer**

1. **New to TCA?** → Start with `guides/TCA-PATTERNS.md`
2. **Need navigation?** → Read `guides/TCA-NAVIGATION.md`
3. **Shared state?** → Study `guides/TCA-SHARED-STATE.md`
4. **Writing tests?** → Follow `guides/TCA-TESTING.md`
5. **Debugging?** → Search `references/DISCOVERY-*.md`

---

## 📚 Directory Structure

```
skill/
├── SKILL.md                    ← Skill metadata & overview
├── README.md                   ← You are here
├── CLAUDE.md                   ← Instructions for Claude
│
├── guides/                     ← Comprehensive guides (2900+ lines)
│   ├── README.md              ← Guides index
│   ├── TCA-PATTERNS.md        ← Core patterns (observation, navigation, shared)
│   ├── TCA-NAVIGATION.md      ← All navigation scenarios
│   ├── TCA-SHARED-STATE.md    ← @Shared discipline
│   ├── TCA-DEPENDENCIES.md    ← Dependency injection
│   ├── TCA-TESTING.md         ← Swift Testing integration
│   └── TCA-TRIGGERS.md        ← Action routing & effects
│
├── references/                ← Investigation & case studies
│   ├── README.md              ← References index
│   └── DISCOVERY-16-...md     ← Type inference issues
│
├── snippets/                  ← Reusable code fragments
│   └── README.md              ← Coming soon
│
├── examples/                  ← Complete feature examples
│   └── README.md              ← Coming soon
│
└── resources/                 ← External references
    └── README.md              ← Coming soon
```

---

## 🎯 Core Concepts at a Glance

### **Modern TCA Architecture (TCA 1.23.0+)**

```swift
@Reducer
struct Feature {
  @ObservableState
  struct State {
    var count = 0
    @Shared var globalState: SharedData
  }

  enum Action {
    case increment
    case child(ChildFeature.Action)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      // Logic here
      return .none
    }
    .ifLet(\._child, action: \.child) {
      ChildFeature()
    }
  }
}

struct FeatureView: View {
  @Bindable var store: StoreOf<Feature>

  var body: some View {
    Button("Increment") { store.send(.increment) }
    Text("\(store.count)")
  }
}
```

### **5 Core Patterns**

1. **State Observation** - Use `@Bindable` to observe store state
2. **Optional Navigation** - Use `.sheet(item:)` with `.scope()` for child features
3. **Multiple Destinations** - Use enum-based routing
4. **Form Bindings** - Use `$store.property` for two-way bindings
5. **Shared State** - Use `@Shared` with single owner + `@SharedReader` pattern

---

## ⚡ Quick Reference: What NOT to Do

| ❌ Deprecated/Wrong | ✅ Modern Alternative |
|---|---|
| `WithViewStore` | `@Bindable` + direct property access |
| `IfLetStore` | `.sheet(item:)` with `.scope()` |
| `@Perception.Bindable` | `@Bindable` (from TCA) |
| `Shared(value: x)` | `Shared(x)` or `Shared(wrappedValue: x, key:)` |
| Nested `CombineReducers` | Flat `@ReducerBuilder` composition |

---

## 🧭 Where to Find What

### **For Pattern Questions**
→ `guides/` directory

**Example:** "How do I implement optional child features?"
→ Read `guides/TCA-NAVIGATION.md`

### **For Debugging Issues**
→ `references/DISCOVERY-*.md` documents

**Example:** "My reducer takes 5+ minutes to compile"
→ Read `references/DISCOVERY-16-TCA-SWIFTUI-TYPE-INFERENCE.md`

### **For Code Examples**
→ `examples/` directory (coming soon)

**Example:** "Show me a complete counter feature"
→ Review `examples/basic-features/counter-feature/`

### **For Quick Snippets**
→ `snippets/` directory (coming soon)

**Example:** "I need a @Shared setup example"
→ See `snippets/shared-state/`

---

## 📋 Reading Recommendations

### **I have 15 minutes**
Read: `guides/TCA-PATTERNS.md` Pattern 1 (state observation)

### **I have 45 minutes**
Read in order:
1. `guides/TCA-PATTERNS.md` Pattern 1
2. `guides/TCA-NAVIGATION.md` Sheet-based pattern
3. `guides/TCA-TESTING.md` Basic setup

### **I have 2+ hours**
Read all guides in this order:
1. `guides/TCA-PATTERNS.md` - Foundations
2. `guides/TCA-NAVIGATION.md` - Navigation
3. `guides/TCA-SHARED-STATE.md` - Shared state
4. `guides/TCA-DEPENDENCIES.md` - Dependencies
5. `guides/TCA-TESTING.md` - Testing
6. `guides/TCA-TRIGGERS.md` - Advanced

---

## 🚨 Red Flags: Stop and Re-Read

If you see yourself about to write any of these, **stop immediately**:

| Red Flag | Read This | Why |
|----------|-----------|-----|
| Using `WithViewStore` | `guides/TCA-PATTERNS.md` | Deprecated since TCA 1.5 |
| `Shared(value: x)` constructor | `guides/TCA-SHARED-STATE.md` | Wrong label in TCA 1.23.0+ |
| Multiple features mutating `@Shared` | `guides/TCA-SHARED-STATE.md` | Race condition guaranteed |
| Calling `Date()` directly | `guides/TCA-DEPENDENCIES.md` | Override through dependencies |
| Nested `CombineReducers` | `references/DISCOVERY-16` | Compilation hangs |

---

## ✅ Verification Checklists

Every guide includes a verification checklist. Before submitting code:

1. **Identify the pattern** you're implementing
2. **Read the relevant guide**
3. **Review the verification checklist**
4. **Ensure your code passes every item**

This is how we prevent bugs and ensure consistency.

---

## 🔗 Integration with Other Skills

### **smith-skill** (Swift Architecture)
This skill complements smith-skill for TCA-specific validation:
- smith-skill provides general Swift patterns
- tca-guidance provides TCA architecture expertise
- Together they cover Swift + TCA development

### **sosumi-skill** (Apple Documentation)
For platform-specific questions:
- sosumi-skill provides Apple docs and WWDC
- tca-guidance provides TCA patterns
- Together they cover platform + architecture

---

## 📊 Content Statistics

| Component | Count | Size |
|-----------|-------|------|
| Guides | 6 | 2,925 lines |
| References | 1 | 400+ lines |
| Verification Checklists | 6+ | Integrated |
| Code Examples | 30+ | Integrated |
| Red Flag Sections | 6 | Integrated |

---

## 🎯 Success Metrics

When using this skill:

- ✅ **Reduced bugs** - Verification checklists catch issues before code submission
- ✅ **Faster development** - Know exactly which pattern applies
- ✅ **Better decisions** - Decision trees guide architectural choices
- ✅ **Modern patterns** - Always using TCA 1.23.0+ best practices
- ✅ **Confident testing** - Clear testing strategies for all patterns
- ✅ **No deprecated APIs** - Guides prevent use of removed features

---

## 📞 Getting Help

### **For pattern questions**
1. Identify which pattern applies to your task
2. Find the relevant guide in `guides/`
3. Read the complete guide (10-30 min)
4. Check the verification checklist
5. Implement with confidence

### **For debugging**
1. Identify the problem (type error, runtime issue, test failure)
2. Search `references/DISCOVERY-*.md` for your symptom
3. Read the matching DISCOVERY (usually 5-10 min)
4. Apply the solution

### **For architecture decisions**
1. Check if guides include decision trees
2. Review the decision section in relevant guide
3. Reference `AGENTS-TCA-PATTERNS.md` for complex decisions

---

## 🚀 Next Steps

### **As a User of Claude Code**

1. Ask Claude about TCA patterns
2. Claude will automatically use this skill
3. You get TCA-specific guidance

### **As a Developer Reading This Skill**

1. Start with `guides/TCA-PATTERNS.md` Pattern 1
2. Work through patterns in order (observation → navigation → shared state)
3. Use verification checklists when writing code
4. Reference DISCOVERY docs when debugging

### **As a Skill Developer**

See `SKILL.md` for metadata and `AGENTS-TCA-PATTERNS.md` for implementation guidance.

---

## 📈 Roadmap

### **Available Now**
- ✅ TCA-PATTERNS.md - Core patterns
- ✅ TCA-NAVIGATION.md - Navigation
- ✅ TCA-SHARED-STATE.md - Shared state
- ✅ TCA-DEPENDENCIES.md - Dependencies
- ✅ TCA-TESTING.md - Testing
- ✅ TCA-TRIGGERS.md - Advanced
- ✅ DISCOVERY-16 - Type inference

### **Coming Soon**
- 📝 `examples/` - Complete feature examples
- 📝 `snippets/` - Reusable code fragments
- 📝 DISCOVERY-17-20 - Additional case studies
- 📝 `resources/` - API reference & WWDC summaries

---

## 📄 Version Information

**Current Version:** 1.0.0
**TCA Version:** 1.23.0+
**Swift Version:** 6.2+ (strict concurrency required)
**Platforms:** iOS, macOS, visionOS, watchOS
**Last Updated:** November 20, 2025

---

## 🤝 Contributing

To improve this skill:

1. Report issues in the TCA project
2. Suggest improvements to guides
3. Share DISCOVERY topics you encounter
4. Test examples on real codebases

---

## 📚 Related Documents

- **SKILL.md** - Skill metadata and overview
- **CLAUDE.md** - Instructions for Claude when using this skill
- **guides/README.md** - Comprehensive guide index
- **references/README.md** - DISCOVERY documents index
- **../agent/** - Agent implementations and validation

---

**TCA Skill v1.0.0 - Production Ready**

*Specialized TCA expertise for modern Swift development teams.*

*Last updated: November 20, 2025*
