# Smith → Maxwell: Content Extraction & Migration Plan

**Date**: November 23, 2025
**Goal**: Separate Smith (Enforcer) from Maxwell (Oracle) by migrating architectural teaching content to Maxwell's database

---

## Phase 1: Content Extraction from Smith

### What's Being Extracted (Teaching/Guidance Content)

**Source Location**: `Smith/skills/skill-smith/`

#### Category 1: Architectural Decision Trees (Priority: High)

**File**: `patterns/AGENTS-DECISION-TREES.md`
**Destination**: Maxwell `patterns` table (7 individual patterns)

| Tree | Domain | Problem | Solution |
|------|--------|---------|----------|
| Tree 1 | Architecture | When should I create a Swift Package module? | Decision tree: feature count, team size, reusability |
| Tree 2 | DependencyInjection | Should I use @DependencyClient or Singleton? | Decision framework based on context |
| Tree 3 | Architecture | When should I refactor code into a module? | Thresholds and strategic considerations |
| Tree 4 | Architecture | Where should business logic live? | Decision tree: Core, UI, Platform, Infrastructure |
| Tree 5 | Performance | Build performance: where are the bottlenecks? | Analysis and optimization strategy |
| Tree 6 | Performance | How do I optimize compile times? | Incremental strategies and monitoring |
| Tree 7 | Performance | How do I debug type inference explosions? | Root cause analysis and fixes |

**Metadata**:
- Category: "Architecture" or "Performance"
- Role: "guidance" (teaching, not validation)
- Enforcement Level: "advisory" (recommended, not required)
- Tags: "decision-tree,architectural-decision,strategy"

---

#### Category 2: Platform-Specific Guidance (Priority: High)

**Files**: `platforms/PLATFORM-*.md` (4 files)
**Destination**: Maxwell `documents` table

| File | Domain | Purpose |
|------|--------|---------|
| PLATFORM-IOS.md | iOS | UIKit/SwiftUI patterns, platform-specific APIs, lifecycle |
| PLATFORM-IPADOS.md | iPadOS | Multitasking, Split View, iPad-specific features |
| PLATFORM-MACOS.md | macOS | AppKit integration, Catalyst, menu bar apps |
| PLATFORM-VISIONOS.md | visionOS | RealityKit, immersive spaces, spatial computing |

**Metadata**:
- Category: "Platform"
- Subcategory: The specific platform name
- Role: "guidance" (framework expertise)
- Enforcement Level: "optional" (best practice, not requirement)
- Tags: platform name, framework names (UIKit, RealityKit, etc.)

---

#### Category 3: Concurrency Patterns (Priority: Medium)

**Source**: `patterns/AGENTS-AGNOSTIC.md` (lines 215-368)
**Destination**: Maxwell `patterns` table (4 patterns)

| Pattern | Domain | Problem | Solution |
|---------|--------|---------|----------|
| Fire-and-forget async | Concurrency | How to handle async operations that don't need results? | Task.detached with proper lifecycle |
| TaskGroup with timeout | Concurrency | How to manage multiple concurrent tasks safely? | TaskGroup pattern with timeout handling |
| Escaping closures | Concurrency | Managing closures across async boundaries | Proper capture and memory safety |
| Cached-only pattern | Concurrency | When should I avoid network requests? | Cache-first strategy with validation |

**Metadata**:
- Category: "Concurrency"
- Role: "guidance"
- Enforcement Level: "advisory"
- Tags: "concurrency,async-await,Task,TaskGroup"

---

#### Category 4: Dependency Injection Philosophy (Priority: Medium)

**Source**: `patterns/AGENTS-AGNOSTIC.md` (lines 370-494)
**Destination**: Maxwell `documents` + `patterns`

**Document**: "Dependency Injection Architecture & @DependencyClient"
- What is dependency injection
- Why modern Swift requires structured DI
- @DependencyClient macro usage
- DependencyClient vs Singleton decision logic
- Module structure recommendations
- Testing benefits

**Patterns**:
- @DependencyClient registration pattern
- Singleton usage pattern (when appropriate)
- Test override pattern

**Metadata**:
- Category: "Architecture"
- Subcategory: "Dependency Injection"
- Role: "guidance"
- Enforcement Level: "advisory"
- Tags: "@DependencyClient,dependency-injection,@Dependency,testing"

---

#### Category 5: TCA Pattern Recipes (Priority: Medium)

**Source**: `skill/SKILL.md` (code examples section)
**Destination**: Maxwell `patterns` table

**Recipes to Extract**:
1. Optional state with `.sheet` navigation
2. @Shared usage with multiple views
3. Testing TCA reducers with TestStore
4. Action error handling pattern
5. Reducer composition with @Reducer
6. Navigation scope state pattern

**Metadata**:
- Category: "TCA"
- Role: "guidance" (pattern examples)
- Enforcement Level: "example"
- Tags: "TCA,pattern-recipe,code-example,Swift Composable Architecture"

---

#### Category 6: Access Control Architecture (Priority: Low)

**Source**: `patterns/AGENTS-AGNOSTIC.md` (lines 708-862)
**Destination**: Maxwell `documents`

