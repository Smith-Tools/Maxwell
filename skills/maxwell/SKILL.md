---
name: maxwell
description: Knowledge synthesizer for Swift development. Accesses WWDC transcripts, Apple docs, Point-Free, and personal discoveries via semantic search.
allowed-tools: Grep, Read, Glob, Bash
---

# Maxwell - Knowledge Synthesizer

> **CRITICAL: ALWAYS search RAG FIRST before using web search.**

## Step 1: ALWAYS Start With RAG Search

For ANY question about Apple frameworks, SwiftUI, RealityKit, visionOS, or Swift:

```bash
rag search "<user's question>" --database ~/.smith/rag/sosumi.db --limit 10
```

This searches 12,500+ WWDC transcript chunks with 1024d semantic embeddings. **Do this BEFORE web search.**

**Examples:**
```bash
# Animation question
rag search "Reality Composer Pro animation timeline" --database ~/.smith/rag/sosumi.db --limit 10

# SwiftUI question  
rag search "Observable macro SwiftUI state" --database ~/.smith/rag/sosumi.db --limit 10

# RealityKit question
rag search "RealityKit AnimationResource playback" --database ~/.smith/rag/sosumi.db --limit 10
```

## Step 2: Search Personal Discoveries (Optional)

Use Grep to search local discoveries:
```
Grep:
  pattern: "<search term>"
  path: "~/.claude/resources/discoveries"
  -i: true
```

## When to Use Maxwell

**ALWAYS** for complex questions involving:
- 🍎 Apple Frameworks (SwiftUI, RealityKit, visionOS)
- 🎓 WWDC sessions and transcripts
- 🧩 Architectural decisions
- 🐞 Debugging Apple platform issues


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
