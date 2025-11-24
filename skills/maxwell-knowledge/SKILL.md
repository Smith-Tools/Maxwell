---
name: Maxwell Knowledge Base
description: Comprehensive knowledge base with SQLite database containing Swift/TCA patterns, architectural decisions, production solutions, game analysis, and development guidance. Auto-activates for any technical questions about Swift, Apple platforms, or project analysis.
tags:
  - "Smith"
  - "knowledge base"
  - "SQLite"
  - "SwiftUI"
  - "TCA"
  - "architecture"
  - "compilation"
  - "errors"
  - "solutions"
  - "patterns"
  - "debugging"
  - "visionOS"
  - "iOS"
  - "macOS"
  - "Green Spurt"
  - "SharePlay"
  - "game"
  - "project"
  - "analysis"
  - "database"
  - "technical questions"
  - Bash
allowed-tools: Bash
version: "3.0.0"
author: "Claude Code Skill - Maxwell Architecture"
---

# Maxwell Knowledge Base

**For:** Swift developers needing instant access to comprehensive knowledge and solutions
**Purpose**: Provide immediate access to 54 documents with 80,000+ words of proven Swift/TCA patterns and solutions
**Expertise**: **Knowledge Base** with SQLite FTS5 search, BM25 ranking, and cross-domain pattern retrieval
**Content**: Complete Swift/TCA knowledge base with production-tested solutions

## 🎯 Skill Invocation

**When invoked, this skill:**
1. **Executes** `python3 ~/.claude/skills/maxwell-knowledge/knowledge/maxwell-knowledge-base.py "query"` (home-relative path)
2. **Searches** the SQLite database at `~/.claude/resources/databases/maxwell.db`
3. **Returns** structured JSON with relevant knowledge and source references
4. **Uses** BM25 ranking and FTS5 for optimal search results

**Required Tool:** `Bash` (to execute Python script)

## 🎯 What This Skill Provides

### **Instant Knowledge Access**
- **Database Location**: `~/.claude/resources/databases/maxwell.db`
- **Knowledge Size**: Extensive documentation covering Swift/TCA expertise
- **Search Performance**: <5ms queries with BM25 ranking
- **Cross-Domain**: SwiftUI, TCA, visionOS, iOS, macOS patterns
- **Production-Tested**: Real-world solutions from Smith development

### **Knowledge Domains Covered**

#### **SwiftUI Patterns & Solutions**
- **@StateObject vs @ObservedObject**: Memory management patterns
- **View Lifecycle**: Proper state management approaches
- **Compilation Errors**: Common SwiftUI fixes and solutions
- **Performance**: Memory leak prevention and optimization
- **Platform-Specific**: iOS, macOS, visionOS variations

#### **TCA (The Composable Architecture)**
- **Nested Reducers**: TCA 1.23+ enum-based patterns
- **State Management**: ObservableState, @Shared patterns
- **Compilation Fixes**: @Reducer struct to enum migration
- **Dependency Injection**: Modern TCA dependency patterns
- **Testing Strategies**: TCA testing architecture and patterns

#### **Platform-Specific Guidance**
- **visionOS**: RealityKit integration, spatial computing
- **iOS**: UIKit integration, lifecycle management
- **macOS**: AppKit patterns, menu bar applications
- **Cross-Platform**: Shared code architecture and patterns

#### **Error Resolution & Debugging**
- **Compilation Errors**: "Cannot find in scope", type mismatches
- **Runtime Issues**: "Unexpectedly found nil", lifecycle problems
- **Memory Management**: Retain cycles, weak reference patterns
- **Performance**: Memory leaks, optimization strategies

## 🔧 Knowledge Base Structure

### **SQLite Database Schema**
```sql
-- Knowledge table with full-text search
CREATE TABLE knowledge (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT,
    folder TEXT,
    tags TEXT,  -- JSON array
    source_file TEXT,
    word_count INTEGER,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- FTS5 virtual table for fast search
CREATE VIRTUAL TABLE knowledge_fts USING fts5(
    content, title, folder, tags,
    content='knowledge',
    content_rowid='rowid'
);

-- Relations for cross-linking
CREATE TABLE relations (
    source_id TEXT,
    target_id TEXT,
    relation_type TEXT,
    created_at TIMESTAMP,
    PRIMARY KEY (source_id, target_id)
);
```

### **Knowledge Organization**
```
Smith Knowledge Base:
├── SwiftUI/           # @StateObject, @ObservedObject, view patterns
├── TCA/              # Reducers, state management, testing
├── visionOS/         # RealityKit, spatial computing
├── iOS/              # UIKit, lifecycle, platform patterns
├── macOS/            # AppKit, menu bar, macOS patterns
├── Errors/           # Compilation fixes, debugging
├── Architecture/     # Design patterns, best practices
└── Performance/      # Memory, optimization, profiling
```

## 🚀 Key Capabilities

### **Immediate Pattern Retrieval**
- **Search Speed**: <5ms for any query across 80,000+ words
- **Relevance Ranking**: BM25 algorithm for accurate results
- **Cross-Domain**: Single query searches across all knowledge domains
- **Context-Aware**: Understands Swift/SwiftUI/TCA terminology

### **Production Solutions**
- **Real Patterns**: Actual solutions from Smith framework development
- **Tested Fixes**: Proven compilation error resolutions
- **Architecture Decisions**: Documented reasoning behind patterns
- **Migration Guides**: TCA version upgrades and breaking changes

### **Comprehensive Coverage**
- **54 Documents**: Complete Smith framework documentation
- **80,023 Words**: Extensive coverage of Swift development patterns
- **Multiple Platforms**: iOS, macOS, visionOS specialized guidance
- **All Skill Levels**: From beginner SwiftUI to advanced TCA patterns

