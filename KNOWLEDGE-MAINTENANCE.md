# Maxwell Knowledge Layer - Maintenance & Extension Guide

This guide explains how to extend Maxwell's knowledge base with new patterns and content.

---

## Current System: Markdown-First Approach

Maxwell uses a **simple, elegant design**:

```
Markdown Files (Version-Controlled)
    ↓
maxwell migrate command
    ↓
SQLite documents table
    ↓
maxwell search queries
    ↓
Skills get results via CLI
```

**Why this works:**
- Source of truth is markdown files in git (easy to review, version-controlled)
- Migration extracts metadata automatically
- SQLite provides fast search
- CLI binary is single access point
- No complex schema management
- No data duplication between git and database

**Database Location**: `~/.claude/resources/databases/maxwell.db`

---

## How to Add Content to Maxwell

### Step 1: Create Markdown Files

Add `.md` files to skill directories:

```
skills/skill-pointfree/skill/guides/pattern-name.md
skills/skill-shareplay/skill/guides/feature-guide.md
skills/skill-meta/skill/architecture-guide.md
```

File format - just plain markdown:
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

### Step 2: Migrate to Database

```bash
maxwell migrate /Volumes/Plutonian/_Developer/Smith\ Tools/Maxwell/skills
```

This:
- Finds all `.md` files recursively
- Extracts `# Title` as document title
- Infers domain from directory path (skill-pointfree → TCA, skill-shareplay → SharePlay)
- Extracts tags from filename and path
- Inserts into `documents` table with full metadata

### Step 3: Query Results

Skills and agents access via CLI:

```bash
maxwell search "Reducer composition"                   # Search all
maxwell search "@Shared" --domain TCA                  # Search domain
maxwell domain SharePlay                               # List domain docs
maxwell pattern "TCA @Shared Single Owner"             # Find by name
```

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

**Markdown-First**: All content is markdown files in git. Database is a cached, searchable index.

**Simple Schema**: One `documents` table for current needs. No complex pattern/integration/discovery tables. Overengineering avoided.

**CLI-Driven**: Maxwell binary is the single source of truth for all queries. No direct database access from skills.

**Type-Safe**: SQLite.swift ensures compile-time type checking. Proper null handling for optional fields.

**Version-Controlled**: Content changes are tracked in git. Database is regenerated from source on each migrate.

**Human-Maintained**: No automatic content generation. Patterns are manually written, reviewed, and validated.

---

## Workflow

The typical workflow for extending Maxwell:

```
1. Write a markdown guide in skill/guides/
2. Commit to git
3. Run: maxwell migrate skills/
4. Search returns new content: maxwell search "query"
5. Skills access via: maxwell search (called from SKILL.md)
```

That's it. No complex tables. No schema migrations. No data entry forms. Just markdown files and a simple migration process.

---

## Next Steps

1. **Add new patterns** to skill `guides/` directories as markdown files
2. **Run migration** to index them: `maxwell migrate skills/`
3. **Test with search** to verify they appear: `maxwell search "topic"`
4. **Verify skills find them** - they'll appear in skill responses

**Maxwell becomes more valuable as its knowledge grows. The simplicity of the markdown-first approach means minimal overhead to add new expertise.**