**Document**: "Access Control Architecture & Swift Module Boundaries"
- Module public API design
- Access control levels (public, package, internal, fileprivate, private)
- When to hide implementation
- Framework design principles

**Keep in Smith** (for validation):
- Access control violation detection
- Improper cascade of modifiers

**Metadata**:
- Category: "Architecture"
- Subcategory: "Module Design"
- Role: "guidance"
- Enforcement Level: "advisory"

---

### Content Staying in Smith

**Keep Only Validation/Enforcement**:
- ✅ Rule 1.1: Monolithic state detection (>15 properties)
- ✅ Rule 1.2: Direct dependency detection (Date(), UUID() calls)
- ✅ Rule 1.3: Code duplication detection
- ✅ Rule 1.4: Unclear organization detection
- ✅ Rule 1.5: Tightly coupled state detection
- ✅ Deprecated pattern detection (@State in reducers, WithViewStore, etc.)
- ✅ Build diagnostics (hangs, bottlenecks, type inference)
- ✅ How to fix violations (code examples for fixing)

---

## Phase 2: Standardize Knowledge Documents

### Document Structure for Maxwell

#### For `documents` table (Comprehensive guides):

```markdown
# Document Title

## Overview
What is this guide about? (1-2 sentences)

## When to Use
When should a developer read this?

## Key Concepts
- Concept 1: Brief explanation
- Concept 2: Brief explanation

## Implementation Guide
Step-by-step guidance with code examples

## Validation Checklist
- [ ] Item 1
- [ ] Item 2

## Common Mistakes
- Mistake 1: Why it's wrong
- Mistake 2: Why it's wrong

## Related Resources
- Links to related patterns
- Cross-references to other guides

## References
- External documentation
- Point-Free episodes
- WWDC sessions
```

**Database Fields**:
- `title`: Clear, searchable title
- `content`: Complete markdown document
- `category`: "Architecture", "Platform", "ConcurrencyPattern", "TCA"
- `subcategory`: More specific classification
- `role`: "guidance", "tutorial", "reference"
- `enforcement_level`: "example", "advisory", "recommended"
- `tags`: Comma-separated keywords for search

#### For `patterns` table (Decision frameworks & recipes):

```swift
INSERT INTO patterns (
    name,                  // "Decide: @DependencyClient vs Singleton"
    domain,               // "DependencyInjection"
    problem,              // "When should I use @DependencyClient vs a Singleton?"
    solution,             // Decision logic/framework
    code_example,         // Real working code
    notes,                // Additional context
    role,                 // "guidance"
    enforcement_level     // "advisory"
)
```

**Database Fields**:
- `name`: Pattern name
- `domain`: "TCA", "Architecture", "Concurrency", "DependencyInjection", "Platform"
- `problem`: What question does this answer?
- `solution`: The solution/recommendation
- `code_example`: Real, working code
- `notes`: Additional context/caveats
- `is_current`: Whether this pattern is current (1 = yes)
- `created_at`, `last_validated`: Timestamps

---

## Phase 3: Migration Strategy

### Step 1: Create Temporary Markdown Files

Location: `/tmp/smith-to-maxwell/` (temporary, will be deleted after migration)

**Structure**:
```
/tmp/smith-to-maxwell/
├── architectural-decisions/
│   ├── when-to-create-module.md
│   ├── dependency-client-vs-singleton.md
│   ├── when-to-refactor-to-module.md
│   ├── where-business-logic-lives.md
│   ├── build-bottleneck-analysis.md
│   ├── compile-time-optimization.md
│   └── type-inference-debugging.md
├── platform-guidance/
│   ├── ios-platform-patterns.md
│   ├── ipados-platform-patterns.md
│   ├── macos-platform-patterns.md
│   └── visionos-platform-patterns.md
├── concurrency-patterns/
│   ├── fire-and-forget-async.md
│   ├── taskgroup-with-timeout.md
│   ├── escaping-closures-safely.md
│   └── cached-only-pattern.md
├── dependency-injection/
│   ├── dependency-injection-architecture.md
│   └── dependency-client-patterns.md
├── tca-recipes/
│   ├── optional-sheet-navigation.md
│   ├── shared-state-multi-view.md
│   ├── testing-tca-reducers.md
│   ├── action-error-handling.md
│   ├── reducer-composition.md
│   └── navigation-scope-state.md
└── access-control/
    └── access-control-architecture.md
```

### Step 2: Create Swift Migration Script

**File**: `Maxwell/database/migrate-smith-patterns.swift`

The script will:
1. Read the temporary markdown files
2. Parse frontmatter for metadata (domain, role, enforcement_level, tags)
3. Insert into appropriate table (`documents` or `patterns`)
4. Validate insertion
5. Build FTS indexes

**Key improvements over current migration script**:
- Handle both `documents` and `patterns` tables
- Extract metadata from markdown frontmatter
- Support bulk insertion with transaction rollback on error
- Verify data integrity
- Report migration status

### Step 3: Update Maxwell Database

