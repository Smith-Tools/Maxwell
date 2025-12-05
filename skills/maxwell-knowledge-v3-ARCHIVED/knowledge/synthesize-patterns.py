#!/usr/bin/env python3
"""
SQLiteData Pattern Synthesis
Extract problem-solution patterns from reference documentation
"""

import sqlite3
import re
from pathlib import Path
from typing import List, Dict, Tuple
import json

class SQLiteDataPatternSynthesizer:
    def __init__(self, db_path: str):
        self.conn = sqlite3.connect(db_path)

    def extract_patterns_from_reference(self) -> List[Dict]:
        """Extract high-value patterns from SQLiteData reference documentation"""
        print("🧠 Synthesizing patterns from SQLiteData documentation...")

        # Get all SQLiteData reference documents
        cursor = self.conn.execute('''
            SELECT id, title, content, folder_path, doc_type
            FROM reference
            WHERE library = 'SQLiteData'
        ''')

        synthesized_patterns = []

        for row in cursor.fetchall():
            doc_id, title, content, folder_path, doc_type = row

            # Extract patterns based on document type
            if doc_type == 'article':
                patterns = self._extract_article_patterns(doc_id, title, content, folder_path)
            elif doc_type == 'extension':
                patterns = self._extract_extension_patterns(doc_id, title, content, folder_path)
            else:
                patterns = self._extract_general_patterns(doc_id, title, content, folder_path)

            synthesized_patterns.extend(patterns)

        print(f"✅ Extracted {len(synthesized_patterns)} patterns from SQLiteData documentation")
        return synthesized_patterns

    def _extract_article_patterns(self, doc_id: str, title: str, content: str, folder_path: str) -> List[Dict]:
        """Extract patterns from tutorial/articles"""
        patterns = []

        # Look for problem-solution patterns in articles
        sections = self._split_into_sections(content)

        for section_title, section_content in sections:
            # Look for performance-related patterns
            if any(keyword in section_content.lower() for keyword in ['performance', 'efficient', 'optimize', 'fast', 'slow']):
                pattern = self._create_performance_pattern(
                    f"{title}: {section_title}",
                    section_content,
                    folder_path
                )
                if pattern:
                    patterns.append(pattern)

            # Look for migration patterns
            if any(keyword in section_content.lower() for keyword in ['migration', 'migrate', 'convert', 'upgrade']):
                pattern = self._create_migration_pattern(
                    f"{title}: {section_title}",
                    section_content,
                    folder_path
                )
                if pattern:
                    patterns.append(pattern)

            # Look for best practice patterns
            if any(keyword in section_content.lower() for keyword in ['best practice', 'recommend', 'should', 'avoid']):
                pattern = self._create_best_practice_pattern(
                    f"{title}: {section_title}",
                    section_content,
                    folder_path
                )
                if pattern:
                    patterns.append(pattern)

        return patterns

    def _extract_extension_patterns(self, doc_id: str, title: str, content: str, folder_path: str) -> List[Dict]:
        """Extract API usage patterns from extensions"""
        patterns = []

        # Look for code examples and patterns
        code_blocks = self._extract_code_blocks(content)

        for code_block in code_blocks:
            if 'SQLiteData' in code_block or 'FetchAll' in code_block or 'FetchOne' in code_block:
                pattern = self._create_api_pattern(
                    title,
                    code_block,
                    folder_path
                )
                if pattern:
                    patterns.append(pattern)

        return patterns

    def _extract_general_patterns(self, doc_id: str, title: str, content: str, folder_path: str) -> List[Dict]:
        """Extract general patterns from any document"""
        patterns = []

        # Look for Swift code patterns
        if '```swift' in content:
            pattern = self._create_swift_pattern(title, content, folder_path)
            if pattern:
                patterns.append(pattern)

        return patterns

    def _split_into_sections(self, content: str) -> List[Tuple[str, str]]:
        """Split markdown content into sections"""
        sections = []
        current_section = ""
        current_title = "Introduction"

        lines = content.split('\n')
        for line in lines:
            if line.startswith('##'):
                # Save previous section
                if current_section.strip():
                    sections.append((current_title, current_section.strip()))
                # Start new section
                current_title = line.strip('#').strip()
                current_section = ""
            elif line.startswith('#'):
                # Save previous section
                if current_section.strip():
                    sections.append((current_title, current_section.strip()))
                # Start new section
                current_title = line.strip('#').strip()
                current_section = ""
            else:
                current_section += line + '\n'

        # Save last section
        if current_section.strip():
            sections.append((current_title, current_section.strip()))

        return sections

    def _extract_code_blocks(self, content: str) -> List[str]:
        """Extract code blocks from markdown"""
        code_blocks = []
        lines = content.split('\n')
        in_code_block = False
        current_block = ""

        for line in lines:
            if line.startswith('```'):
                if in_code_block:
                    code_blocks.append(current_block.strip())
                    current_block = ""
                in_code_block = not in_code_block
            elif in_code_block:
                current_block += line + '\n'

        return code_blocks

    def _create_performance_pattern(self, title: str, content: str, folder_path: str) -> Dict:
        """Create a performance optimization pattern"""
        # Look for performance indicators
        performance_indicators = []

        # Extract performance numbers
        numbers = re.findall(r'\d+(?:\.\d+)?x?\s*(?:times?|faster|slower|ms|seconds?)', content)
        if numbers:
            performance_indicators.extend(numbers)

        # Look for problem statements
        problem_match = re.search(r'(?:problem|issue|challenge)[:\s]*([^.\n]+)', content, re.IGNORECASE)
        problem = problem_match.group(1).strip() if problem_match else "Performance optimization needed"

        # Look for solution statements
        solution_match = re.search(r'(?:solution|fix|recommendation)[:\s]*([^.\n]+)', content, re.IGNORECASE)
        solution = solution_match.group(1).strip() if solution_match else "Optimize database queries"

        # Look for code examples
        code_examples = self._extract_code_blocks(content)

        return {
            'id': f"sqlitedata-perf-{hash(title) % 10000}",
            'title': f"Performance Pattern: {title}",
            'problem': problem,
            'solution': solution,
            'pattern_type': 'performance',
            'folder': 'SQLiteData/Performance',
            'tags': ['sqlitedata', 'performance', 'optimization', 'database', 'swift'],
            'content': content,
            'code_examples': code_examples,
            'performance_indicators': performance_indicators,
            'source_document': title,
            'folder_path': folder_path
        }

    def _create_migration_pattern(self, title: str, content: str, folder_path: str) -> Dict:
        """Create a migration pattern"""
        # Look for migration steps
        steps = []
        lines = content.split('\n')
        for i, line in enumerate(lines):
            if re.match(r'^\d+\.', line) or line.strip().startswith('-'):
                steps.append(line.strip())

        return {
            'id': f"sqlitedata-migration-{hash(title) % 10000}",
            'title': f"Migration Pattern: {title}",
            'problem': "Need to migrate existing data or database structure",
            'solution': "Follow systematic migration process with proper validation",
            'pattern_type': 'migration',
            'folder': 'SQLiteData/Migration',
            'tags': ['sqlitedata', 'migration', 'database', 'swift', 'data-migration'],
            'content': content,
            'migration_steps': steps,
            'source_document': title,
            'folder_path': folder_path
        }

    def _create_best_practice_pattern(self, title: str, content: str, folder_path: str) -> Dict:
        """Create a best practice pattern"""
        # Look for dos and don'ts
        dos = []
        donts = []

        lines = content.split('\n')
        for line in lines:
            line = line.strip()
            if line.lower().startswith(('do ', 'use ', 'implement ')):
                dos.append(line)
            elif line.lower().startswith(('don\'t', 'avoid ', 'never ')):
                donts.append(line)

        return {
            'id': f"sqlitedata-best-practice-{hash(title) % 10000}",
            'title': f"Best Practice: {title}",
            'problem': "Need to follow established patterns for reliable implementation",
            'solution': "Apply best practices to avoid common pitfalls",
            'pattern_type': 'best_practice',
            'folder': 'SQLiteData/BestPractices',
            'tags': ['sqlitedata', 'best-practices', 'swift', 'database', 'patterns'],
            'content': content,
            'do_list': dos,
            'dont_list': donts,
            'source_document': title,
            'folder_path': folder_path
        }

    def _create_api_pattern(self, title: str, code_block: str, folder_path: str) -> Dict:
        """Create an API usage pattern"""
        # Extract function/method names
        function_matches = re.findall(r'(?:func|let|var)\s+(\w+)', code_block)
        functions = list(set(function_matches))

        return {
            'id': f"sqlitedata-api-{hash(title) % 10000}",
            'title': f"API Pattern: {title}",
            'problem': f"Need to use {title} correctly",
            'solution': f"Follow proper {title} usage pattern",
            'pattern_type': 'api_usage',
            'folder': 'SQLiteData/API',
            'tags': ['sqlitedata', 'api', 'swift', 'extension', functions[0] if functions else ''],
            'content': code_block,
            'functions_used': functions,
            'source_document': title,
            'folder_path': folder_path
        }

    def _create_swift_pattern(self, title: str, content: str, folder_path: str) -> Dict:
        """Create a general Swift pattern"""
        return {
            'id': f"sqlitedata-swift-{hash(title) % 10000}",
            'title': f"Swift Pattern: {title}",
            'problem': "Need proper Swift implementation",
            'solution': "Follow Swift best practices",
            'pattern_type': 'swift_implementation',
            'folder': 'SQLiteData/Swift',
            'tags': ['sqlitedata', 'swift', 'implementation'],
            'content': content,
            'source_document': title,
            'folder_path': folder_path
        }

    def save_synthesized_patterns(self, patterns: List[Dict]):
        """Save synthesized patterns to the patterns table"""
        print(f"💾 Saving {len(patterns)} synthesized patterns to database...")

        for pattern in patterns:
            # Convert pattern to knowledge format
            content = self._format_pattern_content(pattern)

            self.conn.execute('''
                INSERT OR REPLACE INTO patterns
                (id, title, content, folder, folder_path, doc_type, library, summary, tags, word_count)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                pattern['id'],
                pattern['title'],
                content,
                pattern['folder'],
                pattern['folder_path'],
                'synthesized_pattern',
                'SQLiteData',
                f"{pattern['problem']}: {pattern['solution']}",
                json.dumps(pattern['tags']),
                len(content.split())
            ))

            # Update FTS index
            rowid = self.conn.execute('SELECT last_insert_rowid()').fetchone()[0]
            self.conn.execute('''
                INSERT INTO patterns_fts (rowid, content, title, folder, tags)
                VALUES (?, ?, ?, ?, ?)
            ''', (rowid, content, pattern['title'], pattern['folder'], json.dumps(pattern['tags'])))

        self.conn.commit()
        print("✅ Synthesized patterns saved successfully")

    def _format_pattern_content(self, pattern: Dict) -> str:
        """Format pattern content for database storage"""
        content = f"""# {pattern['title']}

## Problem
{pattern['problem']}

## Solution
{pattern['solution']}

## Pattern Type
{pattern['pattern_type']}

## Tags
{', '.join(pattern['tags'])}

## Source Document
{pattern['source_document']} (Location: {pattern['folder_path']})

"""

        # Add extra content based on pattern type
        if pattern['pattern_type'] == 'performance' and pattern.get('performance_indicators'):
            content += f"\n## Performance Indicators\n{', '.join(pattern['performance_indicators'])}\n"

        if pattern['pattern_type'] == 'migration' and pattern.get('migration_steps'):
            content += f"\n## Migration Steps\n" + '\n'.join(f"- {step}" for step in pattern['migration_steps']) + "\n"

        if pattern['pattern_type'] == 'best_practice':
            if pattern.get('do_list'):
                content += f"\n## Do's\n" + '\n'.join(f"- {item}" for item in pattern['do_list']) + "\n"
            if pattern.get('dont_list'):
                content += f"\n## Don'ts\n" + '\n'.join(f"- {item}" for item in pattern['dont_list']) + "\n"

        if pattern['pattern_type'] == 'api_usage' and pattern.get('functions_used'):
            content += f"\n## Functions Used\n{', '.join(pattern['functions_used'])}\n"

        if pattern.get('code_examples'):
            content += f"\n## Code Examples\n" + '\n\n'.join(f"```swift\n{example}\n```" for example in pattern['code_examples'][:2]) + "\n"

        content += f"\n## Original Content\n{pattern['content'][:1000]}...\n"

        return content

def main():
    db_path = Path.home() / ".claude" / "resources" / "databases" / "maxwell.db"

    if not db_path.exists():
        print(f"❌ Database not found: {db_path}")
        return 1

    synthesizer = SQLiteDataPatternSynthesizer(str(db_path))

    # Extract patterns from SQLiteData documentation
    patterns = synthesizer.extract_patterns_from_reference()

    if patterns:
        # Save synthesized patterns
        synthesizer.save_synthesized_patterns(patterns)

        print(f"\n🎉 Pattern Synthesis Complete!")
        print(f"   📝 Synthesized {len(patterns)} patterns from SQLiteData documentation")
        print(f"   🏷️ Pattern types: performance, migration, best_practice, api_usage, swift_implementation")
        print(f"   💾 Patterns saved to database with pattern-first priority")

        # Show pattern breakdown
        pattern_types = {}
        for pattern in patterns:
            ptype = pattern['pattern_type']
            pattern_types[ptype] = pattern_types.get(ptype, 0) + 1

        print(f"   📊 Pattern breakdown:")
        for ptype, count in pattern_types.items():
            print(f"      • {ptype}: {count} patterns")

    else:
        print("ℹ️ No patterns found to synthesize")

    return 0

if __name__ == '__main__':
    exit(main())