# Maxwell Architecture Decision Record

**Date**: November 22, 2025
**Status**: Approved
**Decision**: Maintain Maxwell as a separate knowledge and expertise system parallel to Smith validation framework

---

## The Core Insight

**Maxwell's value is the knowledge content, not the architecture.** The 90+ markdown files of patterns, examples, guides, and cross-domain integrations are the asset. The "Maxwell" wrapper is organizational scaffolding that keeps the knowledge accessible and maintainable.

---

## Context: The Problem Being Solved

### Knowledge Silos
- TCA skill has patterns that smith lacks
- SharePlay skill has integration patterns that TCA doesn't address
- RealityKit patterns exist nowhere systematically
- No way to discover cross-domain relationships (TCA + SharePlay + RealityKit integration)

### Project Complexity Reality
Modern Apple development projects are fundamentally **multi-framework**:

```
Contemporary Apple App Structure:
├── macOS (AppKit + SwiftUI)
├── visionOS (RealityKit + ImmersiveSpace)
├── iOS Companion (SwiftUI)
├── Shared Framework (TCA state management)
├── SharePlay Collaboration (GroupActivities)
├── RealityKit 3D (entities + components)
├── TabletopKit Integration
├── CloudKit Sync
└── Core Data / SwiftData persistence
```

A developer with this architecture doesn't ask:
- "How do I use TCA?" (single domain)
- "How do I implement SharePlay?" (single domain)

They ask:
- **"How do I sync RealityKit entities across a TCA-managed SharePlay session?"** (cross-domain)
- **"How do I handle CloudKit conflicts with @Shared state?"** (cross-domain)
- **"Should this be @Shared or passed through SharePlay messenger?"** (architectural decision across domains)

The current siloed approach **cannot answer these questions**.

---

## Alternatives Considered

### 1. Merge Maxwell into Smith
**Proposal**: Extend smith-cli and smith-skill to include pattern expertise and cross-domain knowledge

**Pros:**
- Single CLI tool ecosystem
- Validation + patterns in one place
- No naming confusion

**Cons:**
- Smith's purpose is **validation** (is this code correct?)
- Maxwell's purpose is **expertise** (how should I write this?)
- Different concerns, different workflows
- Smith is already mature; adding framework expertise dilutes its focus
- Validation rules ≠ Pattern guidance

**Decision**: Rejected. Smith remains focused on validation.

---

### 2. Single Unified Subagent (Maxwell Consolidated)
**Proposal**: Consolidate all framework knowledge into one maxwell-unified subagent

**Pros:**
- Single entry point for all complex questions
- Comprehensive knowledge in one agent

**Cons:**
- Loses auto-triggering on keywords (@Shared, SharePlay, etc.)
- 90+ doc knowledge base in one agent is harder to search
- No flexibility for simple questions that don't need complexity
- All invocations require explicit Task tool call (slower UX)

**Decision**: Rejected in favor of hybrid.

---

### 3. Parallel Architecture (CHOSEN)
**Proposal**: Keep skills (auto-triggered) and subagent (explicit) both querying unified knowledge layer

```
┌─────────────────────────────────────────┐
│         Unified Knowledge Layer         │
│  (SQLite + FTS5 - extends sosumi)       │
│                                         │
│  Tables:                                │
│  - patterns (domain-specific)           │
│  - integrations (cross-domain bridges)  │
│  - anti_patterns (symptom → fix)        │
│  - discoveries (real bugs + solutions)  │
└─────────────────────────────────────────┘
         ↑              ↑
    Skills (auto)    Subagent (explicit)
    - TCA skill      - maxwell-unified
    - SharePlay      - can read code files
    - RealityKit     - orchestrates skills
    (single-domain)  (cross-domain)
    (fast)           (comprehensive)
```

**Pros:**
- Keeps auto-triggering for quick questions (80% of queries)
- Enables cross-domain for complex problems (20% of queries)
- Single knowledge source: no duplication
- Flexible: scales to new domains
- Proven pattern: extends sosumi's successful SQLite+FTS5 approach

**Cons:**
- Two entry points (skill vs. subagent)
- Requires clear routing logic

**Decision**: Approved.

---

## The Architecture

### 1. Knowledge Layer: Unified SQLite Database

**Pattern**: Extends sosumi's proven SQLite + FTS5 infrastructure

