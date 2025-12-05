#!/usr/bin/env python3
"""
Structured Queries Pattern Synthesis
Extract SQL query patterns and best practices from Structured Queries documentation
"""

import sqlite3
import re
from pathlib import Path
from typing import List, Dict, Tuple
import json

class StructuredQueriesPatternSynthesizer:
    def __init__(self, db_path: str):
        self.conn = sqlite3.connect(db_path)

    def extract_patterns_from_structured_queries(self) -> List[Dict]:
        """Extract SQL query patterns from Structured Queries documentation"""
        print("🧠 Synthesizing SQL query patterns from Structured Queries documentation...")

        # Get all Structured Queries reference documents
        cursor = self.conn.execute('''
            SELECT id, title, content, folder_path, doc_type, library
            FROM reference
            WHERE library IN ('StructuredQueries', 'StructuredQueriesCore', 'StructuredQueriesSQLite', 'StructuredQueriesSQLiteCore')
        ''')

        synthesized_patterns = []

        for row in cursor.fetchall():
            doc_id, title, content, folder_path, doc_type, library = row

            # Extract patterns based on content and library type
            if 'Core' in library:
                patterns = self._extract_core_patterns(doc_id, title, content, folder_path, library)
            elif 'SQLite' in library:
                patterns = self._extract_sqlite_patterns(doc_id, title, content, folder_path, library)
            else:
                patterns = self._extract_general_query_patterns(doc_id, title, content, folder_path, library)

            synthesized_patterns.extend(patterns)

        print(f"✅ Extracted {len(synthesized_patterns)} SQL query patterns from Structured Queries")
        return synthesized_patterns

    def _extract_core_patterns(self, doc_id: str, title: str, content: str, folder_path: str, library: str) -> List[Dict]:
        """Extract patterns from Core Structured Queries documentation"""
        patterns = []

        # Look for SQL statement patterns (SELECT, INSERT, UPDATE, DELETE)
        if any(stmt in content.upper() for stmt in ['SELECT', 'INSERT', 'UPDATE', 'DELETE']):
            pattern = self._create_sql_statement_pattern(title, content, folder_path, library)
            if pattern:
                patterns.append(pattern)

        # Look for query optimization patterns
        if any(keyword in content.lower() for keyword in ['performance', 'optimization', 'efficient', 'fast']):
            pattern = self._create_query_optimization_pattern(title, content, folder_path, library)
            if pattern:
                patterns.append(pattern)

        # Look for schema design patterns
        if any(keyword in content.lower() for keyword in ['schema', 'table', 'design', 'structure']):
            pattern = self._create_schema_design_pattern(title, content, folder_path, library)
            if pattern:
                patterns.append(pattern)

        # Look for migration patterns
        if any(keyword in content.lower() for keyword in ['migration', 'migrate', 'upgrade', 'version']):
            pattern = self._create_migration_pattern(title, content, folder_path, library)
            if pattern:
                patterns.append(pattern)

        return patterns

    def _extract_sqlite_patterns(self, doc_id: str, title: str, content: str, folder_path: str, library: str) -> List[Dict]:
        """Extract SQLite-specific patterns"""
        patterns = []

        # Look for SQLite function patterns
        if any(keyword in content.lower() for keyword in ['function', 'trigger', 'view']):
            pattern = self._create_sqlite_feature_pattern(title, content, folder_path, library)
            if pattern:
                patterns.append(pattern)

        # Look for full-text search patterns
        if any(keyword in content.lower() for keyword in ['full-text', 'search', 'fts']):
            pattern = self._create_full_text_search_pattern(title, content, folder_path, library)
            if pattern:
                patterns.append(pattern)

        return patterns

    def _extract_general_query_patterns(self, doc_id: str, title: str, content: str, folder_path: str, library: str) -> List[Dict]:
        """Extract general query patterns"""
        patterns = []

        # Look for code examples
        code_blocks = self._extract_code_blocks(content)
        for code_block in code_blocks:
            if 'SELECT' in code_block or 'INSERT' in code_block or 'UPDATE' in code_block or 'DELETE' in code_block:
                pattern = self._create_code_pattern(title, code_block, folder_path, library)
                if pattern:
                    patterns.append(pattern)

        return patterns

    def _create_sql_statement_pattern(self, title: str, content: str, folder_path: str, library: str) -> Dict:
        """Create SQL statement pattern"""
        # Extract SQL statements
        sql_statements = re.findall(r'(SELECT|INSERT|UPDATE|DELETE)\s+[^;]*;', content, re.IGNORECASE | re.MULTILINE | re.DOTALL)

        # Determine statement type
        stmt_types = []
        for stmt in sql_statements:
            stmt_type = stmt.split()[0].upper()
            if stmt_type not in stmt_types:
                stmt_types.append(stmt_type)

        return {
            'id': f"structured-queries-sql-{hash(title) % 10000}",
            'title': f"SQL Pattern: {title}",
            'problem': f"Need to write proper {'/'.join(stmt_types)} statements in Swift",
            'solution': f"Use Structured Queries for type-safe {'/'.join(stmt_types)} statement construction",
            'pattern_type': 'sql_statement',
            'folder': 'StructuredQueries/SQLStatements',
            'tags': ['structured-queries', 'sql', 'swift', library.lower()] + [s.lower() for s in stmt_types],
            'content': content,
            'sql_statements': sql_statements[:3],  # Limit to first 3 examples
            'statement_types': stmt_types,
            'source_document': title,
            'folder_path': folder_path
        }

    def _create_query_optimization_pattern(self, title: str, content: str, folder_path: str, library: str) -> Dict:
        """Create query optimization pattern"""
        # Look for performance tips
        performance_tips = []
        lines = content.split('\n')
        for line in lines:
            if any(keyword in line.lower() for keyword in ['fast', 'efficient', 'optimize', 'performance']):
                performance_tips.append(line.strip())

        return {
            'id': f"structured-queries-perf-{hash(title) % 10000}",
            'title': f"Query Performance: {title}",
            'problem': "Need to optimize SQL query performance in Swift",
            'solution': "Apply Structured Queries optimization techniques",
            'pattern_type': 'query_optimization',
            'folder': 'StructuredQueries/Performance',
            'tags': ['structured-queries', 'performance', 'optimization', 'sql', 'swift', library.lower()],
            'content': content,
            'performance_tips': performance_tips[:5],  # Limit to first 5 tips
            'source_document': title,
            'folder_path': folder_path
        }

    def _create_schema_design_pattern(self, title: str, content: str, folder_path: str, library: str) -> Dict:
        """Create schema design pattern"""
        # Look for design principles
        design_principles = []
        lines = content.split('\n')
        for line in lines:
            if any(keyword in line.lower() for keyword in ['should', 'recommend', 'best', 'avoid']):
                design_principles.append(line.strip())

        return {
            'id': f"structured-queries-schema-{hash(title) % 10000}",
            'title': f"Schema Design: {title}",
            'problem': "Need to design proper database schema with Structured Queries",
            'solution': "Follow Structured Queries schema design principles",
            'pattern_type': 'schema_design',
            'folder': 'StructuredQueries/SchemaDesign',
            'tags': ['structured-queries', 'schema', 'design', 'database', 'swift', library.lower()],
            'content': content,
            'design_principles': design_principles[:5],
            'source_document': title,
            'folder_path': folder_path
        }

    def _create_migration_pattern(self, title: str, content: str, folder_path: str, library: str) -> Dict:
        """Create migration pattern"""
        # Extract migration steps
        migration_steps = []
        lines = content.split('\n')
        for line in lines:
            if re.match(r'^\d+\.', line) or line.strip().startswith('-'):
                migration_steps.append(line.strip())

        return {
            'id': f"structured-queries-migration-{hash(title) % 10000}",
            'title': f"Migration Pattern: {title}",
            'problem': "Need to migrate database schema or queries",
            'solution': "Follow Structured Queries migration process",
            'pattern_type': 'migration',
            'folder': 'StructuredQueries/Migration',
            'tags': ['structured-queries', 'migration', 'database', 'swift', library.lower()],
            'content': content,
            'migration_steps': migration_steps,
            'source_document': title,
            'folder_path': folder_path
        }

    def _create_sqlite_feature_pattern(self, title: str, content: str, folder_path: str, library: str) -> Dict:
        """Create SQLite feature pattern"""
        # Identify SQLite features
        features = []
        lines = content.split('\n')
        for line in lines:
            if any(feature in line.lower() for feature in ['function', 'trigger', 'view', 'index']):
                features.append(line.strip())

        return {
            'id': f"structured-queries-sqlite-{hash(title) % 10000}",
            'title': f"SQLite Feature: {title}",
            'problem': f"Need to use SQLite-specific features with Structured Queries",
            'solution': f"Apply Structured Queries SQLite feature patterns",
            'pattern_type': 'sqlite_feature',
            'folder': 'StructuredQueries/SQLiteFeatures',
            'tags': ['structured-queries', 'sqlite', 'features', 'swift', library.lower()],
            'content': content,
            'sqlite_features': features[:5],
            'source_document': title,
            'folder_path': folder_path
        }

    def _create_full_text_search_pattern(self, title: str, content: str, folder_path: str, library: str) -> Dict:
        """Create full-text search pattern"""
        return {
            'id': f"structured-queries-fts-{hash(title) % 10000}",
            'title': f"Full-Text Search: {title}",
            'problem': "Need to implement full-text search with Structured Queries",
            'solution': "Use Structured Queries FTS integration patterns",
            'pattern_type': 'full_text_search',
            'folder': 'StructuredQueries/FullTextSearch',
            'tags': ['structured-queries', 'full-text-search', 'fts', 'sqlite', 'swift', library.lower()],
            'content': content,
            'source_document': title,
            'folder_path': folder_path
        }

    def _create_code_pattern(self, title: str, code_block: str, folder_path: str, library: str) -> Dict:
        """Create code example pattern"""
        # Extract function calls and types
        function_calls = re.findall(r'\w+\(', code_block)
        types = re.findall(r':\s*\w+', code_block)

        return {
            'id': f"structured-queries-code-{hash(title) % 10000}",
            'title': f"Code Example: {title}",
            'problem': f"Need to implement SQL queries in Swift code",
            'solution': f"Use this Structured Queries code pattern",
            'pattern_type': 'code_example',
            'folder': 'StructuredQueries/CodeExamples',
            'tags': ['structured-queries', 'code', 'swift', 'sql', library.lower()],
            'content': code_block,
            'function_calls': list(set(function_calls))[:5],
            'types': list(set(types))[:5],
            'source_document': title,
            'folder_path': folder_path
        }

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

    def save_synthesized_patterns(self, patterns: List[Dict]):
        """Save synthesized patterns to the patterns table"""
        print(f"💾 Saving {len(patterns)} Structured Queries patterns to database...")

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
                'StructuredQueries',
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
        print("✅ Structured Queries patterns saved successfully")

    def _format_pattern_content(self, pattern: Dict) -> str:
        """Format pattern content for database storage"""
        content = f"""# {pattern['title']}

## Problem
{pattern['problem']}

## Solution
{pattern['solution']}

## Pattern Type
{pattern['pattern_type']}

## Library
{pattern.get('folder_path', 'StructuredQueries')}

## Tags
{', '.join(pattern['tags'])}

## Source Document
{pattern['source_document']} (Location: {pattern['folder_path']})

"""

        # Add extra content based on pattern type
        if pattern['pattern_type'] == 'sql_statement' and pattern.get('sql_statements'):
            content += f"\n## SQL Statement Examples\n" + '\n\n'.join(f"```sql\n{stmt}\n```" for stmt in pattern['sql_statements']) + "\n"

        if pattern['pattern_type'] == 'query_optimization' and pattern.get('performance_tips'):
            content += f"\n## Performance Tips\n" + '\n'.join(f"- {tip}" for tip in pattern['performance_tips']) + "\n"

        if pattern['pattern_type'] == 'schema_design' and pattern.get('design_principles'):
            content += f"\n## Design Principles\n" + '\n'.join(f"- {principle}" for principle in pattern['design_principles']) + "\n"

        if pattern['pattern_type'] == 'migration' and pattern.get('migration_steps'):
            content += f"\n## Migration Steps\n" + '\n'.join(f"- {step}" for step in pattern['migration_steps']) + "\n"

        if pattern['pattern_type'] == 'code_example' and pattern.get('function_calls'):
            content += f"\n## Functions Used\n{', '.join(pattern['function_calls'])}\n"

        content += f"\n## Original Content\n{pattern['content'][:1500]}...\n"

        return content

def main():
    db_path = Path.home() / ".claude" / "resources" / "databases" / "maxwell.db"

    if not db_path.exists():
        print(f"❌ Database not found: {db_path}")
        return 1

    synthesizer = StructuredQueriesPatternSynthesizer(str(db_path))

    # Extract patterns from Structured Queries documentation
    patterns = synthesizer.extract_patterns_from_structured_queries()

    if patterns:
        # Save synthesized patterns
        synthesizer.save_synthesized_patterns(patterns)

        print(f"\n🎉 Structured Queries Pattern Synthesis Complete!")
        print(f"   📝 Synthesized {len(patterns)} SQL query patterns from Structured Queries documentation")
        print(f"   🏷️ Pattern types: sql_statement, query_optimization, schema_design, migration, sqlite_feature, full_text_search, code_example")

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