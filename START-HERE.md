# Maxwell: Start Here

You've just encountered Maxwell. Here's what it is and where to start.

---

## 30-Second Summary

**Maxwell** is a production-ready multi-skill specialist system that helps developers build complex, multi-framework Apple apps.

It provides:
1. **Auto-triggered skills** that answer single-domain questions fast (TCA? SharePlay?)
2. **A unified knowledge layer** (SQLite database with 150+ documents)
3. **A Maxwell orchestrator agent** for complex multi-domain questions

**Key insight**: Maxwell uses a real Swift CLI binary backed by SQLite. Skills call `maxwell search` to access patterns.

---

## Quick Start

### Installation

```bash
cd /Volumes/Plutonian/_Developer/Smith\ Tools/Maxwell
./install.sh
```

This builds the maxwell binary, initializes the database, and deploys skills.

### Testing

```bash
# Verify binary works
maxwell search "TCA @Shared"

# Ask Maxwell a question in Claude
# Keywords will auto-trigger appropriate skills
```

---

## Who Are You?

### "I'm building an Apple app and have a quick question"

→ **Just ask**: Keywords will auto-trigger the right skill

Examples:
- "How do I use @Shared in TCA?" → skill-pointfree auto-triggers
- "How do I implement SharePlay?" → skill-shareplay auto-triggers
- "What's the difference between @Shared patterns?" → skill-pointfree with database query

**Speed**: ~2 seconds for auto-triggered skill response

### "I have complex code that needs review or optimization"

→ **Use Maxwell agent**: `@maxwell`

Examples:
- "Review this TCA reducer for performance"
- "How do I integrate this TCA state with SharePlay?"
- "What patterns should I apply here?"

**Speed**: ~30 seconds for comprehensive analysis

### "I'm trying to understand Maxwell's architecture"

→ **Read [`ARCHITECTURE-DECISION.md`](ARCHITECTURE-DECISION.md)**

This explains:
- Why Maxwell exists
- The 4-tier architecture (Entry Points → Skills → CLI → Database)
- How skills and agent coordinate
- Design principles and trade-offs

**Time**: 10 minutes to fully understand

### "I want to add patterns or extend Maxwell"

→ **Read [`KNOWLEDGE-MAINTENANCE.md`](KNOWLEDGE-MAINTENANCE.md)**

This explains:
- How to add new markdown files to skill directories
- How to run `maxwell migrate` to populate database
- How the CLI binary works
- Extending with new skills

**Time**: 15 minutes to understand the workflow

### "I'm an AI agent working on Maxwell"

→ **Read this document, then [`ARCHITECTURE-DECISION.md`](ARCHITECTURE-DECISION.md)**

Then:
1. Understand what Maxwell solves (cross-domain knowledge)
2. Know when to use skills (single-domain, fast) vs. subagent (cross-domain, comprehensive)
3. When adding new knowledge: follow [`KNOWLEDGE-MAINTENANCE.md`](KNOWLEDGE-MAINTENANCE.md) structure

---

## The Maxwell Documents

Three key documents explain everything:

### 1. `ARCHITECTURE-DECISION.md` (Read First)

**What it answers:**
- Why does Maxwell exist?
- Why not merge it into Smith?
- What's the "knowledge layer"?
- Why parallel skills + subagent?

**Who needs it:**
- Anyone wondering about Maxwell's design
- Decision makers
- Architects
- AI agents planning implementation

**Length**: ~15 min read

**Key section**: "Why Keep Maxwell Separate" - explains the core insight about content vs. architecture

---

### 2. `KNOWLEDGE-MAINTENANCE.md` (Read When Extending)

**What it answers:**
- What goes in the `patterns` table?
- What goes in the `integrations` table?
- What goes in `anti_patterns`?
- What goes in `discoveries`?
- How do I search the knowledge layer?
- How do I maintain it?

**Who needs it:**
- Developers/agents adding patterns
- Maintaining existing content
- Understanding what knowledge exists

**Length**: ~20 min read

**Key sections**:
- "Quick Reference: What Goes Where?"
- "Adding a Pattern/Integration/Anti-Pattern/Discovery" (with examples)
- "Review Checklist"

---

### 3. `README.md` (Project Overview)

**What it answers:**
- What's Maxwell at a glance?
- What modules exist? (TCA, SharePlay, etc.)
- How do I use Maxwell?
- What's the development status?

**Who needs it:**
- First-time visitors
- Understanding what's available now
- Quick reference

**Length**: ~5 min read

---

## The Decision Tree

Use this to know what to read:

```
Are you using Maxwell?
  │
  ├─ No, I'm asking a question
  │   └─ Just describe your problem
  │      (Skills auto-trigger on keywords)
  │
  └─ Yes, I'm working on Maxwell
      │
      ├─ Understanding design
      │   └─ Read ARCHITECTURE-DECISION.md
      │
      ├─ Adding patterns/integrations
      │   └─ Read KNOWLEDGE-MAINTENANCE.md
      │
      └─ Quick overview
          └─ Read README.md
```

---

## Key Concepts (2 Minutes)

### The Problem Maxwell Solves

Modern Apple apps aren't "just TCA" or "just SharePlay". They're:

```
TCA (state) + SharePlay (sync) + RealityKit (3D) + CloudKit (persistence) + ...
```

Developers ask cross-domain questions:
- "How do I sync @Shared state via SharePlay messenger?"
- "Should this use @Shared or pass through GroupSessionMessenger?"
- "How do I handle CloudKit conflicts with TCA state?"

These questions need to **connect multiple frameworks**. Siloed skills can't answer them.

### The Solution: Unified Knowledge Layer

Instead of isolated markdown files:
```
maxwell-tca/skill/  ← TCA patterns (silos)
maxwell-shareplay/skill/  ← SharePlay patterns (silos)
```

Maxwell uses a shared SQLite database:
```
patterns table → TCA patterns + SharePlay patterns + RealityKit patterns
integrations table → TCA+SharePlay bridges, RealityKit+TCA bridges, etc.
anti_patterns table → Bugs that span domains
discoveries table → Real production issues and fixes
```

### How You Interact With It

**For simple questions** (single domain):
```
Q: "How do I use @Shared in TCA?"
→ maxwell-tca skill queries patterns table
→ Returns TCA pattern instantly
```

**For complex questions** (cross-domain):
```
Q: "How do I sync RealityKit entities via TCA+SharePlay?"
→ maxwell-unified subagent queries integrations table
→ Reads your actual code files
→ Provides complete cross-domain solution
```

---

## What's in Maxwell Right Now

### Completed Modules
- ✅ **TCA Module**: 15+ patterns, testing guidance, decision trees
- ✅ **SharePlay Module**: 50+ patterns, real-world examples, HIG integration

### Planned
- 🔄 **RealityKit Module**: Spatial patterns, entity management
- 🔄 **Swift Module**: Language-level patterns, concurrency
- 🔄 **SwiftUI Module**: Platform-specific SwiftUI patterns

### The Unified Knowledge Layer
- 📦 SQLite schema (designed, not yet migrated)
- 🔄 Migration scripts (in progress)
- 🔄 FTS5 search indices (in progress)

---

## Common Questions

### "Should I read all three documents?"

**Not necessarily.**
- Use Maxwell? Just describe your problem.
- Curious about design? Read ARCHITECTURE-DECISION.md
- Extending Maxwell? Read KNOWLEDGE-MAINTENANCE.md
- Quick reference? Read README.md

### "What if I have a question Maxwell can't answer?"

Maxwell is built for **cutting-edge Apple development patterns**. It's designed to handle:
- Complex framework integration
- Production-ready code
- Real bugs and their solutions

If your question is "basic TCA tutorial" → sosumi for docs, maxwell-tca for patterns
If your question is "how do I combine TCA+RealityKit+SharePlay?" → maxwell-unified

### "Can I add my own discoveries?"

Yes. See KNOWLEDGE-MAINTENANCE.md: "Adding a Discovery"

Any real bug you've solved? Add it to the knowledge layer. Future developers (and AIs) will find it.

### "Is Maxwell replacing Smith validation?"

No. Different purposes:
- **Smith**: Is this code architecturally correct? (validation)
- **Maxwell**: How should I write this code? (expertise)

They complement each other.

---

## Next Steps

**Pick one:**

1. **I want to use Maxwell** → Describe your problem, skills will auto-trigger
2. **I want to understand the design** → Read `ARCHITECTURE-DECISION.md` (15 min)
3. **I want to extend Maxwell** → Read `KNOWLEDGE-MAINTENANCE.md` (20 min)
4. **I want a quick overview** → Read `README.md` (5 min)

---

## For AI Agents

If you're Claude or another AI working within Maxwell:

1. **Understand the distinction**: Skills (auto, single-domain) vs. Subagent (explicit, cross-domain)
2. **Know the knowledge structure**: patterns, integrations, anti_patterns, discoveries
3. **When extending**: Add to the knowledge layer, not as isolated markdown
4. **When helping developers**: Route single-domain to skills, cross-domain to unified subagent
5. **Document learnings**: New patterns/integrations get added to the knowledge layer

Your work accumulates in a structured way that helps future developers and AIs.

---

**Welcome to Maxwell. Start with a question or a document. Either way, you're good to go.**