```bash
# Run migration script
swift Maxwell/database/migrate-smith-patterns.swift

# Verify insertion
sqlite3 Maxwell/database/maxwell.db "SELECT COUNT(*) FROM documents;"
sqlite3 Maxwell/database/maxwell.db "SELECT COUNT(*) FROM patterns;"

# Test searches
maxwell search "dependency injection"
maxwell search "monolithic" --domain TCA
```

### Step 4: Commit Updated Database

```bash
cd Maxwell
git add database/maxwell.db
git commit -m "Migrate architectural teaching content from Smith to Maxwell

- Add 7 architectural decision tree patterns
- Add 4 platform-specific guidance documents
- Add 4 concurrency patterns
- Add dependency injection guidance
- Add 6 TCA recipe patterns
- Establish Maxwell as authoritative source for architecture guidance"
```

---

## Phase 4: Update Maxwell Agent & Skills

### Update agent/maxwell.md

**Add routing section**:
```markdown
## When to Ask Maxwell vs Smith

### Use Maxwell for:
- "How should I structure my feature?"
- "What's the best way to use @Shared?"
- "Should I use @DependencyClient or Singleton?"
- "What are platform-specific patterns for visionOS?"
- "How do I optimize build performance?"
- "Show me TCA testing patterns"

### Use Smith (@smith) for:
- "Is my code correct?"
- "Does this violate TCA Rules 1-5?"
- "What's wrong with my build?"
- "Am I using deprecated patterns?"
- Architectural validation and enforcement
```

### Update skill descriptions

All Maxwell skills updated to note they access the shared knowledge database:
- skill-pointfree
- skill-shareplay
- skill-meta

---

## Phase 5: Clean Up Smith

### Update Smith/agent/smith.md

**Remove**:
- Sections describing TCA best practices (teaching)
- Platform-specific guidance
- Architectural decision trees
- Pattern examples (teaching)

**Keep**:
- Rule 1.1-1.5 enforcement descriptions
- How to fix violations
- Build diagnostics
- References to Maxwell for guidance

**Add**:
```markdown
## For Architectural Guidance

Smith is the **enforcer**—it tells you what's wrong.

For **how to write code correctly**, use:
- `@maxwell` - Complete architectural guidance
- `maxwell search "your question"` - Pattern lookup
- `smith-tools-skill.md` in your project - Project-specific setup

See: Maxwell documentation for comprehensive guidance.
```

---

## Phase 6: Update Documentation

### Create Smith/docs/ergonomics/AGENT-ROUTING.md

Guide users on when to use which agent:

```markdown
# Using Smith vs Maxwell: Which Agent When?

## Quick Decision Tree

Do you have code to validate?
├─ YES → Use @smith
│   └─ "Does this violate TCA Rules?"
│   └─ "Is this a deprecated pattern?"
│   └─ "Why is my build slow?"
│
└─ NO → Use @maxwell
    └─ "How should I structure this?"
    └─ "What's the best pattern?"
    └─ "Should I use @DependencyClient?"
```

---

## Database Impact Summary

### New Content in Maxwell

**documents table additions**:
- 4 Platform guidance documents
- 2 Dependency injection documents
- 1 Access control document
- 1 Concurrency patterns overview
- **Total: 8 new documents**

**patterns table additions**:
- 7 Architectural decision tree patterns
- 4 Concurrency patterns
- 6 TCA recipe patterns
- 3 Dependency injection decision patterns
- **Total: 20 new patterns**

**Total new searchable items**: 28

### Database Statistics After Migration

```
documents: 8 new entries
patterns: 20 new entries
Full-text search: Optimized for architectural queries
```

---

## Risk Mitigation

### What Could Go Wrong

1. **Duplicate content**: Some patterns might be referenced in multiple Smith files
   - **Mitigation**: Deduplicate before migration, create cross-references

2. **Lost context**: Some teaching relies on preceding sections
   - **Mitigation**: Include context in each document, add "Related" links

3. **Database corruption**: Migration script errors
   - **Mitigation**: Use transactions, validate after each insert, backup before

4. **Search quality degradation**: Patterns stored but not findable
   - **Mitigation**: Comprehensive tagging, test searches beforehand

### Verification Checklist

- [ ] All extracted content accounted for
- [ ] No duplicate patterns in database
- [ ] All searches work correctly
- [ ] Database integrity verified
- [ ] Smith skills still work (validation only)
- [ ] Maxwell agent enhanced with new routing
- [ ] Documentation updated
- [ ] No broken cross-references

---

## Success Criteria

✅ **Smith remains lean**: Only validation/enforcement (no teaching)
✅ **Maxwell is comprehensive**: All architectural guidance accessible
✅ **Clear separation**: Users understand when to use each
✅ **Searchable**: All patterns findable via `maxwell search`
✅ **Version controlled**: Database committed with good metadata
✅ **No data loss**: All teaching content preserved
✅ **Improved boundaries**: Smith and Maxwell responsibilities crystal clear

---

## Next Steps

1. Extract content from Smith (create temporary markdown files)
2. Create/improve migration script
3. Run migration and verify
4. Update Smith to reference Maxwell
5. Update Maxwell documentation
6. Commit changes
7. Test in real projects

