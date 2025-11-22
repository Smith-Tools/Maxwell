# Pattern Contradiction Detection (Skill-Level Logic)

## Overview

This skill implements contradiction detection using AI pattern recognition to identify conflicting patterns before they're added to Maxwell's knowledge base.

## When to Use

Use this skill whenever:
- Adding new TCA patterns to the database
- Updating existing patterns
- Validating pattern consistency
- Reviewing pattern recommendations

## Detection Process

### Step 1: Pattern Analysis
When a new pattern is proposed, analyze:

```markdown
1. **Pattern Name**: "@Shared Single Owner"
2. **Domain**: "TCA"
3. **Recommendation**: "Single writer, multiple readers - Only one feature should own and mutate @Shared state"
4. **Source**: "Smith CLAUDE.md"
5. **Credibility**: 3/5
```

### Step 2: Contradiction Keyword Detection
Look for opposing keyword pairs:

| Keyword | Opposing Keyword | Example |
|---------|-----------------|---------|
| single | multiple | "single writer" vs "multiple writers" |
| only | both | "only one feature" vs "both features" |
| owner | shared | "single owner" vs "shared access" |
| writer | readers | "writers allowed" vs "readers only" |
| one | many | "one feature should" vs "many features can" |

### Step 3: Domain-Specific Rules
TCA contradictions are inherently **critical**:

- **@Shared state patterns**: Always critical if contradictory
- **Navigation patterns**: Critical if lifecycle conflicts
- **Testing patterns**: Warning if approach differs
- **Dependency patterns**: Info if alternative injection methods

### Step 4: Credibility Ranking
Source authority hierarchy:
1. **canonical** (5/5): TCA DocC, official docs
2. **expert** (4/5): Point-Free (TCA creators)
3. **derived** (3/5): Analysis based on canonical
4. **opinion** (2/5): Community practices

## Decision Point Generation

When contradictions are detected:

### Critical Contradiction Response
```markdown
🚨 **PATTERN CONTRADICTION DETECTED**

**Conflict**: "@Shared Multiple Writers" vs "@Shared Single Owner"

**Option 1**: Follow "TCA-SHARED-STATE.md" (Credibility: 3/5)
> "Both features can read/write without explicit dependency chain"
> **Consequences**: More flexibility, potential race conditions

**Option 2**: Follow "Smith CLAUDE.md" (Credibility: 3/5)
> "Single writer, multiple readers - Only one feature should own and mutate @Shared state"
> **Consequences**: Stricter discipline, easier to reason about

**Recommendation**: Follow highest credibility source, or synthesize both approaches
```

### Resolution Strategies
- **followHighestCredibility**: Choose highest-ranked source
- **synthesizeApproach**: Combine both approaches safely
- **requireHumanDecision**: Ask user to choose (for critical contradictions)

## Implementation Logic

### Skill Function: `detectPatternContradiction`

```markdown
Function: detectPatternContradiction(newPattern, existingPatterns)

Input:
- newPattern: {name, domain, recommendation, source, credibility}
- existingPatterns: [Pattern] from database

Process:
1. For each existingPattern in same domain:
   a. Check for contradictory keywords
   b. Calculate severity based on domain and credibility
   c. If contradiction found, generate decision point

2. Return:
   - hasContradictions: boolean
   - contradictions: [Contradiction]
   - recommendation: ResolutionStrategy
```

### Contradiction Detection Algorithm

```markdown
function areContradictory(rec1, rec2):
  contradictoryPairs = [
    ("single", "multiple"),
    ("only", "both"),
    ("owner", "shared"),
    ("writer", "readers"),
    ("one", "many")
  ]

  for (word1, word2) in contradictoryPairs:
    if rec1.lower().contains(word1) and rec2.lower().contains(word2):
      return true
    if rec1.lower().contains(word2) and rec2.lower().contains(word1):
      return true

  return false
```

### Severity Calculation

```markdown
function calculateSeverity(patterns):
  # TCA domain contradictions are always critical
  if any(pattern.name.contains("@Shared") or pattern.name.contains("TCA") for pattern in patterns):
    return "critical"

  # High-credibility conflicts are critical
  highCredibilityCount = count(pattern.credibility >= 4 for pattern in patterns)
  if highCredibilityCount >= 2:
    return "critical"
  elif highCredibilityCount == 1:
    return "warning"
  else:
    return "info"
```

## Database Integration

### Query Existing Patterns
```sql
-- Get patterns that might contradict new pattern
SELECT name, recommendation, source, credibility
FROM patterns
WHERE domain = ?
AND (
  recommendation LIKE '%single%'
  OR recommendation LIKE '%multiple%'
  OR recommendation LIKE '%only%'
  OR recommendation LIKE '%both%'
  OR recommendation LIKE '%owner%'
  OR recommendation LIKE '%shared%'
);
```

### Store Contradiction Decisions
```sql
CREATE TABLE contradiction_resolutions (
  id INTEGER PRIMARY KEY,
  pattern_a_id INTEGER,
  pattern_b_id INTEGER,
  resolution_strategy TEXT,
  chosen_pattern_id INTEGER,
  decision_date TEXT,
  notes TEXT
);
```

## Usage Examples

### Example 1: @Shared State Contradiction
**Input**: New pattern suggests "@Shared Single Owner"
**Existing**: Pattern allows "@Shared Multiple Writers"
**Output**: Critical contradiction with decision point

### Example 2: Navigation Pattern Update
**Input**: New navigation pattern uses sheet-based presentation
**Existing**: Pattern uses full-screen presentation
**Output**: Warning - different approaches, both valid

### Example 3: Testing Method
**Input**: New test uses TestStore
**Existing**: Pattern uses XCTest
**Output**: Info - alternative testing approaches

## Integration with Existing Skills

This contradiction detection skill integrates with:

- **skill-tca**: Primary domain for TCA patterns
- **simple-database**: Query existing patterns for comparison
- **pattern-insertion**: Validate before adding new patterns

## Error Handling

- **No contradictions**: Proceed with pattern insertion
- **Minor contradictions**: Log warning, allow insertion
- **Critical contradictions**: Halt insertion, require decision

## Future Enhancements

- **Semantic analysis**: Use AI to understand pattern semantics, not just keywords
- **Pattern clustering**: Group similar patterns to detect broader contradictions
- **Learning system**: Record human decisions to improve future detection
- **Cross-domain contradictions**: Detect conflicts between TCA and SharePlay patterns

---

**Last Updated**: 2025-01-22
**Skill Type**: Pattern Validation
**Dependencies**: simple-database, pattern-insertion