# TCA Skill - Usage Triggers & Routing

> **When Claude should use the TCA skill and how to route TCA-specific questions**

## Auto-Load Keywords

The TCA skill automatically loads when Claude detects these keywords:

### **Primary TCA Keywords**
- "TCA", "@Reducer", "@ObservableState", "@Shared"
- "ComposableArchitecture", "StoreOf", "store.send"
- "@Bindable", "WithViewStore", "ViewStore", "IfLetStore"
- "SwiftUI navigation with TCA", "TCA patterns"
- "monolithic features", "reducer extraction", "TCA composition"

### **TCA Pattern Keywords**
- "TCA state management", "TCA testing", "TCA dependencies"
- "TCA anti-patterns", "deprecated TCA", "TCA migration"
- "@Shared state", "single owner pattern", "@SharedReader"
- "TCA navigation", "sheet presentation", ".scope()"

### **TCA Problem Keywords**
- "TCA reducer won't compile", "TCA compilation errors"
- "WithViewStore deprecated", "migrate from WithViewStore"
- "TCA testing patterns", "TestStore", "expectNoDifference"
- "TCA performance issues", "TCA best practices"

## Routing Decision Tree

### **1. Is this about TCA patterns?**
```
Question mentions TCA, @Reducer, @ObservableState, @Shared?
YES → Use TCA skill
NO  → Check other skills
```

### **2. Is this about TCA testing?**
```
Question mentions TCA testing, TestStore, @MainActor?
YES → Use TCA skill (TCA-TESTING.md)
NO  → Continue routing
```

### **3. Is this about TCA navigation?**
```
Question mentions SwiftUI navigation with TCA, sheets, .scope?
YES → Use TCA skill (TCA-NAVIGATION.md)
NO  → Continue routing
```

### **4. Is this about TCA anti-patterns?**
```
Question mentions deprecated APIs, migration issues?
YES → Use TCA skill (TCA-PATTERNS.md anti-patterns section)
NO  → Continue routing
```

## Example Routing Scenarios

### **Definitely TCA Skill**
```bash
"How do I migrate from WithViewStore to @Bindable?" → TCA skill
"Is my @Shared state usage correct?" → TCA skill
"My TCA reducer has compilation errors" → TCA skill
"How should I test my TCA feature?" → TCA skill
"Should I use @Shared or @Dependency for this state?" → TCA skill
```

### **Combined Skills**
```bash
"Implement TCA with proper build optimization" → smith skill + TCA skill
"TCA app with visionOS RealityKit integration" → TCA skill + sosumi skill
"TCA app with performance monitoring" → smith skill + TCA skill
```

### **Not TCA Skill**
```bash
"General Swift dependency injection" → smith skill
"Xcode build hanging" → smith skill (xcsift)
"Apple API documentation" → sosumi skill
"Swift package structure" → smith skill (spmsift)
```

## Claude Skill Selection Logic

```swift
// Simplified routing logic Claude uses
func routeToSkill(userQuestion: String) -> Skill {
  let tcaKeywords = ["TCA", "@Reducer", "@ObservableState", "@Shared",
                     "ComposableArchitecture", "WithViewStore", "StoreOf"]

  let containsTCAKeywords = tcaKeywords.contains { userQuestion.contains($0) }

  if containsTCAKeywords {
    return .tcaGuidance
  } else if userQuestion.contains("build") || userQuestion.contains("xcode") {
    return .smith
  } else if userQuestion.contains("API") || userQuestion.contains("documentation") {
    return .sosumi
  } else {
    return .smith // Default for general Swift questions
  }
}
```

## TCA Skill Content Mapping

| User Question | TCA Skill File | Section |
|---------------|----------------|---------|
| "TCA patterns" | TCA-PATTERNS.md | Patterns 1-5 |
| "@Shared state" | TCA-SHARED-STATE.md | Discipline section |
| "TCA dependencies" | TCA-DEPENDENCIES.md | @DependencyClient patterns |
| "TCA testing" | TCA-TESTING.md | TestStore usage |
| "TCA navigation" | TCA-NAVIGATION.md | SwiftUI integration |
| "Migration issues" | TCA-PATTERNS.md | Anti-patterns section |
| "Architecture decisions" | TCA-DEPENDENCIES.md | Decision trees |

## Integration with smith-validation

### **When to Use Both**
```bash
"Analyze my TCA architecture for violations"
→ smith-cli validate --tca + TCA skill for guidance

"My TCA code fails validation"
→ TCA skill for patterns + smith-validation for fixes
```

### **Tool Integration**
- **TCA skill**: Provides patterns and guidance
- **smith-validation**: Automated rule checking (Rules 1.1-1.5)
- **Combined**: Pattern guidance + automated validation

## Common User Intent Patterns

### **Pattern Learning**
```
User: "What's the right TCA pattern for shared state?"
Route: TCA skill → TCA-SHARED-STATE.md → Single owner pattern
```

### **Problem Solving**
```
User: "My @Shared state causes race conditions"
Route: TCA skill → TCA-SHARED-STATE.md → Discipline violations
```

### **Migration Help**
```
User: "How do I migrate from deprecated APIs?"
Route: TCA skill → TCA-PATTERNS.md → Anti-patterns section
```

### **Testing Questions**
```
User: "How do I test TCA reducers properly?"
Route: TCA skill → TCA-TESTING.md → Swift Testing patterns
```

## Quality Assurance

### **Before Responding, TCA Skill Should:**
1. ✅ Identify TCA version context (1.23.0+ preferred)
2. ✅ Check for deprecated API usage
3. ✅ Verify platform-specific considerations
4. ✅ Provide code examples with modern patterns
5. ✅ Include testing recommendations

### **Response Structure:**
1. **Pattern identification** - What TCA concept applies
2. **Modern solution** - Current best practice (TCA 1.23.0+)
3. **Code example** - Complete, working implementation
4. **Anti-pattern warnings** - What to avoid
5. **Testing guidance** - How to test the pattern
6. **Platform notes** - Any platform-specific considerations

## Red Flag Detection

The TCA skill should stop and provide stronger guidance when detecting:

| Red Flag | Response |
|----------|----------|
| `WithViewStore` usage | Explain deprecation, show @Bindable migration |
| `Shared(value:)` constructor | Correct to `Shared(wrappedValue:)` |
| Multiple @Shared writers | Explain single-owner pattern |
| Missing @MainActor in tests | Show proper TCA testing setup |
| Direct Date() calls in reducers | Explain dependency injection |
| Task.detached in effects | Show proper TCA concurrency patterns |