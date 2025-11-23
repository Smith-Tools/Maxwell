# Maxwell Knowledge Layer - Maintenance & Extension Guide

This guide explains how to extend Maxwell's knowledge base with new patterns and content.

---

## Current System: Database-as-Source-of-Truth

Maxwell uses a **simple, storage-focused design**:

```
Content (imported once)
    ↓
SQLite documents table (73 documents, 327 KB)
    ↓
maxwell search queries
    ↓
Skills get results via CLI
```

**Why this works:**
- Database IS the source of truth (not markdown files)
- Content imported once via `maxwell migrate`, then markdown files deleted
- SQLite provides fast full-text search (3ms average)
- CLI binary is single access point
- No schema complexity - one flexible `documents` table
- No data duplication or sync issues
- Database snapshot version-controlled in git

**Database Location**: `~/.claude/resources/databases/maxwell.db`
**Current Content**: 73 documents across 5 categories (SharePlay, Point-Free, Architecture, Claude Code, General)

---

## How to Extend Maxwell's Knowledge

### Current State

The database already contains 73 documents indexed and searchable. The markdown source files have been deleted (since database is the source of truth).

To add NEW content in the future:

### Step 1: Create Markdown Files (Temporary)

Create `.md` files in a temporary location (not in the repository):

```markdown
# New Pattern Name

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

### Step 2: Migrate to Database

```bash
# Create temporary directory with your markdown files
mkdir /tmp/new-content
# ... add your .md files ...

# Migrate to the installed database
maxwell migrate /tmp/new-content
```

This:
- Finds all `.md` files recursively
- Extracts `# Title` as document title
- Infers domain from content or metadata
- Extracts tags from filename
- Inserts into `documents` table with metadata

### Step 3: Verify in Database

```bash
# Search for your new content
maxwell search "your-pattern-name"

# Query database to verify
sqlite3 ~/.claude/resources/databases/maxwell.db \
  "SELECT title, category FROM documents WHERE title LIKE '%new%';"
```

### Step 4: Delete Temporary Markdown Files

Once in the database, the markdown files are no longer needed:

```bash
rm -rf /tmp/new-content
```

The database IS the permanent storage now.

---

## Creating a New Skill (For a New Domain)

To add expertise in a new framework area:

1. **Create skill directory structure**:
   ```
   skills/skill-newdomain/
   ├── skill/
   │   ├── SKILL.md                    # Skill manifest (see below)
   │   └── guides/
   │       ├── guide-1.md
   │       ├── guide-2.md
   │       └── ...more guides
   └── README.md                       # Optional description
   ```

2. **Create SKILL.md manifest**:
   ```yaml
   ---
   name: "skill-newdomain"
   description: "Expertise in NewDomain framework"
   auto-triggers: ["KEYWORD1", "KEYWORD2", "KEYWORD3"]
   allowed-tools: [Bash]
   model: "claude-opus"
   ---

   # NewDomain Specialist

   I'm specialized in NewDomain development.

   When you ask about NewDomain, I can help with:
   - Core concepts and best practices
   - Implementation patterns and examples
   - Integration with other frameworks
   - Common pitfalls and how to avoid them

   I'll search Maxwell's knowledge base for relevant patterns
   and provide practical guidance.
   ```

3. **Add markdown guides to `guides/` directory**:
   - Follow the same format as other skill guides
   - Start with `# Title`
   - Include sections: Problem, Solution, Code Example, Validation Checklist
   - One guide per file

4. **Deploy and migrate**:
   ```bash
   cp -r skills/skill-newdomain ~/.claude/skills/
   maxwell migrate /Volumes/Plutonian/_Developer/Smith\ Tools/Maxwell/skills
   ```

---

## Database Schema

### documents table
Only active table for current content:

