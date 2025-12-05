---
name: Maxwell
description: Personal discovery knowledge base for Swift/TCA development. Auto-activates for Swift/TCA questions to search documented case studies and debugging patterns in ~/.claude/resources/discoveries/
tags:
  - "Smith"
  - "discoveries"
  - "Swift"
  - "TCA"
  - "debugging"
  - "case studies"
  - "visionOS"
  - "SwiftUI"
allowed-tools: [Grep, Read, Glob]
version: "4.0.0"
author: "Claude Code Skill - Simplified Architecture"
---

# Maxwell - Personal Discovery Knowledge Base

**Purpose:** Provide instant access to personal Swift/TCA discoveries and case studies

## When to Use This Skill

Auto-activates when user asks about:
- Swift development patterns
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

### Step 2: Read Specific Discovery

Once you find a relevant discovery, read it:
```
Read:
  file_path: "~/.claude/resources/discoveries/DISCOVERY-14-NESTED-REDUCER-GOTCHAS.md"
```

### Step 3: Search Within Discovery

If you need more context from a discovery:
```
Grep:
  pattern: "<specific pattern>"
  path: "~/.claude/resources/discoveries/DISCOVERY-14-NESTED-REDUCER-GOTCHAS.md"
  output_mode: "content"
  -C: 10  # Show 10 lines of context
```

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

✅ **Personal Knowledge** - Your documented discoveries, not third-party docs
✅ **Production-Tested** - Real solutions from actual projects
✅ **Context-Rich** - Case studies with reasoning, not just code snippets
✅ **Always Fresh** - Files are source of truth, no import/sync needed
✅ **Git-Tracked** - Version controlled, diffable, blameable

## What This Skill Does NOT Provide

❌ **Third-party documentation** - Use `sosumi` skill for Apple docs
❌ **TCA reference docs** - Use WebSearch for latest TCA documentation
❌ **General Swift questions** - Use reasoning or WebSearch

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
