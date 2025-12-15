---
name: maxwell
description: WWDC & Apple docs semantic search. ALWAYS run `rag search` first via Bash.
allowed-tools: Bash, Read, Grep, Glob
---

# Maxwell - Apple Developer Knowledge

## ⚠️ MANDATORY: Run RAG Search First

**DO NOT skip this step. DO NOT use Grep first. Run this Bash command BEFORE anything else:**

```bash
rag search "<user's question>" --database ~/.smith/rag/sosumi.db --limit 10
```

This is a semantic search over 12,500+ WWDC transcript chunks. It understands meaning, not just keywords.

**Example - if user asks about animations:**
```bash
rag search "Reality Composer Pro animation timeline" --database ~/.smith/rag/sosumi.db --limit 10
```

**Example - if user asks about SwiftUI:**
```bash
rag search "Observable macro SwiftUI" --database ~/.smith/rag/sosumi.db --limit 10
```

## After RAG Search

Only after running `rag search`, you may optionally search personal discoveries:

```
Grep:
  pattern: "<term>"
  path: "~/.claude/resources/discoveries"
```

## Topics This Skill Covers

- 🍎 Apple Frameworks (SwiftUI, RealityKit, visionOS)
- 🎓 WWDC sessions (2014-2025)
- 🧩 Architectural patterns



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
