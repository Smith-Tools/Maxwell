# Skill Maxwell - Cross-Domain Contradiction Detection

## Purpose

**Lightweight cross-domain contradiction detection** that any domain skill can call when adding new patterns.

## When Skills Call This

Use this skill when:
- skill-tca adds new TCA patterns
- skill-shareplay adds new SharePlay patterns
- skill-visionos adds new VisionOS patterns
- Any skill wants to validate pattern consistency

## Cross-Domain Detection Logic

### 1. Domain Mapping
```markdown
domains = {
    "TCA": ["@Shared", "State", "Navigation", "Dependencies"],
    "SharePlay": ["GroupSession", "Coordination", "Synchronization"],
    "VisionOS": ["Spatial", "RealityKit", "ImmersiveSpace"]
}
```

### 2. Contradiction Keywords (Domain-Aware)
```markdown
contradictoryPairs = [
    ("single", "multiple"),
    ("only", "both"),
    ("owner", "shared"),
    ("exclusive", "collaborative"),
    ("centralized", "distributed"),
    ("synchronous", "asynchronous")
]
```

### 3. Cross-Domain Impact Analysis
- **High Impact**: State management contradictions (TCA vs SharePlay)
- **Medium Impact**: User experience contradictions (VisionOS vs TCA)
- **Low Impact**: Implementation-specific contradictions

## Usage Pattern

### Domain Skill Integration
```markdown
# When skill-tca wants to add a pattern:
1. Call skill-maxwell:contradiction-detection
2. Pass new pattern details
3. Get contradiction report
4. If clear: proceed with insertion
5. If contradictions: show decision point
```

### Simple API
```markdown
Input: {
    "name": "@Shared Single Owner",
    "domain": "TCA",
    "recommendation": "Single writer, multiple readers",
    "source": "Smith CLAUDE.md",
    "credibility": 3
}

Output: {
    "hasContradictions": true,
    "severity": "critical",
    "conflictingPatterns": [...],
    "recommendation": "synthesize_approach"
}
```

## Benefits

### ✅ **Lightweight**
- Single skill handles all contradiction detection
- Domain skills stay focused on expertise
- No duplication of detection logic

### ✅ **Cross-Domain Awareness**
- Detects contradictions across TCA/SharePlay/VisionOS
- Understands domain-specific terminology
- Maintains domain expert boundaries

### ✅ **Scalable**
- New domains automatically get contradiction detection
- Easy to add new detection rules
- Centralized maintenance

---

**This keeps Maxwell modular while providing unified contradiction detection across all domain expert systems!**