# Pattern Contradiction Detection - Skill Logic Implementation

## Skill Function: `detectPatternContradictions`

This function uses AI pattern recognition to detect contradictions in TCA patterns before they're added to Maxwell's database.

### Input Parameters
- `newPattern`: Object containing pattern details (name, domain, recommendation, source, credibility)
- `databaseAccess`: Function to query existing patterns from SQLite database

### Output
- Decision point object with contradictions found and recommended resolution

## AI Pattern Recognition Logic

### 1. Keyword-Based Contradiction Detection
```
contradictoryPairs = [
    ("single", "multiple"),
    ("only", "both"),
    ("owner", "shared"),
    ("writer", "readers"),
    ("one", "many"),
    ("exclusive", "shared"),
    ("restricted", "allowed")
]
```

### 2. Domain-Specific Severity Rules
- **TCA @Shared patterns**: Always critical if contradictory
- **Navigation patterns**: Critical if lifecycle conflicts
- **Testing patterns**: Warning if different approaches
- **Dependency patterns**: Info if alternative methods

### 3. Credibility-Based Resolution
```
sourceAuthority = {
    "TCA DocC": 5,           // canonical
    "Point-Free": 4,         // expert
    "Smith Analysis": 3,     // derived
    "Community": 2           // opinion
}
```

## Implementation Steps

### Step 1: Query Existing Patterns
```sql
SELECT id, name, recommendation, source, credibility
FROM patterns
WHERE domain = 'TCA'
AND recommendation LIKE '%@Shared%'
```

### Step 2: Analyze for Contradictions
For each existing pattern in the same domain:
1. Check for contradictory keywords in recommendations
2. Compare pattern names for opposing concepts
3. Evaluate source credibility
4. Determine severity based on domain

### Step 3: Generate Decision Points
If contradictions found:
1. Calculate severity (critical/warning/info)
2. Determine resolution strategy
3. Present options to user with recommendations
4. Require human decision for critical contradictions

## Example Usage

### Scenario: Adding @Shared Pattern
**New Pattern**: "@Shared Single Owner Pattern"
**Existing Pattern**: "@Shared Multiple Writers Pattern"

**Detection Process**:
1. ✅ Found contradictory keywords: "single" vs "multiple"
2. ✅ Domain: TCA (critical severity)
3. ✅ Both have derived credibility (3/5 each)
4. ✅ Generate decision point

**Output Decision Point**:
```
🚨 CRITICAL CONTRADICTION DETECTED

Conflict: "@Shared Single Owner" vs "@Shared Multiple Writers"

Option 1: Follow "@Shared Single Owner" (Smith CLAUDE.md, 3/5)
Recommendation: Single writer, multiple readers
Consequences: Stricter discipline, easier reasoning

Option 2: Follow "@Shared Multiple Writers" (TCA-SHARED-STATE.md, 3/5)
Recommendation: Both features can read/write
Consequences: More flexibility, potential race conditions

RECOMMENDATION: Synthesize both approaches with clear discipline guidelines
```

## Integration with Existing Skills

### Before Pattern Insertion
```markdown
1. Call detectPatternContradictions()
2. If no contradictions: proceed with insertion
3. If minor contradictions: log warning, insert anyway
4. If critical contradictions: halt, show decision point
```

### Database Interaction
- Query existing patterns via simple-database skill
- Store contradiction decisions for future reference
- Update pattern credibility based on human decisions

## Advanced Pattern Recognition

### Semantic Analysis (Future Enhancement)
- Use AI to understand pattern semantics beyond keywords
- Recognize conceptually similar but differently worded patterns
- Detect implied contradictions (not just keyword-based)

### Learning System (Future Enhancement)
- Record human contradiction resolutions
- Build pattern of preferred sources and approaches
- Improve contradiction detection accuracy over time

## Error Handling

### No Database Access
- Use existing skill patterns as fallback
- Check skill content for contradictions
- Proceed with warnings if access unavailable

### Ambiguous Contradictions
- When contradiction detection is uncertain, assume warning severity
- Request human clarification for edge cases
- Document ambiguous cases for future reference

## Performance Considerations

### Pattern Matching Optimization
- Focus on patterns in same domain
- Limit keyword search to pattern recommendations
- Cache existing patterns for faster repeated checks

### Scalability
- As pattern database grows, implement domain-specific indexes
- Consider pattern clustering to reduce comparison scope
- Use efficient SQL queries for large datasets

---

This skill-level implementation provides Maxwell with intelligent contradiction detection using AI pattern recognition, ensuring pattern consistency without requiring compiled code or external tools.