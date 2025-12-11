---
name: maxwell
description: The Smith Tools Orchestrator. Primary entry point for complex queries. Accesses personal discoveries (grep), Apple documentation (via sosumi status), and Point-Free tutorials (via pointfree CLI). Capable of multi-step reasoning and gathering context from multiple sources.
allowed-tools: Grep, Read, Glob, Bash
---

# Maxwell - The Orchestrator

**Purpose:** Your proactive engineering partner. Coordinators knowledge retrieval across all domains (Personal, Apple, Point-Free).

## When to Use Maxwell

**ALWAYS** the first port of call for complex questions involving:
- 🧩 Architectural decisions (integrating multiple patterns)
- 🍎 Apple Frameworks + TCA (how they work together)
- 🎓 Learning new concepts (searches WWDC + Point-Free)
- 🐞 Debugging (searches known issues + personal discoveries)
- TCA (The Composable Architecture) issues
- Smith framework architecture
- Debugging visionOS/SwiftUI problems
- Green Spurt project patterns

## How to Search Discoveries

### Step 1: Search for Relevant Discoveries

Use Grep tool to search all discoveries:
```
Grep:
  pattern: "<search term>"
  path: "~/.claude/resources/discoveries"
  output_mode: "files_with_matches"
  -i: true  # Case insensitive
```

### Step 2: Search External Knowledge (RAG)

Maxwell can query external knowledge bases directly.

**Search Point-Free Video Tutorials:**
```bash
pointfree rag-search "dependency injection with tca" --limit 5
```

**Search Apple Documentation & WWDC (Sosumi):**
```bash
sosumi rag-search "realitykit timeline animation" --limit 5
```

### Step 3: Read Specific Content

**Read Personal Discovery:**
```
Read:
  file_path: "~/.claude/resources/discoveries/DISCOVERY-14.md"
```

**Read External Content:**
Use `Read` on file paths returned by `rag-search`.

## Discovery Organization

**Location:** `~/.claude/resources/discoveries/`

**Discovery Types:**
- `DISCOVERY-*.md` - Numbered case studies with problem/solution/patterns
- `DISCOVERY-POLICY.md` - Guidelines for when to document discoveries
- `EVOLUTION.md` - Historical learnings and pattern evolution
- `AGENT-ROUTING.md` - Agent coordination patterns
- Other strategy and architecture documents

**Discovery Structure (typical):**
Each discovery contains:
1. Problem summary with impact assessment
2. Root cause analysis
3. Solution with code examples
4. Validated patterns
5. Lessons learned

## Key Discoveries (Quick Reference)

Use Glob to list all discoveries:
```
Glob:
  pattern: "DISCOVERY-*.md"
  path: "~/.claude/resources/discoveries"
```

**Critical discoveries include:**
- DISCOVERY-12: Module Boundary Violation (850-line inline reducer anti-pattern)
- DISCOVERY-14: Nested @Reducer Macro Gotchas (validated Point-Free patterns)
- DISCOVERY-15: Print vs OSLog Patterns
- Plus 40+ other documented case studies

## Search Tips

**By topic:**
- "nested reducer" → TCA composition patterns
- "module boundary" → Architecture decisions
- "compiler crash" → Build issues
- "visionOS" → Platform-specific patterns

**By severity:**
- "CRITICAL" → High-impact discoveries
- "RESOLVED" → Solved problems with patterns

**By project:**
- "Smith" → Framework development patterns
- "GreenSpurt" → Game development lessons

## What This Skill Provides

✅ **Orchestration** - Connects personal patterns with external docs
✅ **Unified Search** - Point-Free, WWDC, Apple Docs, and Local Discoveries
✅ **Reasoning** - Synthesizes answers from multiple sources
✅ **Context-Awareness** - Understands project architecture validation

## Tool Delegation

- **Build/Dependencies:** Delegates to `smith analyze` / `smith dependencies`
- **Apple Docs:** Uses `sosumi` CLI for retrieval
- **Point-Free:** Uses `pointfree` CLI for retrieval

## Maintenance

**Adding new discoveries:**
1. Create markdown file in `~/.claude/resources/discoveries/`
2. Follow DISCOVERY-POLICY.md guidelines
3. Done - immediately searchable

**Editing discoveries:**
1. Edit the markdown file directly
2. Git tracks changes automatically
3. No import/sync needed

**No database. No scripts. Just files.**
