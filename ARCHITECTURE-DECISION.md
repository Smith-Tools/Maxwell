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

### 3. Unified Multi-Skill + Agent Architecture (CHOSEN)
**Proposal**: Auto-triggered skills for fast answers, single Maxwell agent for complex analysis

```
Developer Question
        ↓
Route by keywords (auto-triggered)
        ↓
Simple pattern lookup?
  ✅ → skill-pointfree/shareplay/meta answers (2 seconds)
       - Calls: maxwell search "query"
       - Returns relevant patterns from database
  ❌ → Complex multi-domain question?
       → Maxwell agent (`@maxwell`) analyzes (30 seconds)
       - Reads code files
       - Queries maxwell database
       - Synthesizes cross-domain solutions
```

**Pros:**
- Fast auto-triggered responses for simple questions (2 seconds)
- One comprehensive agent for complex questions
- Real CLI binary backend (not fake infrastructure)
- Type-safe database queries (SQLite.swift)
- Markdown-first content (version controlled)
- Zero unsafe code, clear separation of concerns

**Cons:**
- Requires explicit `@maxwell` invocation for complex questions
- Single agent can't specialize like separate subagents could

**Decision**: Approved and implemented.

---

## The Implementation

### 1. Auto-Triggered Skills Layer

Three specialized skills trigger automatically on keywords:

**skill-pointfree** (TCA authority):
- Triggers on: `@Shared`, `@Bindable`, `Reducer`, `TestStore`, `TCA`
- Accesses: `maxwell search "@Shared" --domain TCA`
- Returns: TCA patterns and best practices in ~2 seconds

**skill-shareplay** (SharePlay expert):
- Triggers on: `SharePlay`, `GroupActivities`, `collaborative`
- Accesses: `maxwell search "GroupActivities"`
- Returns: SharePlay implementation patterns in ~2 seconds

**skill-meta** (Maxwell's self-knowledge):
- Triggers on: `Maxwell`, `architecture`, `patterns`, `skills`
- Provides: Maxwell system documentation
- Returns: Architecture guidance in ~2 seconds

### 2. Maxwell Agent Layer

**Unified Maxwell Agent** (`@maxwell` explicit invocation):
- Comprehensive multi-domain expertise
- Can read project code and files
- Queries maxwell database via CLI
- Synthesizes complex cross-domain solutions
- Orchestrates insight from all domains

### 3. Real CLI Binary Backend

**maxwell command-line tool**:
- Built with Swift ArgumentParser
- Provides 5 subcommands:
  - `maxwell search "query" [--domain] [--limit]` - Full-text search
  - `maxwell pattern "name"` - Find by name
  - `maxwell domain TCA|SharePlay` - List domain patterns
  - `maxwell init` - Initialize database
  - `maxwell migrate /path` - Migrate markdown files
- Binary path: `~/.local/bin/maxwell`
- Location: `database/Sources/MaxwellCLI/main.swift`

### 4. SQLite Database

**Type-Safe Database Layer**:
- Uses SQLite.swift library (compile-time checked queries)
- Zero unsafe code
- Proper null handling for optional fields
- Two tables:
  - `documents` (70 markdown files, 153 total with metadata)
  - `patterns` (prepared for structured pattern data)
- Location: `~/.claude/resources/databases/maxwell.db`

### 5. Markdown-First Content

**Version-Controlled Content**:
- All patterns stored as markdown in skill directories
- Migration process extracts metadata and populates database
- Content is human-maintained, not auto-generated
- Easy to review changes in git

---

## Relationship to Smith

**Smith** (validation tool):
- Purpose: Is this code architecturally correct?
- What it checks: TCA patterns, reducer composition, testability, access control
- When it runs: After implementation, as a quality gate
- Example: Smith detects @Shared race conditions

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
- Infrastructure: SQLite + FTS5 with sosumi coordination

**Maxwell subagents coordinate with sosumi** like any expert agent - calling sosumi when Apple documentation is needed to supplement framework expertise.

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

