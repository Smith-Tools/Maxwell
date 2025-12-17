# Maxwell v4.0: Simplified File-Based Architecture

## Overview

Maxwell v4.0 is a complete architectural simplification of the Maxwell knowledge system. Instead of using SQLite FTS5 databases with Python scripts, Maxwell now uses a file-based approach with built-in Claude Code tools (Grep, Read, Glob).

## What Changed (v3.0 → v4.0)

### Architecture

**v3.0 (Database-based):**
- SQLite FTS5 database (`maxwell.db`)
- Python script for search (`maxwell-knowledge-base.py`)
- Import/export process (librarian tool)
- Complex schema and migrations
- 234 documents (mostly third-party TCA docs)

**v4.0 (File-based):**
- Markdown files in `~/.claude/resources/discoveries/`
- Built-in tools: Grep, Read, Glob
- No import process - just copy files
- Simple folder structure
- 44 discoveries (all personal, first-party knowledge)

### Benefits

1. **Simplicity** - No database, no Python scripts, no migrations
2. **Transparency** - Human-readable markdown, easily editable
3. **Git-friendly** - Version control, diffs, blame all work naturally
4. **Maintainability** - Edit files directly, changes are immediate
5. **No overhead** - No import/export, no sync issues
6. **Speed** - Grep searches 44 files in milliseconds

### Trade-offs

- ❌ No BM25 ranking (but 44 docs is small enough to scan all results)
- ❌ No complex metadata queries (but don't need them)
- ❌ No embedded database relationships (can use wikilinks in markdown)

These trade-offs are acceptable for the current scale.

## File Structure

```
~/.claude/resources/discoveries/
├── DISCOVERY-01-*.md       # Numbered case studies
├── DISCOVERY-02-*.md
├── ...
├── DISCOVERY-14-NESTED-REDUCER-GOTCHAS.md  (Critical)
├── DISCOVERY-15-PRINT-OSLOG-PATTERNS.md    (Critical)
├── DISCOVERY-12-MODULE-BOUNDARY-VIOLATION.md (Critical)
├── DISCOVERY-POLICY.md     # Guidelines for documenting discoveries
├── EVOLUTION.md            # Historical learnings
├── AGENT-ROUTING.md        # Agent patterns
└── (40+ other personal documentation files)
```

## How Agents Use Maxwell

When agents encounter Swift/TCA questions:

1. **Search for relevant discoveries**
   ```
   Grep:
     pattern: "nested reducer"
     path: "~/.claude/resources/discoveries"
     output_mode: "files_with_matches"
     -i: true
   ```

2. **Read the full discovery**
   ```
   Read:
     file_path: "~/.claude/resources/discoveries/DISCOVERY-14-NESTED-REDUCER-GOTCHAS.md"
   ```

3. **Return the solution to user**

## Adding New Discoveries

1. Create markdown file in `~/.claude/resources/discoveries/`
2. Follow guidelines in `DISCOVERY-POLICY.md`
3. File is immediately searchable - no import needed

Example structure:
```markdown
# DISCOVERY-16: Your Problem Title

**Date**: 2025-12-05
**Impact**: CRITICAL
**Status**: RESOLVED

## Problem Summary
Brief description...

## Root Cause
Why it happened...

## Solution
How you fixed it...

## Code Examples
```

## Editing Discoveries

Simply edit the markdown file directly:
```bash
vim ~/.claude/resources/discoveries/DISCOVERY-14-*.md
# Git automatically tracks changes
git status
```

## Archived Components (v3.0)

Old Maxwell architecture is preserved for reference:

```
~/.claude/skills/maxwell-knowledge-ARCHIVED/      # Old skill
~/.claude/skills/maxwell-librarian-ARCHIVED/      # Old import tool
~/.claude/skills/maxwell-meta-ARCHIVED/           # Old meta skill
~/.claude/resources/databases/maxwell-ARCHIVED.db # Old database
```

### Rollback Instructions

If file-based approach doesn't work:

```bash
# Restore old skills
mv ~/.claude/skills/maxwell-knowledge-ARCHIVED ~/.claude/skills/maxwell-knowledge
mv ~/.claude/skills/maxwell-librarian-ARCHIVED ~/.claude/skills/maxwell-librarian
mv ~/.claude/skills/maxwell-meta-ARCHIVED ~/.claude/skills/maxwell-meta

# Restore database
mv ~/.claude/resources/databases/maxwell-ARCHIVED.db ~/.claude/resources/databases/maxwell.db

# Remove new maxwell
rm -rf ~/.claude/skills/maxwell
```

## Why This Change?

### Problem with v3.0

1. **Only 1 real discovery in 234 documents** - 99.6% was third-party TCA docs
2. **Complex infrastructure** - SQLite, Python, import/sync, migrations
3. **Maintenance burden** - Database schema, duplicates, stale docs
4. **Inaccessible** - Discoveries weren't in Maxwell, they were in Smith repo

### Solution with v4.0

1. **All 44 personal discoveries accessible** - Every personal case study is indexed

2. **Simple infrastructure** - Just files and built-in tools
3. **No maintenance** - Edit files, Git tracks changes
4. **Accessible** - Part of Smith-Tools repo, installed via script

## Performance Expectations

**Search time:** <5ms for Grep across 44 files
**Indexing:** Instant (no indexing needed)
**Update frequency:** Immediate (no sync delays)
**Storage:** ~200KB for all 44 discoveries

## Future Scaling

**When to consider upgrading:**
- Discoveries grow to 500+ documents (search becomes slow)
- Need semantic search (keyword matching insufficient)
- Want AI features (summarization, pattern extraction)
- Need complex metadata queries

At that point, consider:
- Vector database (Qdrant) for semantic search
- SQL database for complex queries
- Hybrid approach (files + database)

For now, keep it simple.

## Related Skills

- `sosumi` - Apple documentation (SwiftUI, UIKit, WWDC)
- `smith` - Smith framework validation
- Standard tools - Grep, Read, Glob (built-in)

## Quick Start

**List all discoveries:**
```
Grep:
  pattern: "DISCOVERY-"
  path: "~/.claude/resources/discoveries"
  output_mode: "files_with_matches"
```

**Search for a topic:**
```
Grep:
  pattern: "TCA reducer"
  path: "~/.claude/resources/discoveries"
  output_mode: "files_with_matches"
  -i: true
```

**Read a discovery:**
```
Read:
  file_path: "~/.claude/resources/discoveries/DISCOVERY-14-NESTED-REDUCER-GOTCHAS.md"
```

---

**Maxwell v4.0: Simple, maintainable, and discovery-focused.**
