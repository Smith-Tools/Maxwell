# Maxwell Knowledge Layer - Maintenance & Extension Guide

This guide explains how to extend Maxwell's knowledge base with new patterns and content.

---

## Current Database Structure

Maxwell uses SQLite with two main tables:

| Table | Purpose | Current Rows |
|-------|---------|--------------|
| `documents` | Markdown files from skill directories | 70 |
| `patterns` | Structured patterns with metadata | (prepared for future) |

**Database Location**: `~/.claude/resources/databases/maxwell.db`

---

## How Maxwell Works

1. **Markdown files** live in skill directories:
   - `skills/skill-pointfree/skill/guides/*.md`
   - `skills/skill-shareplay/skill/guides/*.md`
   - `skills/skill-meta/skill/*.md`

2. **Migration process**:
   ```bash
   maxwell migrate /path/to/skills
   ```
   - Recursively finds all `.md` files
   - Extracts title from `# Title` in markdown
   - Infers domain from file path
   - Inserts into `documents` table with metadata

3. **Search access**:
   ```bash
   maxwell search "query" [--domain TCA|SharePlay] [--limit N]
   ```
   - Skills call this command via Bash tool
   - Returns matching documents from database
   - Results ranked by relevance

---

## Adding Content to Maxwell

### Method 1: Add Markdown Files (Easiest)

For single-domain patterns, add markdown files to skill directories:

**For TCA patterns:**
```
skills/skill-pointfree/skill/guides/pattern-name.md
```

**For SharePlay patterns:**
```
skills/skill-shareplay/skill/guides/pattern-name.md
```

**For Maxwell's own patterns:**
```
skills/skill-meta/skill/pattern-name.md
```

**File format:**
```markdown
# Pattern Name

## Problem
What problem does this solve?

## Solution
How to solve it.

## Code Example
Real working code.

## Validation Checklist
- [ ] Item 1
- [ ] Item 2
```

**After adding files:**
```bash
maxwell migrate /Volumes/Plutonian/_Developer/Smith\ Tools/Maxwell/skills
```

This updates the database with new documents.

### Method 2: Create New Skill (For New Domain)

To add a new specialized skill:

1. **Create skill directory**:
   ```
   skills/skill-newdomain/
   ├── skill/
   │   ├── SKILL.md              # Skill manifest
   │   └── guides/
   │       ├── pattern1.md
   │       ├── pattern2.md
   │       └── ...
   └── README.md
   ```

2. **Create SKILL.md manifest** (copy from existing skill and modify):
   ```yaml
   ---
   name: "skill-newdomain"
   description: "Specialization in NewDomain"
   auto-triggers: ["KEYWORD1", "KEYWORD2"]
   allowed-tools: [Bash]
   model: "claude-opus"
   ---

   # NewDomain Specialist

   Your expertise blurb...

   When users ask about NewDomain, I can help with:
   - Task 1
   - Task 2
   ```

3. **Deploy new skill**:
   ```bash
   cp -r skills/skill-newdomain ~/.claude/skills/
   ```

4. **Migrate content**:
   ```bash
   maxwell migrate ~/path/to/skill
   ```

---

## Database Schema

### documents table
```
id                  - Auto-incrementing ID
title               - Document title (from # Heading)
content             - Full markdown content
path                - File path
document_type       - "markdown" or "pattern"
category            - Framework category (TCA, SharePlay, etc.)
subcategory         - Optional subcategory
role                - "guide", "reference", "example", "checklist"
enforcement_level   - "required", "recommended", "optional"
tags                - Comma-separated keywords
file_size           - Size in bytes
line_count          - Number of lines
created_at          - Auto-set to current date
```

### patterns table
```
id                  - Auto-incrementing ID
name                - Pattern name (unique)
domain              - Primary domain (TCA, SharePlay, etc.)
problem             - Problem it solves
solution            - How to solve it
code_example        - Code snippet
created_at          - Auto-set
last_validated      - Manual timestamp of last verification
is_current          - Boolean: is this pattern still valid?
notes               - Additional notes
```

---

## Maintenance Tasks

### Keeping Patterns Fresh

**Quarterly review**:
1. Update code examples for new framework versions
2. Remove obsolete patterns (mark `is_current = false`)
3. Add validation notes to patterns
4. Merge duplicate patterns

**When a framework updates**:
1. Search related markdown files:
   ```bash
   grep -r "1.24" skills/skill-pointfree/
   ```
2. Update code examples to new version
3. Add note: "(Updated for TCA 1.25)"
4. Re-migrate:
   ```bash
   maxwell migrate skills/
   ```

### Testing Content

Verify markdown is valid:
```bash
# Check markdown syntax
maxwell search "your-pattern" --domain TCA

# Manually verify binary works
maxwell domain TCA | head -5
```

### Validating Code Examples

Before adding code examples:
- [ ] Code compiles with current Swift version
- [ ] Example is complete (not pseudo-code)
- [ ] Example solves the stated problem
- [ ] Includes error handling where needed
- [ ] Follows Apple best practices
- [ ] Tested in real project (not theoretical)

---

## Troubleshooting

### Database is empty after migration

```bash
# Check database file exists
ls -la ~/.claude/resources/databases/maxwell.db

# Check document count
sqlite3 ~/.claude/resources/databases/maxwell.db \
  "SELECT COUNT(*) FROM documents;"

# Re-initialize and migrate
maxwell init
maxwell migrate /path/to/skills
```

### Binary not found after migration

```bash
# Make sure maxwell is in PATH
which maxwell
# Should output: /Users/username/.local/bin/maxwell

# If not, rebuild:
cd database
swift build --configuration release
cp .build/release/Maxwell ~/.local/bin/maxwell
```

### Markdown not appearing in search results

1. Check file is in correct directory:
   ```bash
   find skills/ -name "*.md" | grep pattern
   ```

2. Verify migration ran:
   ```bash
   maxwell search "pattern-name"
   ```

3. Check title format in file:
   ```
   # Exact Title Here
   ```
   Must be first line starting with `# `

4. Re-run migration:
   ```bash
   maxwell migrate skills/
   ```

---

## CLI Command Reference

```bash
# Search across all documents
maxwell search "Reducer composition"

# Search specific domain
maxwell search "@Shared" --domain TCA

# List all patterns in domain
maxwell domain SharePlay

# Find pattern by name
maxwell pattern "TCA @Shared Single Owner"

# Initialize empty database (use if corrupted)
maxwell init

# Migrate markdown files from skills directory
maxwell migrate /path/to/skills

# Get help
maxwell --help
```

---

## Design Principles

**Markdown-First**: Content lives in version-controlled markdown files, not just in database.

**CLI-Driven**: Maxwell binary is single source of truth for queries. Skills don't access database directly; they call the binary.

**Type-Safe**: SQLite.swift ensures compile-time checked queries with proper null handling.

**Stateless Search**: Each search is independent. No caching or indexing optimization needed.

**Human-Maintained**: No automatic ingestion or contradiction detection. Content is manually curated.

---

## Next Steps

1. Add new markdown files to skill `guides/` directories
2. Run `maxwell migrate skills/` to populate database
3. Test with `maxwell search` command
4. Verify skills can access content via Bash tool

**Maxwell becomes more valuable as its knowledge grows. Every pattern documented helps the next developer.**
