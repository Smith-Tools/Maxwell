# Maxwell Knowledge Base - Documentation Import Guide

## Overview

Maxwell now supports a comprehensive documentation import system with hybrid database architecture for efficient knowledge retrieval.

## Architecture

### Dual-Table System
- **Patterns Table**: High-value synthesized patterns for first-line responses (265+ patterns)
- **Reference Table**: Complete documentation with folder structure preservation (184+ documents)
- **Total**: 481 documents, 255,001 words across 8 libraries

### Supported Libraries
1. **ComposableArchitecture** (73 docs) - TCA patterns, migration guides, API usage
2. **SwiftDependencies** (27 docs) - Dependency injection, testing, lifecycle
3. **SwiftSharing** (22 docs) - @Shared state management, observation, mutation
4. **SQLiteData** (18 docs) - Database patterns, performance, migration
5. **StructuredQueries** (44 docs) - SQL patterns, optimization, schema design
6. **Smith Framework** (Core) - Architecture patterns, best practices

## Import Process

### Step 1: Import Documentation
```bash
python3 ~/.claude/skills/maxwell-knowledge/knowledge/migrate-database.py \
  --import-docs "/path/to/documentation" \
  --library "LibraryName"
```

### Step 2: Generate Patterns (Library-Specific)
```bash
# For SQLiteData
python3 ~/.claude/skills/maxwell-knowledge/knowledge/synthesize-patterns.py

# For Structured Queries
python3 ~/.claude/skills/maxwell-knowledge/knowledge/synthesize-structured-queries-patterns.py

# For Composable Architecture
python3 ~/.claude/skills/maxwell-knowledge/knowledge/synthesize-composable-patterns.py

# For Swift Dependencies
python3 ~/.claude/skills/maxwell-knowledge/knowledge/synthesize-dependencies-patterns.py

# For Swift Sharing
python3 ~/.claude/skills/maxwell-knowledge/knowledge/synthesize-sharing-patterns.py
```

### Step 3: Verify Integration
```bash
# Test search functionality
python3 ~/.claude/skills/maxwell-knowledge/knowledge/maxwell-hybrid-search.py "test query"

# Check statistics
python3 ~/.claude/skills/maxwell-knowledge/knowledge/migrate-database.py --stats
```

## Pattern Types

### Extracted Automatically
- **Migration Patterns**: Version-specific upgrade guides and breaking changes
- **API Usage Patterns**: Code examples and function signatures
- **Conceptual Patterns**: High-level concepts and principles
- **Performance Patterns**: Optimization techniques and best practices
- **Anti-Patterns**: Common pitfalls and warnings to avoid

### Search System
- **Pattern-First Priority**: Fast high-precision results (0.001s response time)
- **Reference Fallback**: Comprehensive documentation coverage
- **Progressive Disclosure**: Summary → Details → Full content
- **FTS5 Search**: Full-text search with BM25 ranking

## Current Capabilities

### ✅ Working Well
- Document discovery and navigation
- Fast pattern-based search
- Multi-library cross-referencing
- Automatic pattern synthesis
- Scalable import process (supports 50+ libraries)
- Token optimization (85% reduction in responses)

### 🔄 Future Enhancements
- Agent-level conversation context for follow-ups
- Code example extraction and analysis
- Syntax-aware search (Swift @ symbols)
- Progressive disclosure with detail expansion
- Interactive teaching capabilities

## Database Schema

### Patterns Table
```sql
CREATE TABLE patterns (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT,
    folder TEXT,
    folder_path TEXT,
    doc_type TEXT,
    library TEXT,
    summary TEXT,
    tags TEXT,
    word_count INTEGER
);
```

### Reference Table
```sql
CREATE TABLE reference (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT,
    folder_path TEXT,
    doc_type TEXT,
    library TEXT,
    file_path TEXT,
    word_count INTEGER,
    summary TEXT,
    tags TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Performance

- **Search Speed**: 0.001-0.003s average response time
- **Database Size**: 255,001 words across 481 documents
- **Scalability**: Designed to handle 100+ libraries efficiently
- **Memory Usage**: SQLite FTS5 with BM25 optimization

## Usage Examples

### Search Commands
```bash
# Find TCA patterns
python3 maxwell-hybrid-search.py "TCA performance"

# Find dependency patterns
python3 maxwell-hybrid-search.py "dependency testing"

# Find sharing patterns
python3 maxwell-hybrid-search.py "Shared state mutation"
```

### Agent Integration
The Maxwell agent automatically queries this knowledge base for any technical questions about Swift, TCA, or architecture patterns.

## File Structure
```
Maxwell/skills/maxwell-knowledge/knowledge/
├── maxwell-hybrid-search.py          # Main search interface
├── maxwell-token-optimized.py        # Token optimization system
├── migrate-database.py              # Documentation import tool
├── synthesize-patterns.py           # SQLiteData pattern synthesis
├── synthesize-structured-queries-patterns.py  # Structured Queries synthesis
├── synthesize-composable-patterns.py # Composable Architecture synthesis
├── synthesize-dependencies-patterns.py # Swift Dependencies synthesis
└── synthesize-sharing-patterns.py    # Swift Sharing synthesis
```

## Statistics (Current)
- **Patterns**: 297 documents, 144,760 words
- **Reference**: 184 documents, 110,241 words
- **Libraries**: 8 integrated libraries
- **Total Knowledge**: 481 documents, 255,001 words

This system provides comprehensive Swift/TCA knowledge discovery with scalable architecture for future expansion.