**Schema**:
```sql
-- Domain-specific patterns
CREATE TABLE patterns (
    id INTEGER PRIMARY KEY,
    domain TEXT,              -- 'TCA', 'SharePlay', 'RealityKit'
    pattern_name TEXT,
    problem TEXT,             -- What problem does this solve?
    solution TEXT,            -- How to solve it
    code_example TEXT,        -- Swift code
    references TEXT,          -- Links to source material
    validation_checklist TEXT,
    UNIQUE(domain, pattern_name)
);

-- Cross-domain integration patterns (CRITICAL)
CREATE TABLE integrations (
    id INTEGER PRIMARY KEY,
    domain_a TEXT,            -- 'TCA'
    domain_b TEXT,            -- 'SharePlay'
    integration_pattern TEXT, -- 'TCA-SharePlay State Bridge'
    problem TEXT,
    solution TEXT,
    code_example TEXT,
    tradeoffs TEXT,           -- Why this approach vs alternatives
    UNIQUE(domain_a, domain_b, integration_pattern)
);

-- Anti-patterns and debugging
CREATE TABLE anti_patterns (
    id INTEGER PRIMARY KEY,
    domain TEXT,
    symptom TEXT,             -- What the developer sees
    root_cause TEXT,          -- Why it happens
    fix TEXT,                 -- How to fix it
    discovery_source TEXT,    -- Where we learned this
    example_code TEXT
);

-- Real-world discoveries and bug fixes
CREATE TABLE discoveries (
    id INTEGER PRIMARY KEY,
    title TEXT,
    domains TEXT,             -- JSON array: ['TCA', 'SharePlay']
    symptom TEXT,
    investigation TEXT,
    solution TEXT,
    code_fix TEXT,
    validation_status TEXT,
    discovered_date TEXT
);

-- Full-text search index (extends sosumi pattern)
CREATE VIRTUAL TABLE maxwell_search USING fts5(
    pattern_name, problem, solution, code_example,
    domain, integration_pattern, content=patterns, content_rowid=id
);
```

### 2. Skills Layer: Auto-Triggered Knowledge Access

Each domain has a skill that:
- Triggers automatically on keywords (@Shared, SharePlay, etc.)
- Queries the unified DB for single-domain patterns
- Returns fast, focused answers
- Detects cross-domain problems and recommends subagent escalation

**Current Skills**:
- `maxwell-tca` - TCA patterns and anti-patterns
- `maxwell-shareplay` - SharePlay GroupActivities patterns
- (Future) `maxwell-realitykit` - RealityKit and spatial computing
- (Future) `maxwell-swiftui` - SwiftUI and platform-specific patterns

### 3. Subagent Layer: Cross-Domain Problem Solving

**maxwell-unified** subagent:
- Explicit invocation (via Task tool)
- Can read actual project code
- Queries integration patterns in DB
- Orchestrates multiple skills as needed
- Provides architectural guidance across domains

---

## Relationship to Smith

**Smith** (validation tool):
- Purpose: Is this code architecturally correct?
- What it checks: Reducer composition, testability, access control, concurrency safety
- When it runs: After implementation, as a quality gate

**Maxwell** (expertise tool):
- Purpose: How should I implement this cross-domain feature?
- What it provides: Patterns, examples, integration guidance, anti-patterns
- When it's used: Before and during implementation

**They are complementary, not overlapping.**

---

## Relationship to sosumi

**sosumi** (Apple documentation search):
- Purpose: What does the official Apple documentation say?
- Knowledge source: Official Apple docs, WWDC sessions
- Infrastructure: SQLite + FTS5

**Maxwell** (framework expertise):
- Purpose: How do I combine these frameworks in production?
- Knowledge source: Patterns, integrations, real-world discoveries
- Infrastructure: Extends sosumi's SQLite + FTS5

**Maxwell uses sosumi's infrastructure as a foundation** and extends it with cross-domain search capabilities.

---

## Why Keep Maxwell Separate

### Knowledge Content vs. Architecture
The value of Maxwell is not in its technical architecture (which is straightforward: SQLite + FTS5), but in its **knowledge content**:

1. **90+ markdown files** capturing framework expertise
2. **Integration patterns** connecting TCA, SharePlay, RealityKit, CloudKit
3. **Real-world discoveries** from production app analysis
4. **Anti-patterns** with root causes and fixes
5. **Validation checklists** ensuring production quality

