---
name: Maxwell Librarian
description: Private knowledge base management for importing documentation, detecting duplicates, and synthesizing patterns. Manual invocation only.
tags:
  - "Knowledge Management"
  - "Database Management"
  - "Documentation Import"
  - "Pattern Synthesis"
  - "Maxwell"
  - "Duplicate Detection"
allowed-tools: [Bash, Read, Write, Glob]
version: "1.0.0"
author: "Claude Code Skill - Maxwell Architecture"
---

# Maxwell Librarian - Private Knowledge Management

**MANUAL INVOCATION ONLY** - This skill requires explicit user invocation and will not auto-trigger in conversations.

## Primary Mission:
Assist users in adding new knowledge to Maxwell's database with intelligent duplicate detection and quality validation. Coordinates existing Maxwell tools to simplify the knowledge curation process.

## When to Use:
- Deliberate knowledge base updates
- Adding new documentation libraries
- Pattern synthesis from imported content
- Knowledge base maintenance and optimization
- Duplicate analysis before importing

## Manual Invocation Only:
```bash
# Explicit skill invocation (only method):
/skill maxwell-librarian import "/path/to/docs" "LibraryName"
/skill maxwell-librarian check-duplicates "/path/to/docs" "LibraryName"
/skill maxwell-librarian synthesize "LibraryName"
/skill maxwell-librarian validate "LibraryName"
```

## Available Operations:

### Import Management:
- `import` - Import documentation with duplicate detection
- `check-duplicates` - Analyze content for overlaps with existing knowledge
- `validate-import` - Test if import was successful

### Pattern Synthesis:
- `synthesize` - Generate patterns from imported documentation
- `validate-patterns` - Test pattern search functionality

### Database Management:
- `get-stats` - Current knowledge base statistics
- `clean-duplicates` - Remove duplicate content
- `optimize-search` - Improve search performance

## Usage Examples:

### Basic Documentation Import:
```bash
/skill maxwell-librarian import "/Users/Me/Downloads/RealityKit-Docs" "RealityKit"
```

### Duplicate Analysis Before Import:
```bash
/skill maxwell-librarian check-duplicates "/path/to/SwiftUI-docs" "SwiftUI"
```

### Pattern Synthesis:
```bash
/skill maxwell-librarian synthesize "ComposableArchitecture"
```

## Safety Features:
- Always requires explicit user confirmation before database modifications
- Shows duplicate analysis results before proceeding
- Provides rollback instructions for recent changes
- Tracks all operations with timestamps and logging

## Quality Validation:
- Tests search functionality after import
- Validates pattern synthesis quality
- Checks for content accessibility
- Provides knowledge base health metrics

## Integration with Existing Maxwell Tools:
This skill coordinates with existing Maxwell tools:
- `migrate-database.py` - Documentation import script
- `maxwell-hybrid-search.py` - Search testing tool
- Pattern synthesis scripts - Library-specific pattern generation

The skill provides intelligent coordination while you maintain full control over what gets added to Maxwell's knowledge base.