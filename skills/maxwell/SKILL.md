---
name: maxwell
description: Knowledge synthesizer for Swift development. Accesses personal discoveries, Apple documentation (sosumi), package docs (scully), and Point-Free tutorials. Multi-source pattern guidance and debugging support.
allowed-tools: Grep, Read, Glob, Bash
---

# Maxwell - Knowledge Synthesizer

**Reference**: 
- https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview
- `/Volumes/Plutonian/_Developer/Smith-Tools/ARCHITECTURE.md` (canonical architecture)

**Swift Version**: 6.2+ required (strict concurrency)

**Purpose:** Your proactive engineering partner. Synthesizes knowledge retrieval across all domains (Personal Discoveries, Apple Frameworks, Point-Free, Third-Party Packages).

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

### Step 1: Search Personal Discoveries

Use Grep tool to search all discoveries:
```
Grep:
  pattern: "<search term>"
  path: "~/.claude/resources/discoveries"
  output_mode: "files_with_matches"
  -i: true  # Case insensitive
```

### Step 2: Semantic Search via RAG Engine (smith-rag)

Maxwell integrates with **SmithRAG** - a semantic search engine with MLX embeddings (Qwen3 1024d vectors) running on Apple Silicon GPU.

**Search Apple Documentation & WWDC (via sosumi database):**
```bash
rag search "SwiftUI state management with Observable" --database ~/.smith/rag/sosumi.db --limit 10
```

**Search Personal Discoveries (via maxwell database):**
```bash
rag search "TCA navigation patterns I've used before" --database ~/.smith/rag/maxwell.db --limit 5
```

**Search Third-Party Package Docs (via scully database):**
```bash
rag search "dependency injection with Composable Architecture" --database ~/.smith/rag/scully.db --limit 8
```

**Features:**
- Semantic search (understands meaning, not just keywords)
- MLX Reranking for relevance
- 1024d embeddings (Qwen3-Embedding-0.6B-4bit)
- Runs entirely offline on Apple Silicon GPU
- FTS5 fallback for non-vector searches

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