This knowledge exists *because* it solves a real problem: developers building complex multi-framework Apple apps.

### Separation of Concerns
- **Smith**: Architecture validation (structural correctness)
- **Maxwell**: Framework expertise (pattern correctness)
- **sosumi**: Official documentation (API correctness)

Each tool has a clear purpose and owns its domain.

### Maintainability
A developer (human or AI) working on Maxwell knows exactly what they're doing:
- Adding a new TCA pattern? → Add to patterns table + create guide
- Discovering cross-domain integration? → Add to integrations table
- Found a bug with root cause? → Add to discoveries table

No confusion with validation rules or documentation searches.

---

## Implementation Roadmap

### Phase 1: Foundation (Current)
- [ ] Design unified SQLite schema
- [ ] Migrate existing 90 MD files to schema
- [ ] Build FTS5 search indices
- [ ] Create schema validation scripts

### Phase 2: Skills Layer
- [ ] Update maxwell-tca skill to query unified DB
- [ ] Update maxwell-shareplay skill to query unified DB
- [ ] Add cross-domain detection (escalate to subagent)
- [ ] Test skill queries and performance

### Phase 3: Subagent Layer
- [ ] Implement maxwell-unified subagent
- [ ] Integration pattern queries
- [ ] Code file analysis
- [ ] Skill orchestration

### Phase 4: Integration Patterns
- [ ] TCA + SharePlay integration patterns
- [ ] RealityKit + TCA synchronization
- [ ] CloudKit + @Shared state conflict resolution
- [ ] Production-ready examples for each

### Phase 5: Continuous Learning
- [ ] Document new patterns as discovered
- [ ] Expand anti-patterns with real bugs
- [ ] Add discovery records from real projects

---

## For Future Developers (Human or AI)

### When You Encounter Maxwell

**This system exists because:**
- Single-domain expertise isn't sufficient for modern Apple development
- Cross-domain patterns need to be discoverable
- Real bugs and their root causes are valuable knowledge
- Pattern guidance (Maxwell) is different from validation (Smith)

### How to Extend Maxwell

1. **New pattern discovered?** Add to `integrations` table if cross-domain, `patterns` if single-domain
2. **Found a bug?** Add to `discoveries` table with root cause and solution
3. **Anti-pattern identified?** Add to `anti_patterns` table with example code
4. **New domain?** Create new skill following the pattern of maxwell-tca and maxwell-shareplay

### How NOT to Extend Maxwell

- Don't add validation rules (that's Smith's job)
- Don't add Apple API documentation (that's sosumi's job)
- Don't duplicate knowledge across tables (single source of truth)

---

## Questions This Architecture Answers

### "How do I sync RealityKit entities in a TCA-managed SharePlay session?"
→ Query integrations table: `WHERE domain_a='TCA' AND domain_b='SharePlay'`
→ Find "TCA-SharePlay State Bridge" pattern
→ Read solution with code example

### "My @Shared state keeps getting out of sync when SharePlay sends updates"
→ Query anti_patterns: `WHERE domain='TCA' AND domain='SharePlay' AND symptom='state out of sync'`
→ Find root cause and fix

### "Should I use @Shared or pass through GroupSessionMessenger?"
→ Invoke maxwell-unified subagent with code context
→ Get architectural decision with tradeoffs from integrations table

### "How do I test TCA + SharePlay interactions?"
→ Search integrations for "TCA-SharePlay" patterns with code examples
→ Find testing patterns and validation checklist

---

## Success Criteria

Maxwell succeeds when:
1. ✅ Single-domain questions can be answered by auto-triggered skills (< 5 sec)
2. ✅ Cross-domain questions can be answered by subagent with code analysis (< 30 sec)
3. ✅ New patterns can be added without modifying code
4. ✅ Real bugs and root causes are documented
5. ✅ Developers build correct multi-framework apps on first try

---

**This architecture decision was made with full understanding of the alternatives. Maxwell exists to solve a real problem: helping developers and AI agents navigate the complexity of modern, multi-framework Apple development.**

---

**Related Documents:**
- `README.md` - Maxwell overview
- `TCA/README.md` - TCA module specifics
- `SharePlay/README.md` - SharePlay module specifics
- Smith documentation (separate repo) - Validation framework
- sosumi documentation - Apple documentation search