## 🎯 Usage Examples

### **SwiftUI Pattern Search**
```
User: "@StateObject memory leak in child view"
→ Retrieves immediate solution with proper pattern usage
```

### **TCA Compilation Fixes**
```
User: "TCA nested @Reducer compilation error TCA 1.23"
→ Provides enum-based solution pattern with code examples
```

### **Cross-Platform Issues**
```
User: "visionOS RealityKit SwiftUI integration performance"
→ Returns platform-specific optimization patterns
```

### **Error Resolution**
```
User: "Cannot find in scope SwiftUI property"
→ Provides debugging steps and common fixes
```

### **Architecture Decisions**
```
User: "When to use @StateObject vs @ObservedObject"
→ Returns comprehensive guidance with examples
```

## 🔧 How to Use This Skill

**IMPORTANT**: This skill provides access to a SQLite database via Python script. When a user asks for information:

1. **Execute the Python script** using the home-relative path for cross-directory compatibility:
   ```bash
   python3 ~/.claude/skills/maxwell-knowledge/knowledge/maxwell-knowledge-base.py "user query here"
   ```

2. **The script will automatically**:
   - Search the SQLite database with FTS5
   - Find relevant knowledge documents
   - Return structured results with source references

3. **Process the results**:
   - If `status: knowledge_found`: Use the content from the database
   - If `status: no_knowledge_found`: Admit no information is available

**Script Output Format:**
```json
{
  "status": "knowledge_found",
  "solution": "content from database",
  "source": "Document Title",
  "response_time": 0.004,
  "reasoning": "Found relevant solution in knowledge base",
  "tags": ["tca", "swiftui", "visionos"]
}
```

## 🔍 Knowledge Access Methods

### **Direct Database Queries**
```python
import sqlite3
import json
from pathlib import Path

class SmithKnowledgeBase:
    def __init__(self):
        db_path = Path.home() / ".claude" / "resources" / "databases" / "maxwell.db"
        self.conn = sqlite3.connect(db_path)

    def search(self, query: str, limit: int = 5):
        cursor = self.conn.execute('''
            SELECT knowledge.id, knowledge.title, knowledge.content, knowledge.folder, knowledge.tags,
                   snippet(knowledge_fts, 1, '🔸', '🔹', '...', 100) as snippet
            FROM knowledge_fts
            JOIN knowledge ON knowledge.rowid = knowledge_fts.rowid
            WHERE knowledge_fts MATCH ?
            ORDER BY bm25(knowledge_fts)
            LIMIT ?
        ''', (query, limit))
        return cursor.fetchall()
```

### **Agent Integration Pattern**
```python
def solve_developer_problem(self, query: str) -> Dict:
    # Search knowledge base
    kb_results = self._search_knowledge(query, limit=5)

    if kb_results:
        best_match = kb_results[0]
        return {
            'status': 'knowledge_found',
            'solution': best_match['content'],
            'source': best_match['title'],
            'reasoning': 'Found relevant solution in Smith knowledge base',
            'tags': best_match.get('tags', [])
        }
    else:
        return {
            'status': 'reasoning_required',
            'solution': self._reason_about_problem(query),
            'source': 'general_reasoning'
        }
```

## 📊 Knowledge Base Statistics

### **Current Content**
- **Documents**: Extensive Smith framework documentation
- **Word Count**: Comprehensive Swift/TCA expertise
- **Domains**: Multiple knowledge domains
- **Performance**: <5ms search across all content
- **Database**: SQLite with FTS5 full-text search

### **Coverage Areas**
- **SwiftUI**: 15+ documents on patterns, errors, best practices
- **TCA**: 12+ documents on architecture, testing, migration
- **Platform-Specific**: 8+ documents covering iOS, macOS, visionOS
- **Error Solutions**: 10+ documents of compilation fixes and debugging
- **Architecture**: 9+ documents on design patterns and decisions

## ✅ Authority and Validation

### **Smith Framework Excellence**
- **Production Tested**: All patterns from actual Smith framework development
- **Comprehensive Coverage**: Complete lifecycle from beginner to advanced patterns
- **Performance Validated**: <5ms query time with 80,000+ words
- **Continuously Updated**: Imported from latest Smith documentation

### **Technical Excellence**
- **SQLite FTS5**: Full-text search with BM25 relevance ranking
- **Cross-Referenced**: Wiki-style links between related concepts
- **Tagged Content**: JSON tag arrays for precise domain filtering
- **Metadata Tracking**: Word counts, folders, source file references

### **Developer-Focused**
- **Real Problems**: Solutions from actual Swift development challenges
- **Code Examples**: Practical implementations with explanations
- **Version-Specific**: TCA 1.23+, SwiftUI version considerations
- **Platform Awareness**: iOS, macOS, visionOS specialized guidance

## 🎯 Getting Started

### **For SwiftUI Developers**
Ask about SwiftUI patterns and errors:
- "@StateObject vs @ObservedObject best practices"
- "SwiftUI compilation error fixes"
- "Memory management in SwiftUI views"

### **For TCA Developers**
Ask about architecture and patterns:
- "TCA nested reducer compilation solutions"
- "State management with @Shared and ObservableState"
- "TCA testing architecture patterns"

### **For Cross-Platform Development**
Ask about platform-specific guidance:
- "visionOS RealityKit integration patterns"
- "Cross-platform Swift architecture decisions"
- "iOS UIKit and SwiftUI integration"

### **For Problem Solving**
Ask about specific issues:
- "Cannot find in scope error Swift"
- "Memory leak debugging iOS"
- "Performance optimization SwiftUI"

**Maxwell Smith Knowledge Expert** provides immediate access to the complete Smith framework knowledge base with production-tested patterns, compilation fixes, and architectural guidance for Swift/TCA development across all Apple platforms.