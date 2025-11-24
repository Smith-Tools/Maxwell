#!/usr/bin/env python3
"""
MAXWELL KNOWLEDGE BASE INTEGRATION
For Maxwell Skill - Embedded SQLite database with comprehensive knowledge
Database location: ~/.claude/resources/databases/maxwell.db
Knowledge repository: ~/.claude/resources/knowledge/maxwell/
"""

import sqlite3
import hashlib
import json
import re
import sys
import os
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Optional, Tuple

class MaxwellKnowledgeBase:
    """Maxwell knowledge base with comprehensive knowledge integration"""

    def __init__(self):
        # Follow user directory pattern like Sosumi/Maxxpunk
        self.db_dir = Path.home() / ".claude" / "resources" / "databases"
        self.db_dir.mkdir(parents=True, exist_ok=True)

        # Knowledge repository
        self.knowledge_dir = Path.home() / ".claude" / "resources" / "knowledge" / "maxwell"

        self.db_path = self.db_dir / "maxwell.db"
        self.conn = None

        # Performance stats
        self.stats = {
            'total_queries': 0,
            'kb_hits': 0,
            'cache_hits': 0,
            'response_times': []
        }

        # Cache for recent queries
        self.cache = {}
        self.cache_limit = 50

        self._initialize_database()
        self._load_or_import_knowledge()

    def _initialize_database(self):
        """Initialize SQLite database with FTS5"""
        self.conn = sqlite3.connect(self.db_path)

        # Knowledge table
        self.conn.execute('''
            CREATE TABLE IF NOT EXISTS knowledge (
                id TEXT PRIMARY KEY,
                title TEXT NOT NULL,
                content TEXT,
                folder TEXT,
                tags TEXT,  -- JSON array
                source_file TEXT,
                word_count INTEGER,
                created_at TIMESTAMP,
                updated_at TIMESTAMP
            )
        ''')

        # Full-text search table
        self.conn.execute('''
            CREATE VIRTUAL TABLE IF NOT EXISTS knowledge_fts USING fts5(
                content, title, folder, tags,
                content='knowledge',
                content_rowid='rowid'
            )
        ''')

        # Relations table
        self.conn.execute('''
            CREATE TABLE IF NOT EXISTS relations (
                source_id TEXT,
                target_id TEXT,
                relation_type TEXT,
                created_at TIMESTAMP,
                PRIMARY KEY (source_id, target_id)
            )
        ''')

        # Performance indexes
        self.conn.execute('CREATE INDEX IF NOT EXISTS idx_knowledge_folder ON knowledge(folder)')
        self.conn.execute('CREATE INDEX IF NOT EXISTS idx_knowledge_created ON knowledge(created_at DESC)')
        self.conn.execute('CREATE INDEX IF NOT EXISTS idx_relations_source ON relations(source_id)')

    def _load_or_import_knowledge(self):
        """Load existing knowledge or import from knowledge repository"""
        # Check if database has content
        existing_count = self.conn.execute('SELECT COUNT(*) FROM knowledge').fetchone()[0]

        if existing_count > 0:
            print(f"✅ Loaded {existing_count} knowledge entries from existing database")
        else:
            print(f"📚 Importing knowledge from repository...")
            self._import_knowledge_content()

            final_count = self.conn.execute('SELECT COUNT(*) FROM knowledge').fetchone()[0]
            print(f"✅ Imported {final_count} knowledge entries from repository")

    def _import_knowledge_content(self):
        """Import all knowledge from repository"""
        if not self.knowledge_dir.exists():
            print(f"⚠️  Knowledge repository not found: {self.knowledge_dir}")
            print(f"   Creating knowledge repository structure...")
            self._create_knowledge_repository()
            return

        all_md_files = list(self.knowledge_dir.rglob("*.md"))
        imported_count = 0

        print(f"📄 Found {len(all_md_files)} markdown files in knowledge repository")

        for md_file in all_md_files:
            if md_file.stat().st_size > 200:  # Skip very small files
                if self._import_markdown_file(md_file):
                    imported_count += 1

        print(f"✅ Successfully imported {imported_count} knowledge documents")

    def _create_knowledge_repository(self):
        """Create knowledge repository structure"""
        categories = ['smith', 'swiftui', 'tca', 'visionos', 'errors', 'architecture', 'platform-specific']

        for category in categories:
            category_dir = self.knowledge_dir / category
            category_dir.mkdir(parents=True, exist_ok=True)

        # Create README
        readme_content = """# Maxwell Knowledge Repository

This repository contains knowledge sources for Maxwell agent.

## Structure
- smith/ - Smith framework documentation
- swiftui/ - SwiftUI patterns and solutions
- tca/ - The Composable Architecture docs
- visionos/ - visionOS and spatial computing
- errors/ - Error solutions and debugging
- architecture/ - Software architecture patterns
- platform-specific/ - iOS, macOS, cross-platform patterns

Add markdown files to appropriate categories and run update to rebuild the database.
"""

        readme_path = self.knowledge_dir / "README.md"
        with open(readme_path, 'w', encoding='utf-8') as f:
            f.write(readme_content)

        print(f"✅ Created knowledge repository structure:")
        for category in categories:
            print(f"   📁 {category}/")
        print(f"📄 README.md")

    def _import_markdown_file(self, file_path: Path) -> bool:
        """Import a single markdown file"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

            # Extract metadata
            title, folder, tags = self._extract_metadata(content, file_path)

            # Generate unique ID (just filename for flat structure)
            doc_id = file_path.name

            # Count words
            word_count = len(content.split())

            # Store in database
            self.conn.execute('''
                INSERT INTO knowledge
                (id, title, content, folder, tags, source_file, word_count, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (doc_id, title, content, folder, json.dumps(tags), str(file_path),
                   word_count, datetime.now().isoformat(), datetime.now().isoformat()))

            # Update FTS index
            rowid = self.conn.execute('SELECT rowid FROM knowledge WHERE id = ?', (doc_id,)).fetchone()[0]
            tags_search = ' '.join(tags) if tags else ''

            self.conn.execute('''
                INSERT OR REPLACE INTO knowledge_fts
                (rowid, content, title, folder, tags)
                VALUES (?, ?, ?, ?, ?)
            ''', (rowid, content, title, folder, tags_search))

            # Extract relations
            self._extract_relations(doc_id, content)

            self.conn.commit()
            return True

        except Exception as e:
            print(f"❌ Error importing {file_path.name}: {e}")
            return False

    def _extract_metadata(self, content: str, file_path: Path) -> Tuple[str, str, List[str]]:
        """Extract metadata from markdown content with YAML frontmatter support"""
        # Default values
        title = file_path.stem.replace('-', ' ').replace('_', ' ').title()
        folder = ""
        tags = []

        # Check for YAML frontmatter
        if content.startswith('---\n'):
            try:
                # Parse YAML frontmatter
                frontmatter_end = content.find('\n---\n', 4)
                if frontmatter_end != -1:
                    frontmatter_content = content[4:frontmatter_end]
                    body_content = content[frontmatter_end + 5:]  # Skip past frontmatter

                    # Simple YAML parsing (basic key-value extraction)
                    for line in frontmatter_content.split('\n'):
                        line = line.strip()
                        if ':' in line:
                            key, value = line.split(':', 1)
                            key = key.strip()
                            value = value.strip()

                            if key == 'title':
                                title = value.strip('"\'')
                            elif key == 'category':
                                folder = value.strip()
                            elif key == 'tags':
                                # Parse tags array format: [tag1, tag2, tag3]
                                if value.startswith('[') and value.endswith(']'):
                                    tags_str = value[1:-1]
                                    tags = [tag.strip().strip('"\'') for tag in tags_str.split(',') if tag.strip()]
                                else:
                                    tags = [value.strip()]
                else:
                    body_content = content
            except:
                # If frontmatter parsing fails, use original content
                body_content = content
        else:
            body_content = content

        # If no title from frontmatter, extract from first # heading
        if title == file_path.stem.replace('-', ' ').replace('_', ' ').title():
            lines = body_content.split('\n')
            for line in lines[:10]:
                if line.startswith('# '):
                    title = line[2:].strip()
                    break

        # If still no folder, try to determine from filename/content
        if not folder:
            filename_lower = file_path.name.lower()
            content_lower = content.lower()

            if any(term in filename_lower or term in content_lower for term in ['tca', 'reducer', 'state', 'scope', 'pointfree']):
                folder = 'tca'
            elif any(term in filename_lower or term in content_lower for term in ['swiftui', 'stateobject', 'observedobject', '@state']):
                folder = 'swiftui'
            elif any(term in filename_lower or term in content_lower for term in ['visionos', 'spatial', 'realitykit', 'shareplay', 'arkit']):
                folder = 'visionos'
            elif any(term in filename_lower or term in content_lower for term in ['smith', 'agent', 'maxwell', 'skill']):
                folder = 'smith'
            elif any(term in filename_lower or term in content_lower for term in ['error', 'compilation', 'debug', 'fix']):
                folder = 'errors'
            elif any(term in filename_lower or term in content_lower for term in ['architecture', 'pattern', 'design', 'module']):
                folder = 'architecture'
            elif any(term in filename_lower or term in content_lower for term in ['ios', 'macos', 'ipados', 'platform']):
                folder = 'platform-specific'
            else:
                folder = 'general'

        # If still no tags, extract from content (fallback)
        if not tags:
            tag_patterns = [
                r'#swiftui', r'#tca', r'#ios', r'#macos', r'#visionos', r'#ipados',
                r'#stateobject', r'#observedobject', r'#shared', r'#reducer',
                r'#compilation', r'#error', r'#fix', r'#solution', r'#pattern',
                r'#architecture', r'#performance', r'#memory', r'#debugging',
                r'#swift', r'#xcode', r'#testing', r'#navigation', r'#state'
            ]

            for pattern in tag_patterns:
                if re.search(pattern, content, re.IGNORECASE):
                    tag = pattern.replace('#', '')
                    if tag not in tags:
                        tags.append(tag)

        return title, folder, tags

    def _extract_relations(self, doc_id: str, content: str):
        """Extract cross-references from content"""
        self.conn.execute('DELETE FROM relations WHERE source_id = ?', (doc_id,))

        # Find wiki-style links
        wiki_links = re.findall(r'\[\[([^\]]+)\]\]', content)
        for link_title in wiki_links:
            target_id = self._find_document_by_title(link_title)
            if target_id:
                self.conn.execute('''
                    INSERT INTO relations (source_id, target_id, relation_type, created_at)
                    VALUES (?, ?, ?, ?)
                ''', (doc_id, target_id, 'wiki_link', datetime.now().isoformat()))

    def _find_document_by_title(self, title: str) -> Optional[str]:
        """Find document ID by title"""
        cursor = self.conn.execute('SELECT id FROM knowledge WHERE title LIKE ?', (f'%{title}%',))
        row = cursor.fetchone()
        return row[0] if row else None

    # === CORE AGENT METHODS ===

    def solve_developer_problem(self, query: str) -> Dict:
        """Main entry point for developer problems"""
        self.stats['total_queries'] += 1
        start_time = datetime.now()

        print(f"\n🔍 Maxwell solving: '{query}'")

        # Check cache first
        cache_key = self._get_cache_key(query)
        if cache_key in self.cache:
            self.stats['cache_hits'] += 1
            cached_result = self.cache[cache_key]
            print(f"📚 Cache hit: {cached_result['status']}")

            return {
                'status': cached_result['status'],
                'solution': cached_result['solution'],
                'source': cached_result['source'],
                'response_time': cached_result['response_time'],
                'reasoning': cached_result['reasoning']
            }

        # Search knowledge base
        kb_results = self._search_knowledge(query, limit=5)
        search_time = (datetime.now() - start_time).total_seconds()

        print(f"📚 Knowledge search: {len(kb_results)} results ({search_time:.3f}s)")

        # Process results
        if kb_results:
            self.stats['kb_hits'] += 1
            best_match = kb_results[0]

            print(f"✅ Using knowledge: {best_match['title']}")

            result = {
                'status': 'knowledge_found',
                'solution': best_match['content'],
                'source': best_match['title'],
                'response_time': search_time,
                'reasoning': 'Found relevant solution in knowledge base',
                'tags': best_match.get('tags', [])
            }
        else:
            print(f"🤖 No knowledge match - reasoning from first principles")

            result = {
                'status': 'reasoning_required',
                'solution': self._reason_about_problem(query),
                'source': 'general_reasoning',
                'response_time': search_time,
                'reasoning': 'Applied general development principles and best practices'
            }

        # Cache result
        self._cache_result(cache_key, result)

        # Track performance
        total_time = (datetime.now() - start_time).total_seconds()
        self.stats['response_times'].append(total_time)

        return result

    def _search_knowledge(self, query: str, limit: int = 5) -> List[Dict]:
        """Search knowledge base with FTS5"""
        # Remove special characters that break FTS5 syntax
        clean_query = query.replace('@', ' ').replace(':', ' ').replace('(', ' ').replace(')', ' ').replace('.', ' ')

        cursor = self.conn.execute('''
            SELECT knowledge.id, knowledge.title, knowledge.content, knowledge.folder, knowledge.tags,
                   snippet(knowledge_fts, 1, '🔸', '🔹', '...', 100) as snippet
            FROM knowledge_fts
            JOIN knowledge ON knowledge.rowid = knowledge_fts.rowid
            WHERE knowledge_fts MATCH ?
            ORDER BY bm25(knowledge_fts)
            LIMIT ?
        ''', (clean_query, limit))

        results = []
        for row in cursor.fetchall():
            results.append({
                'id': row[0],
                'title': row[1],
                'content': row[2],
                'folder': row[3],
                'tags': json.loads(row[4]) if row[4] else [],
                'snippet': row[5]
            })

        return results

    def _reason_about_problem(self, query: str) -> str:
        """General reasoning about development problems"""
        query_lower = query.lower()

        # Pattern-based reasoning
        if 'error' in query_lower or 'compilation' in query_lower:
            return '''When encountering compilation errors:

1. Check syntax and import statements
2. Verify property declarations
3. Look for type mismatches
4. Check for deprecated APIs
5. Use Xcode's Fix-It suggestions

Common Swift compilation errors:
- "Cannot find in scope" → Check imports and declarations
- "Type cannot conform" → Implement protocol requirements
- "Unexpectedly found nil" → Check optional initialization'''

        elif 'memory' in query_lower or 'leak' in query_lower:
            return '''For memory-related issues in iOS/macOS:

1. Check for strong reference cycles (delegates, closures)
2. Use weak references where appropriate
3. Verify object lifecycles
4. Monitor memory usage with Instruments
5. Use @StateObject vs @ObservedObject correctly

SwiftUI-specific:
- @StateObject: Creates and owns the object
- @ObservedObject: Only observes, doesn't own
- @EnvironmentObject: For shared state across views'''

        elif 'tca' in query_lower or 'reducer' in query_lower:
            return '''For TCA-related issues:

1. Check TCA version compatibility
2. Verify @ObservableState usage
3. Review dependency injection
4. Check action handling
5. Test state mutations

Common TCA patterns:
- Use Scope() for child features
- @Shared for shared state between features
- @ObservableState for local state
- Proper action handling in reduce()'''

        else:
            return '''For general development issues:

1. Identify the specific problem symptoms
2. Break down the issue into smaller components
3. Research current best practices
4. Test solutions incrementally
5. Consider platform-specific constraints

Debugging approach:
- Start with minimal reproduction
- Add logging to identify failure points
- Use debugger breakpoints strategically
- Test edge cases separately'''

    def get_knowledge_stats(self) -> Dict:
        """Get knowledge base statistics"""
        total_docs = self.conn.execute('SELECT COUNT(*) FROM knowledge').fetchone()[0]
        total_words = self.conn.execute('SELECT SUM(word_count) FROM knowledge').fetchone()[0] or 0

        folders = self.conn.execute('SELECT DISTINCT folder FROM knowledge').fetchall()
        all_tags = []
        for row in self.conn.execute('SELECT DISTINCT tags FROM knowledge WHERE tags IS NOT NULL'):
            if row[0]:
                all_tags.extend(json.loads(row[0]))

        return {
            'total_documents': total_docs,
            'total_words': total_words,
            'unique_folders': len([f[0] for f in folders if f[0]]),
            'unique_tags': len(set(all_tags)),
            'folders': [f[0] for f in folders if f[0]],
            'tags': list(set(all_tags))
        }

    def update_knowledge_base(self):
        """Update knowledge base from repository"""
        print("🔄 Updating knowledge base...")

        # Clear existing data
        self.conn.execute('DELETE FROM knowledge')
        self.conn.execute('DELETE FROM knowledge_fts')
        self.conn.execute('DELETE FROM relations')

        # Re-import from knowledge repository
        self._import_knowledge_content()

        print("✅ Knowledge base updated successfully")

    def _get_cache_key(self, query: str) -> str:
        """Generate cache key for query"""
        return hashlib.md5(query.encode()).hexdigest()

    def _cache_result(self, key: str, result: Dict):
        """Cache a result"""
        if len(self.cache) >= self.cache_limit:
            # Remove oldest entry
            oldest_key = next(iter(self.cache))
            del self.cache[oldest_key]

        self.cache[key] = result

# === CLI Interface ===

def main():
    """CLI interface for testing"""
    print("🧠 MAXWELL KNOWLEDGE BASE")
    print("=" * 50)

    # Initialize knowledge base
    kb = MaxwellKnowledgeBase()

    # Handle command line arguments
    if len(sys.argv) > 1:
        if sys.argv[1] == '--update':
            kb.update_knowledge_base()
        elif sys.argv[1] == '--stats':
            kb_stats = kb.get_knowledge_stats()
            print(f"\n📊 Knowledge Base Stats:")
            print(f"   Documents: {kb_stats['total_documents']}")
            print(f"   Total words: {kb_stats['total_words']:,}")
            print(f"   Folders: {kb_stats['unique_folders']}")
            print(f"   Tags: {kb_stats['unique_tags']}")
        else:
            # Test with provided query
            test_query = ' '.join(sys.argv[1:])
            print(f"\n🧪 Testing with: '{test_query}'")
            result = kb.solve_developer_problem(test_query)

            print(f"\n📊 Result:")
            print(f"   Status: {result['status']}")
            print(f"   Source: {result.get('source', 'N/A')}")
            print(f"   Response time: {result['response_time']:.3f}s")
            print(f"   Reasoning: {result['reasoning']}")

            if result['status'] == 'knowledge_found':
                print(f"   Tags: {', '.join(result.get('tags', []))}")
    else:
        # Show stats and usage
        kb_stats = kb.get_knowledge_stats()
        print(f"\n📚 Knowledge Base Stats:")
        print(f"   Documents: {kb_stats['total_documents']}")
        print(f"   Total words: {kb_stats['total_words']:,}")
        print(f"   Folders: {kb_stats['unique_folders']}")
        print(f"   Tags: {kb_stats['unique_tags']}")

        print(f"\n✅ Maxwell knowledge base ready!")
        print(f"\nUsage:")
        print(f"  python3 {sys.argv[0]} 'your query here'  # Test query")
        print(f"  python3 {sys.argv[0]} --update          # Update knowledge base")
        print(f"  python3 {sys.argv[0]} --stats           # Show statistics")

if __name__ == "__main__":
    main()