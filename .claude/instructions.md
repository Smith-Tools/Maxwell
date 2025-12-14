# maxwell Development Workflow

maxwell is your personal Swift/TCA knowledge base. It surfaces case studies, patterns, and solutions you've discovered and documented.

## Context Gathering Workflow

### 1. Understand Your Current Project

Start with project analysis:

```bash
smith dependencies /path/to/your-project
```

This shows what matters for your implementation.

### 2. Search Personal Discoveries

When you've solved similar problems before, maxwell remembers:

```
Query: "TCA navigation patterns"
Get: Personal case studies, implementations, lessons learned
```

maxwell auto-triggers on:
- Swift/TCA architecture questions
- Debugging patterns you've documented
- Performance optimizations you've implemented
- Testing patterns you've used
- UI/UX solutions you've created

### 3. Cross-Reference with Other Tools

Combine maxwell with:
- **smith**: Project structure and dependencies
- **sosumi**: Official Apple documentation
- **scully**: Package capabilities

### 4. Learn from Pattern Matches

maxwell provides:
- Code you've written before (similar pattern)
- How you debugged similar issues
- Performance optimizations that worked
- Testing approaches you used
- Architectural decisions you made

## Example: TCA Architecture Question

Task: "How should I structure this TCA reducer?"

```
Step 1: smith dependencies
   → See existing reducers in project
   → Understand dependency structure

Step 2: maxwell skill (auto-triggers)
   → Search: "TCA reducer structure"
   → Get: Past reducer implementations
   → See: Patterns you've established

Step 3: Implement
   → Follow your established patterns
   → Reference past implementations
   → Result: Consistent architecture
```

## Example: Performance Debugging

Task: "List scrolling is jittery"

```
Step 1: smith dependencies
   → Identify performance-critical components
   → See related frameworks (SwiftUI, Combine)

Step 2: maxwell skill (auto-triggers)
   → Search: "SwiftUI performance optimization"
   → Get: "Fixed list jitter with memoization"
   → Get: "Debugged render cycles with Instruments"

Step 3: Implement
   → Apply proven optimization pattern
   → Use tested debugging approach
   → Result: Confident fix
```

## Example: Testing Pattern

Task: "How do I test this TCA reducer?"

```
Step 1: maxwell skill (auto-triggers)
   → Search: "TCA testing patterns"
   → Get: Test structure you've used before
   → See: Sample test assertions

Step 2: smith dependencies
   → Understand test dependencies available

Step 3: Implement tests
   → Follow your established testing pattern
   → Use proven test structure
```

## Quick Reference

| Task | How maxwell Helps |
|------|-------------------|
| Architecture | Shows past implementations |
| Performance | Recalls optimization patterns |
| Testing | Provides test structures |
| Debugging | Surfaces debug approaches |
| Patterns | Shows established conventions |

## How maxwell Works

maxwell searches your personal discoveries:
- Located at: `~/.claude/resources/discoveries/`
- Auto-triggered on Swift/TCA questions
- Provides context from past work
- Shows what you've learned before

## Example Discoveries maxwell Might Surface

```
# TCA Navigation Pattern (from maxwell discovery)
When implementing NavigationPath in TCA:
1. Add NavigationPath to AppState
2. Create NavigationStackReducer for navigation
3. Handle .navigationDestination in views
4. Test with XCTestDynamicOverlay

See: Implementation in ProjectX/Sources/Features/Navigation
See: Test pattern in ProjectX/Tests/NavigationReducerTests
```

## Key Principles

✅ **Reuse proven patterns**: What worked before likely works again
✅ **Cross-reference with smith**: Understand project context
✅ **Combine with official docs**: maxwell + sosumi = complete guidance
✅ **Update discoveries**: Add new patterns to maxwell as you learn

## Integration with Smith Tools

When you need complete context:

1. `smith dependencies` → Understand your project
2. maxwell skill → See past implementations (auto-triggers)
3. `sosumi docs <framework>` → Get official guidance
4. `scully patterns <package> --filter <topic>` → Extract usage patterns

## Contributing to maxwell

When you solve a problem or learn a pattern:
1. Document it in `~/.claude/resources/discoveries/`
2. Include: problem, solution, code example, lessons learned
3. maxwell automatically indexes and surfaces it

## Documentation

For the complete integration architecture, see:
**Smith-Tools/AGENT-INTEGRATION.md**
