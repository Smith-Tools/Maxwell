# Framework Detection Engine

**Purpose**: Automatically identify which Point-Free frameworks are needed based on user queries and code context.

## Detection Algorithm

```python
def detect_needed_frameworks(user_query, code_context=None):
    frameworks_needed = []

    # Keyword-based detection
    framework_keywords = {
        'tca': ['tca', 'composable architecture', 'reducer', 'store', '@observablestate', '@bindable'],
        'dependencies': ['dependency', 'injection', '@dependency', '@dependencyclient', 'testvalue'],
        'navigation': ['navigation', 'navigator', 'sheetstack', 'destination', '@cased'],
        'testing': ['testing', 'teststore', 'snapshot', 'macro testing', 'custom dump'],
        'clocks': ['clock', 'timer', 'scheduler', 'testclock', 'immediatescheduler'],
        'sharing': ['sharing', 'persistence', 'filestorage', 'appstorage', 'cloudkit']
    }

    # Analyze user query
    query_lower = user_query.lower()
    for framework, keywords in framework_keywords.items():
        if any(keyword in query_lower for keyword in keywords):
            frameworks_needed.append(framework)

    # Analyze code context if provided
    if code_context:
        for framework, keywords in framework_keywords.items():
            if any(f'@{keyword}' in code_context or f'{keyword}(' in code_context
                   for keyword in keywords):
                if framework not in frameworks_needed:
                    frameworks_needed.append(framework)

    # Special case detection
    if 'integration' in query_lower or 'together' in query_lower:
        # User explicitly wants integration help
        return frameworks_needed  # All detected frameworks

    if len(frameworks_needed) == 0:
        return ['pointfree-general']  # General Point-Free guidance

    return frameworks_needed
```

## Routing Logic

### Single Framework Routes
- **TCA only** → delegate to `maxwell-tca`
- **Dependencies only** → delegate to `maxwell-dependencies`
- **Navigation only** → delegate to `maxwell-navigation`

### Multi-Framework Integration Routes
- **TCA + Dependencies** → Use integration guide `TCA-DEPENDENCIES.md`
- **TCA + Navigation** → Use integration guide `TCA-NAVIGATION.md`
- **Testing + Multiple Frameworks** → Use `TESTING-INTEGRATION.md`

### Complex Multi-Framework Routes
- **3+ frameworks** → Synthesize from multiple specialists
- **Architecture decisions** → Use decision trees
- **Full stack questions** → Use `FULL-STACK-EXAMPLES.md`

## Context Analysis

### Code Context Parsing
```swift
// Example: Analyzing existing code
struct UserQuery {
    let text: String
    let existingCode: String?

    func detectFrameworkNeeds() -> [FrameworkType] {
        var needs = []

        // Check existing imports
        if existingCode?.contains("import ComposableArchitecture") {
            needs.append(.tca)
        }

        // Check existing patterns
        if existingCode?.contains("@Dependency") {
            needs.append(.dependencies)
        }

        // Check user intent
        if text.contains("navigation") || text.contains("routing") {
            needs.append(.navigation)
        }

        return needs
    }
}
```

### Confidence Scoring
Each detection gets a confidence score:
- **High (0.8-1.0)**: Explicit keyword mentions
- **Medium (0.5-0.7)**: Contextual hints
- **Low (0.2-0.4)**: Indirect references

High confidence → Auto-route to specialist
Low confidence → Ask clarification questions