#!/usr/bin/env python3
"""
MAXWELL HYBRID KNOWLEDGE BASE
Enhanced search with patterns (high precision) + reference (comprehensive coverage)
Supports folder-based organization and human-friendly summaries
"""

import sqlite3
import json
import sys
import os
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Optional

class MaxwellHybridKnowledgeBase:
    """Hybrid knowledge base with pattern-first search and reference fallback"""

    def __init__(self):
        self.db_dir = Path.home() / ".claude" / "resources" / "databases"
        self.db_dir.mkdir(parents=True, exist_ok=True)
        self.db_path = self.db_dir / "maxwell.db"
        self.conn = sqlite3.connect(self.db_path)
        self.stats = {
            'total_queries': 0,
            'pattern_hits': 0,
            'reference_hits': 0,
            'response_times': []
        }

    def search(self, query: str, limit: int = 5) -> Dict:
        """Hybrid search: patterns first, then reference fallback"""
        start_time = datetime.now()
        self.stats['total_queries'] += 1

        print(f"🔍 Maxwell solving: '{query}'")

        # Step 1: Search patterns (high precision, problem-solution focused)
        pattern_results = self._search_patterns(query, limit)
        if pattern_results:
            self.stats['pattern_hits'] += 1
            response_time = (datetime.now() - start_time).total_seconds()
            self.stats['response_times'].append(response_time)

            return {
                'status': 'pattern_found',
                'solution': self._format_pattern_response(pattern_results[0]),
                'source': pattern_results[0]['title'],
                'response_time': response_time,
                'reasoning': 'Found relevant solution in Maxwell patterns database',
                'tags': json.loads(pattern_results[0].get('tags', '[]')),
                'knowledge_type': 'pattern'
            }

        # Step 2: Search reference documentation (comprehensive coverage)
        reference_results = self._search_reference(query, limit)
        if reference_results:
            self.stats['reference_hits'] += 1
            response_time = (datetime.now() - start_time).total_seconds()
            self.stats['response_times'].append(response_time)

            result = reference_results[0]
            return {
                'status': 'reference_found',
                'solution': self._format_reference_response(result),
                'source': result['title'],
                'response_time': response_time,
                'reasoning': f"Found comprehensive reference in {result['library']} documentation",
                'tags': json.loads(result.get('tags', '[]')),
                'folder_path': result['folder_path'],
                'library': result['library'],
                'knowledge_type': 'reference'
            }

        # Step 3: No results found
        response_time = (datetime.now() - start_time).total_seconds()
        return {
            'status': 'no_knowledge_found',
            'solution': None,
            'source': None,
            'response_time': response_time,
            'reasoning': 'No relevant information found in Maxwell knowledge base',
            'knowledge_type': 'none'
        }

    def _search_patterns(self, query: str, limit: int = 5) -> List[Dict]:
        """Search patterns table with FTS5"""
        try:
            # Check if patterns_fts exists
            self.conn.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='patterns_fts'")

            # Search patterns FTS
            cursor = self.conn.execute('''
                SELECT p.id, p.title, p.content, p.folder, p.tags,
                       snippet(patterns_fts, 1, '🔸', '🔹', '...', 100) as snippet
                FROM patterns_fts
                JOIN patterns p ON p.rowid = patterns_fts.rowid
                WHERE patterns_fts MATCH ?
                ORDER BY bm25(patterns_fts)
                LIMIT ?
            ''', (query, limit))

            results = []
            for row in cursor.fetchall():
                results.append({
                    'id': row[0],
                    'title': row[1],
                    'content': row[2],
                    'folder': row[3],
                    'tags': row[4],
                    'snippet': row[5]
                })
            return results

        except sqlite3.OperationalError:
            # Fallback to legacy table structure
            cursor = self.conn.execute('''
                SELECT id, title, content, folder, tags
                FROM knowledge
                WHERE knowledge_fts MATCH ?
                ORDER BY bm25(knowledge_fts)
                LIMIT ?
            ''', (query, limit))
            results = []
            for row in cursor.fetchall():
                results.append({
                    'id': row[0],
                    'title': row[1],
                    'content': row[2],
                    'folder': row[3],
                    'tags': row[4]
                })
            return results

    def _search_reference(self, query: str, limit: int = 5) -> List[Dict]:
        """Search reference table with FTS5"""
        try:
            # Check if reference_fts exists
            self.conn.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='reference_fts'")

            cursor = self.conn.execute('''
                SELECT r.id, r.title, r.content, r.folder_path, r.library,
                       r.doc_type, r.summary, r.tags,
                       snippet(reference_fts, 1, '🔸', '🔹', '...', 150) as snippet
                FROM reference_fts
                JOIN reference r ON r.rowid = reference_fts.rowid
                WHERE reference_fts MATCH ?
                ORDER BY bm25(reference_fts)
                LIMIT ?
            ''', (query, limit))

            results = []
            for row in cursor.fetchall():
                results.append({
                    'id': row[0],
                    'title': row[1],
                    'content': row[2],
                    'folder_path': row[3],
                    'library': row[4],
                    'doc_type': row[5],
                    'summary': row[6],
                    'tags': row[7],
                    'snippet': row[8]
                })
            return results

        except sqlite3.OperationalError:
            # Reference table not yet created
            return []

    def _format_pattern_response(self, result: Dict) -> str:
        """Format pattern result with problem-solution focus"""
        title = result.get('title', 'Unknown Pattern')
        content = result.get('content', '')
        tags = json.loads(result.get('tags', '[]'))

        # Extract key insights from pattern content
        lines = content.split('\n')
        problem = ""
        solution = ""
        key_points = []

        current_section = None
        for line in lines:
            line = line.strip()
            if line.lower().startswith('## problem') or line.lower().startswith('# problem'):
                current_section = 'problem'
                problem = line.split(':', 1)[-1].strip() if ':' in line else ''
            elif line.lower().startswith('## solution') or line.lower().startswith('# solution'):
                current_section = 'solution'
                solution = line.split(':', 1)[-1].strip() if ':' in line else ''
            elif line.startswith('-') and current_section:
                point = line[1:].strip()
                if point:
                    key_points.append(point)
            elif line.startswith('```') and solution and not key_points:
                # Code block after solution heading
                key_points.append(line)

        response = f"**{title}**\n\n"

        if problem:
            response += f"**Problem:** {problem}\n\n"

        if solution:
            response += f"**Solution:** {solution}\n\n"

        if key_points:
            response += "**Key Points:**\n"
            for i, point in enumerate(key_points[:5], 1):  # Limit to 5 points
                if point.startswith('```'):
                    response += f"{point}\n"
                else:
                    response += f"{i}. {point}\n"
            response += "\n"

        # Add reference link for more details
        response += f"*Pattern from Maxwell knowledge base with tags: {', '.join(tags[:5])}*"

        return response

    def _format_reference_response(self, result: Dict) -> str:
        """Format reference result with human-friendly summary"""
        title = result.get('title', 'Unknown Reference')
        summary = result.get('summary', '')
        library = result.get('library', 'Unknown Library')
        folder_path = result.get('folder_path', 'root')
        doc_type = result.get('doc_type', 'documentation')
        tags = json.loads(result.get('tags', '[]'))

        response = f"**{title}**\n\n"

        # Use the pre-generated summary for first line
        if summary:
            response += f"**Summary:** {summary}\n\n"

        # Add context information
        response += f"**Source:** {library} Documentation ({doc_type.title()})\n"
        response += f"**Location:** {folder_path}\n\n"

        # Add relevant tags
        if tags:
            response += f"**Topics:** {', '.join(tags[:8])}\n\n"

        # Add reference pointer for deeper exploration
        response += f"*For complete implementation details, see the full {library} documentation.*"

        return response

    def get_statistics(self) -> Dict:
        """Get comprehensive database statistics"""
        try:
            # Pattern statistics
            pattern_count = 0
            pattern_words = 0
            try:
                pattern_count = self.conn.execute('SELECT COUNT(*) FROM patterns').fetchone()[0]
                pattern_words = self.conn.execute('SELECT SUM(word_count) FROM patterns').fetchone()[0] or 0
            except sqlite3.OperationalError:
                # Legacy structure
                pattern_count = self.conn.execute('SELECT COUNT(*) FROM knowledge').fetchone()[0]
                pattern_words = self.conn.execute('SELECT SUM(word_count) FROM knowledge').fetchone()[0] or 0

            # Reference statistics
            reference_count = 0
            reference_words = 0
            libraries = {}
            try:
                reference_count = self.conn.execute('SELECT COUNT(*) FROM reference').fetchone()[0]
                reference_words = self.conn.execute('SELECT SUM(word_count) FROM reference').fetchone()[0] or 0
                library_rows = self.conn.execute('SELECT library, COUNT(*) FROM reference GROUP BY library').fetchall()
                libraries = dict(library_rows)
            except sqlite3.OperationalError:
                pass

            # Performance statistics
            avg_response_time = sum(self.stats['response_times']) / len(self.stats['response_times']) if self.stats['response_times'] else 0

            stats = {
                'patterns': {'count': pattern_count, 'words': pattern_words},
                'reference': {'count': reference_count, 'words': reference_words},
                'libraries': libraries,
                'total_documents': pattern_count + reference_count,
                'total_words': pattern_words + reference_words,
                'performance': {
                    'total_queries': self.stats['total_queries'],
                    'pattern_hits': self.stats['pattern_hits'],
                    'reference_hits': self.stats['reference_hits'],
                    'avg_response_time_ms': avg_response_time * 1000
                }
            }

            return stats

        except Exception as e:
            return {'error': str(e)}

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 maxwell-hybrid-search.py '<search query>'")
        print("       python3 maxwell-hybrid-search.py --stats")
        return 1

    # Stats mode
    if sys.argv[1] == '--stats':
        kb = MaxwellHybridKnowledgeBase()
        stats = kb.get_statistics()

        print("🧠 MAXWELL HYBRID KNOWLEDGE BASE")
        print("=" * 50)

        if 'error' in stats:
            print(f"❌ Error: {stats['error']}")
            return 1

        print(f"📚 Patterns: {stats['patterns']['count']:,} documents, {stats['patterns']['words']:,} words")
        print(f"📖 Reference: {stats['reference']['count']:,} documents, {stats['reference']['words']:,} words")

        if stats['libraries']:
            print(f"🏛️ Libraries: {', '.join(stats['libraries'].keys())}")
            for library, count in stats['libraries'].items():
                print(f"   • {library}: {count:,} documents")

        print(f"📊 Total: {stats['total_documents']:,} documents, {stats['total_words']:,} words")

        perf = stats['performance']
        if perf['total_queries'] > 0:
            print(f"⚡ Performance: {perf['avg_response_time_time_ms']:.1f}ms avg response time")
            print(f"🎯 Hit Rate: {perf['pattern_hits'] + perf['reference_hits']}/{perf['total_queries']} queries")
        return 0

    # Search mode
    query = ' '.join(sys.argv[1:])
    kb = MaxwellHybridKnowledgeBase()

    result = kb.search(query)

    print(f"🧠 MAXWELL HYBRID KNOWLEDGE BASE")
    print("=" * 50)
    print(f"🧪 Testing with: '{query}'")

    if result['status'] in ['pattern_found', 'reference_found']:
        print(f"📚 Knowledge search: {len(result.get('results', []))} results ({result['response_time']:.3f}s)")
        knowledge_type = result['knowledge_type']
        print(f"✅ Using {knowledge_type}: {result['source']}")
        print()

        print("📊 Result:")
        print(f"   Status: {result['status']}")
        print(f"   Source: {result['source']}")
        print(f"   Response time: {result['response_time']:.3f}s")
        print(f"   Reasoning: {result['reasoning']}")
        if 'tags' in result and result['tags']:
            print(f"   Tags: {', '.join(result['tags'])}")
        if 'library' in result:
            print(f"   Library: {result['library']}")
        if 'folder_path' in result:
            print(f"   Location: {result['folder_path']}")
        print()

        print("💡 Solution:")
        print(result['solution'])

    else:
        print("🤖 No knowledge match - would need general reasoning")
        print()
        print("📊 Result:")
        print(f"   Status: {result['status']}")
        print(f"   Response time: {result['response_time']:.3f}s")
        print(f"   Reasoning: {result['reasoning']}")

    return 0

if __name__ == '__main__':
    exit(main())