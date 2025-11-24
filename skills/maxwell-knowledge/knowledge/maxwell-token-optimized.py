#!/usr/bin/env python3
"""
MAXWELL TOKEN-OPTIMIZED KNOWLEDGE BASE
Progressive disclosure system for efficient token usage
First-line answers → Progressive details → On-demand expansion
"""

import sqlite3
import json
import sys
import os
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Optional

class MaxwellTokenOptimized:
    """Token-optimized knowledge base with progressive disclosure"""

    def __init__(self):
        self.db_dir = Path.home() / ".claude" / "resources" / "databases"
        self.db_path = self.db_dir / "maxwell.db"
        self.conn = sqlite3.connect(self.db_path)

    def search(self, query: str, max_tokens: int = 500, detail_level: str = "summary") -> Dict:
        """Token-optimized search with progressive disclosure"""
        start_time = datetime.now()

        print(f"🔍 Maxwell solving: '{query}'")

        # Step 1: Pattern search (highest value, lowest tokens)
        pattern_results = self._search_patterns(query, limit=3)
        if pattern_results:
            best_match = pattern_results[0]
            response_time = (datetime.now() - start_time).total_seconds()

            if detail_level == "summary":
                return {
                    'status': 'pattern_found',
                    'summary': self._create_summary(best_match),
                    'source': best_match['title'],
                    'response_time': response_time,
                    'reasoning': 'Found pattern in first-line defense',
                    'tags': json.loads(best_match.get('tags', '[]')),
                    'knowledge_type': 'pattern',
                    'has_more_details': True,
                    'detail_available': ['key_points', 'code_examples', 'full_pattern']
                }
            elif detail_level == "details":
                return {
                    'status': 'pattern_found',
                    'summary': self._create_summary(best_match),
                    'key_points': self._extract_key_points(best_match),
                    'source': best_match['title'],
                    'response_time': response_time,
                    'reasoning': 'Found pattern with key points',
                    'tags': json.loads(best_match.get('tags', '[]')),
                    'knowledge_type': 'pattern'
                }
            elif detail_level == "full":
                return {
                    'status': 'pattern_found',
                    'summary': self._create_summary(best_match),
                    'key_points': self._extract_key_points(best_match),
                    'code_examples': self._extract_code_examples(best_match),
                    'solution': self._create_detailed_solution(best_match),
                    'source': best_match['title'],
                    'response_time': response_time,
                    'reasoning': 'Complete pattern details provided',
                    'tags': json.loads(best_match.get('tags', '[]')),
                    'knowledge_type': 'pattern'
                }

        # Step 2: Reference search (comprehensive coverage)
        reference_results = self._search_reference(query, limit=3)
        if reference_results:
            best_match = reference_results[0]
            response_time = (datetime.now() - start_time).total_seconds()

            if detail_level == "summary":
                return {
                    'status': 'reference_found',
                    'summary': best_match.get('summary', best_match['title']),
                    'source': best_match['title'],
                    'response_time': response_time,
                    'reasoning': f"Found {best_match['library']} reference documentation",
                    'tags': json.loads(best_match.get('tags', '[]')),
                    'library': best_match['library'],
                    'folder_path': best_match['folder_path'],
                    'knowledge_type': 'reference',
                    'has_more_details': True,
                    'detail_available': ['full_content', 'section_highlights']
                }
            elif detail_level == "full":
                return {
                    'status': 'reference_found',
                    'summary': best_match.get('summary', best_match['title']),
                    'content_preview': self._extract_content_preview(best_match),
                    'source': best_match['title'],
                    'response_time': response_time,
                    'reasoning': f"Found {best_match['library']} reference documentation",
                    'tags': json.loads(best_match.get('tags', '[]')),
                    'library': best_match['library'],
                    'folder_path': best_match['folder_path'],
                    'knowledge_type': 'reference',
                    'has_more_details': True,
                    'detail_available': ['full_content']
                }

        # Step 3: No results
        response_time = (datetime.now() - start_time).total_seconds()
        return {
            'status': 'no_knowledge_found',
            'summary': None,
            'source': None,
            'response_time': response_time,
            'reasoning': 'No relevant information found in knowledge base',
            'knowledge_type': 'none',
            'has_more_details': False
        }

    def _search_patterns(self, query: str, limit: int = 3) -> List[Dict]:
        """Search patterns table with token efficiency focus"""
        try:
            self.conn.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='patterns_fts'")

            cursor = self.conn.execute('''
                SELECT p.id, p.title, p.content, p.tags,
                       snippet(patterns_fts, 1, '🔸', '🔹', '...', 50) as snippet
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
                    'tags': row[3],
                    'snippet': row[4]
                })
            return results

        except sqlite3.OperationalError:
            return []

    def _search_reference(self, query: str, limit: int = 3) -> List[Dict]:
        """Search reference table with token efficiency focus"""
        try:
            self.conn.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='reference_fts'")

            cursor = self.conn.execute('''
                SELECT r.id, r.title, r.summary, r.library, r.folder_path, r.tags,
                       snippet(reference_fts, 1, '🔸', '🔹', '...', 40) as snippet
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
                    'summary': row[2],
                    'library': row[3],
                    'folder_path': row[4],
                    'tags': row[5],
                    'snippet': row[6]
                })
            return results

        except sqlite3.OperationalError:
            return []

    def _create_summary(self, result: Dict) -> str:
        """Create token-efficient summary from pattern or reference"""
        title = result.get('title', 'Unknown')
        tags = json.loads(result.get('tags', '[]'))

        # Create concise summary
        if 'sql' in ' '.join(tags).lower():
            return f"SQL {title}: Database query pattern for {', '.join(tags[:3])}"
        elif 'migration' in ' '.join(tags).lower():
            return f"Migration: {title} - Steps for {', '.join(tags[:3])}"
        elif 'performance' in ' '.join(tags).lower():
            return f"Performance: {title} - Optimizes {', '.join(tags[:3])}"
        else:
            return f"Pattern: {title} - Covers {', '.join(tags[:3])}"

    def _extract_key_points(self, result: Dict) -> List[str]:
        """Extract key points with minimal tokens"""
        content = result.get('content', '')
        key_points = []

        # Look for numbered lists, bullet points
        lines = content.split('\n')
        for line in lines[:20]:  # Limit to first 20 lines
            line = line.strip()
            if line.startswith(('1.', '2.', '3.', '•', '-')):
                # Truncate long lines
                if len(line) > 80:
                    line = line[:77] + "..."
                key_points.append(line)
            elif line.startswith(('Problem:', 'Solution:', 'Key Points:')):
                key_points.append(line)

        return key_points[:5]  # Limit to 5 points

    def _extract_code_examples(self, result: Dict) -> List[str]:
        """Extract brief code examples"""
        content = result.get('content', '')

        # Find code blocks and make them concise
        import re
        code_blocks = re.findall(r'```swift\n(.*?)\n```', content, re.DOTALL)

        concise_examples = []
        for block in code_blocks[:3]:  # Limit to 3 examples
            if len(block) > 200:
                # Show first few lines
                lines = block.split('\n')[:3]
                concise_examples.append('\n'.join(lines) + '\n...')
            else:
                concise_examples.append(block)

        return concise_examples

    def _extract_content_preview(self, result: Dict) -> str:
        """Extract brief content preview"""
        content = result.get('content', '')

        # Remove code blocks for text preview
        import re
        text_only = re.sub(r'```.*?```', '', content, flags=re.DOTALL)
        text_only = re.sub(r'#+', '', text_only)

        # First paragraph or first 150 characters
        paragraphs = [p.strip() for p in text_only.split('\n\n') if p.strip()]

        if paragraphs:
            return paragraphs[0][:150] + ("..." if len(paragraphs[0]) > 150 else "")
        else:
            return text_only[:150] + ("..." if len(text_only) > 150 else "")

    def _create_detailed_solution(self, result: Dict) -> str:
        """Create detailed solution (only when explicitly requested)"""
        title = result.get('title', 'Unknown Pattern')
        content = result.get('content', '')

        # Extract key sections
        key_points = self._extract_key_points(result)
        code_examples = self._extract_code_examples(result)

        solution = f"**{title}**\n\n"

        if key_points:
            solution += "**Key Points:**\n"
            for point in key_points:
                solution += f"• {point}\n"
            solution += "\n"

        if code_examples:
            solution += "**Code Examples:**\n"
            for example in code_examples:
                solution += f"```swift\n{example}\n``\n"

        return solution

    def expand_details(self, query: str, detail_type: str, source_id: str) -> Dict:
        """Progressive disclosure expansion for specific detail types"""
        if detail_type == "key_points":
            # Get more detailed key points
            if source_id.startswith(('sqlitedata-', 'structured-queries-')):
                pattern_result = self._get_pattern_by_id(source_id)
                if pattern_result:
                    key_points = self._extract_detailed_key_points(pattern_result)
                    return {
                        'detail_type': 'key_points',
                        'content': key_points,
                        'source_id': source_id
                    }

        elif detail_type == "code_examples":
            # Get more code examples
            if source_id.startswith(('sqlitedata-', 'structured-queries-')):
                pattern_result = self._get_pattern_by_id(source_id)
                if pattern_result:
                    code_examples = self._extract_code_examples(pattern_result)
                    return {
                        'detail_type': 'code_examples',
                        'content': code_examples,
                        'source_id': source_id
                    }

        elif detail_type == "full_content":
            # Get full reference content
            reference_result = self._get_reference_by_id(source_id)
            if reference_result:
                return {
                    'detail_type': 'full_content',
                    'content': reference_result.get('content', ''),
                    'source_id': source_id
                }

        return {'detail_type': detail_type, 'content': None, 'error': 'Detail not found'}

    def _get_pattern_by_id(self, pattern_id: str) -> Dict:
        """Get pattern by ID"""
        cursor = self.conn.execute('SELECT * FROM patterns WHERE id = ?', (pattern_id,))
        row = cursor.fetchone()
        if row:
            return {
                'id': row[0],
                'title': row[1],
                'content': row[2],
                'tags': row[3]
            }
        return None

    def _get_reference_by_id(self, reference_id: str) -> Dict:
        """Get reference by ID"""
        cursor = self.conn.execute('SELECT id, title, content, library, folder_path FROM reference WHERE id = ?', (reference_id,))
        row = cursor.fetchone()
        if row:
            return {
                'id': row[0],
                'title': row[1],
                'content': row[2],
                'library': row[3],
                'folder_path': row[4]
            }
        return None

    def _extract_detailed_key_points(self, result: Dict) -> List[str]:
        """Extract more detailed key points"""
        content = result.get('content', '')
        key_points = []

        # Look for comprehensive sections
        lines = content.split('\n')
        for line in lines:
            line = line.strip()
            # More comprehensive key point detection
            if (line.startswith(('##', '###')) or
                line.lower().startswith(('note:', 'important:', 'remember:', 'consider:')) or
                (line.startswith(('1.', '2.', '3.', '4.', '5.', '6.', '7.', '8.', '9.')) and len(line) < 100)):
                key_points.append(line)

        return key_points[:10]  # More detailed but still limited

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 maxwell-token-optimized.py '<search query>' [summary|details|full]")
        print("       python3 maxwell-token-optimized.py --stats")
        return 1

    query = sys.argv[1]
    detail_level = sys.argv[2] if len(sys.argv) > 2 else "summary"

    kb = MaxwellTokenOptimized()
    result = kb.search(query, detail_level=detail_level)

    print(f"🧠 MAXWELL TOKEN-OPTIMIZED")
    print("=" * 40)
    print(f"🧪 Query: '{query}' (detail: {detail_level})")
    print(f"⏱️ Response time: {result['response_time']:.3f}s")

    if result['status'] in ['pattern_found', 'reference_found']:
        print(f"✅ {result['status'].replace('_', ' ').title()}:")
        print(f"   Source: {result['source']}")
        print(f"   Reasoning: {result['reasoning']}")
        if 'tags' in result and result['tags']:
            print(f"   Tags: {', '.join(result['tags'][:5])}")
        if result.get('library'):
            print(f"   Library: {result['library']}")
        print()

        print("💡 Summary:")
        print(result['summary'])

        if result.get('has_more_details'):
            print()
            print("📖 Available details:")
            print(f"   • {', '.join(result['detail_available'])}")
            print("   Use 'expand <detail_type>' for more information")

        # Show additional details based on level
        if detail_level == "details" and result.get('key_points'):
            print()
            print("🔑 Key Points:")
            for point in result['key_points']:
                print(f"   • {point}")

        elif detail_level == "full":
            if result.get('key_points'):
                print()
                print("🔑 Key Points:")
                for point in result['key_points']:
                    print(f"   • {point}")

            if result.get('code_examples'):
                print()
                print("💻 Code Examples:")
                for i, example in enumerate(result['code_examples'], 1):
                    print(f"   Example {i}:")
                    print(f"```swift")
                    print(f"{example}")
                    print(f"```")

    else:
        print("❌ No knowledge found")
        print(f"   {result['reasoning']}")
        print(f"   Consider: General reasoning or alternative search terms")

    return 0

if __name__ == '__main__':
    exit(main())