```
id                  - Auto-incrementing ID
title               - Document title (extracted from # Heading)
content             - Full markdown content
path                - Original file path
document_type       - "markdown" (all current documents)
category            - Framework (TCA, SharePlay, RealityKit, etc.)
subcategory         - Optional (e.g., "state-management" for TCA)
role                - "guide", "reference", "example", "checklist"
enforcement_level   - "required", "recommended", "optional"
tags                - Comma-separated keywords for search
file_size           - File size in bytes
line_count          - Number of lines
created_at          - Auto-set to current date when migrated
```

### patterns table
Prepared for future structured pattern storage:

```
id                  - Auto-incrementing ID
name                - Pattern name (unique identifier)
domain              - Primary domain (TCA, SharePlay, etc.)
problem             - Problem it solves
solution            - How to solve it
code_example        - Code snippet demonstrating pattern
created_at          - Auto-set to current date
last_validated      - Manual timestamp (when pattern was last tested)
is_current          - Boolean (is this pattern still valid?)
notes               - Additional context or caveats
```

**Current Status**: Empty. The `documents` table is sufficient for Maxwell v2.0. The `patterns` table exists for future use when structured pattern data becomes needed.

---

## Maintenance Tasks

### Keep Content Fresh

**When frameworks update** (e.g., TCA 1.25 released):
1. Find affected guides:
   ```bash
   grep -r "1.24" skills/skill-pointfree/
   ```
2. Update code examples to new API
3. Add note in guide: "(Updated for TCA 1.25 - November 2025)"
4. Commit to git
5. Re-migrate to update database:
   ```bash
   maxwell migrate skills/
   ```

**Quarterly review**:
1. Run search on common queries - do results make sense?
2. Check code examples still compile with current SDK
3. Merge duplicate guides (keep the better one)
4. Remove guides that are obsolete (delete markdown file)

### Before Adding Code Examples

Validation checklist:
- [ ] Code compiles with current Swift version
- [ ] Example is complete (not pseudo-code snippets)
- [ ] Example demonstrates the stated problem/solution
- [ ] Includes proper error handling
- [ ] Follows Apple Human Interface Guidelines and best practices
- [ ] Tested in a real project (not theoretical)

### Testing Changes

After modifying guides:
```bash
# Verify search works
maxwell search "your-pattern"

# Check results for your domain
maxwell domain TCA | grep -i "your-pattern"

# List all docs in a domain
maxwell domain SharePlay
```

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

**Database-as-Source-of-Truth**: The SQLite database IS the permanent storage. Content is imported once, markdown files deleted. No redundancy.

**Simple Schema**: One `documents` table stores all content as flexible blobs. No complex pattern/integration/discovery tables. Simple = sustainable.

**CLI-Driven**: Maxwell binary is the single query interface. No direct database access from skills. All queries go through `maxwell search`.

**Type-Safe**: SQLite.swift provides compile-time type checking. Proper null handling for optional fields. Zero unsafe code.

**Version-Controlled Database**: The `maxwell.db` file itself is version-controlled. Snapshot of knowledge at release time. Easy to rollback if needed.

**Human-Maintained**: No automatic content generation. Content is manually written, reviewed, and validated before import.

---

## Workflow for Future Maintenance

The typical workflow for adding new content to Maxwell:

```
1. Write markdown files in temporary directory (not in repo)
2. Run: maxwell migrate /tmp/your-content/
3. Verify: maxwell search "query" returns results
4. Verify: sqlite3 checks the database
5. Delete markdown files (no longer needed)
6. Database becomes the permanent record
```

That's it. Simple, clean workflow. No complex schema. No sync issues. Database is the source of truth.

---

## Next Steps

1. **Add new patterns** to skill `guides/` directories as markdown files
2. **Run migration** to index them: `maxwell migrate skills/`
3. **Test with search** to verify they appear: `maxwell search "topic"`
4. **Verify skills find them** - they'll appear in skill responses

**Maxwell becomes more valuable as its knowledge grows. The simplicity of the markdown-first approach means minimal overhead to add new expertise.**
