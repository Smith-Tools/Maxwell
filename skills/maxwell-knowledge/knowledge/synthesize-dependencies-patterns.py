#!/usr/bin/env python3
"""
Swift Dependencies Pattern Synthesis
Extract problem-solution patterns from Swift Dependencies documentation
"""

import sqlite3
import re
from pathlib import Path
from typing import List, Dict, Tuple
import json

class SwiftDependenciesPatternSynthesizer:
    def __init__(self, db_path: str):
        self.conn = sqlite3.connect(db_path)

    def extract_patterns_from_swift_dependencies(self) -> List[Dict]:
        """Extract dependency patterns from Swift Dependencies documentation"""
        print("🧠 Synthesizing dependency patterns from Swift Dependencies documentation...")

        # Get all Swift Dependencies reference documents
        cursor = self.conn.execute('''
            SELECT id, title, content, folder_path, doc_type
            FROM reference
            WHERE library = 'SwiftDependencies'
        ''')

        synthesized_patterns = []

        for row in cursor.fetchall():
            doc_id, title, content, folder_path, doc_type = row

            # Extract patterns based on content and document type
            if 'Articles' in folder_path:
                patterns = self._extract_article_patterns(doc_id, title, content, folder_path)
            elif 'Extensions' in folder_path:
                patterns = self._extract_extension_patterns(doc_id, title, content, folder_path)
            else:
                patterns = self._extract_general_dependency_patterns(doc_id, title, content, folder_path)

            synthesized_patterns.extend(patterns)

        print(f"✅ Extracted {len(synthesized_patterns)} dependency patterns from Swift Dependencies")
        return synthesized_patterns

    def _extract_article_patterns(self, doc_id: str, title: str, content: str, folder_path: str) -> List[Dict]:
        """Extract patterns from Swift Dependencies articles"""
        patterns = []

        # Look for conceptual dependency patterns
        if any(keyword in title.lower() for keyword in ['testing', 'lifetimes', 'designing', 'registering']):
            pattern = self._create_conceptual_pattern(title, content, folder_path)
            if pattern:
                patterns.append(pattern)

        # Look for migration patterns
        if any(keyword in title.lower() for keyword in ['migration', 'migrating']):
            pattern = self._create_migration_pattern(title, content, folder_path)
            if pattern:
                patterns.append(pattern)

        # Look for anti-patterns and gotchas
        if 'gotchas' in title.lower() or 'single entry point' in title.lower():
            pattern = self._create_anti_pattern(title, content, folder_path)
            if pattern:
                patterns.append(pattern)

        return patterns

    def _extract_extension_patterns(self, doc_id: str, title: str, content: str, folder_path: str) -> List[Dict]:
        """Extract API usage patterns from extensions documentation"""
        patterns = []

        # Look for code examples and API patterns
        code_blocks = self._extract_code_blocks(content)

        for code_block in code_blocks:
            if any(keyword in code_block for keyword in ['@Dependency', 'DependencyKey', 'DependencyValues']):
                pattern = self._create_dependency_api_pattern(title, code_block, folder_path)
                if pattern:
                    patterns.append(pattern)

        return patterns

    def _extract_general_dependency_patterns(self, doc_id: str, title: str, content: str, folder_path: str) -> List[Dict]:
        """Extract general dependency patterns"""
        patterns = []

        # Look for Swift code with dependency concepts
        code_blocks = self._extract_code_blocks(content)
        for code_block in code_blocks:
            if '@Dependency' in code_block or 'DependencyValues' in code_block:
                pattern = self._create_dependency_pattern(title, code_block, folder_path)
                if pattern:
                    patterns.append(pattern)

        return patterns

    def _create_conceptual_pattern(self, title: str, content: str, folder_path: str) -> Dict:
        """Create conceptual dependency pattern"""
        # Extract key principles and concepts
        concepts = []
        lines = content.split('\n')
        for line in lines:
            if any(keyword in line.lower() for keyword in ['should', 'recommend', 'principle', 'pattern', 'best']):
                if len(line) > 20 and len(line) < 150:
                    concepts.append(line.strip())

        # Determine main concept based on title
        main_concept = "Dependency Concept"
        if 'testing' in title.lower():
            main_concept = "Dependency Testing"
        elif 'lifetime' in title.lower():
            main_concept = "Dependency Lifecycle"
        elif 'designing' in title.lower():
            main_concept = "Dependency Design"
        elif 'registering' in title.lower():
            main_concept = "Dependency Registration"
        elif 'overriding' in title.lower():
            main_concept = "Dependency Override"

        return {
            'id': f"deps-concept-{hash(title) % 10000}",
            'title': f"Dependency Concept: {title}",
            'problem': f"Need to understand {main_concept} in Swift Dependencies",
            'solution': f"Follow {main_concept} principles for proper dependency management",
            'pattern_type': 'dependency_concept',
            'folder': f'SwiftDependencies/{main_concept.replace(" ", "")}',
            'tags': ['swift-dependencies', 'concept', 'dependency-injection', main_concept.lower().replace(" ", "-")],
            'content': content,
            'key_concepts': concepts[:5],  # Limit to first 5 concepts
            'main_concept': main_concept,
            'source_document': title,
            'folder_path': folder_path
        }

    def _create_migration_pattern(self, title: str, content: str, folder_path: str) -> Dict:
        """Create migration pattern for Swift Dependencies"""
        # Look for version-specific changes
        version_match = re.search(r'(\d+\.\d+)', title)
        version = version_match.group(1) if version_match else "Unknown"

        # Look for breaking changes
        breaking_changes = []
        lines = content.split('\n')
        for line in lines:
            if any(keyword in line.lower() for keyword in ['breaking', 'deprecated', 'removed', 'changed']):
                breaking_changes.append(line.strip())

        return {
            'id': f"deps-migration-{hash(title) % 10000}",
            'title': f"Dependencies Migration: {title}",
            'problem': f"Upgrading to Swift Dependencies {version} introduces breaking changes",
            'solution': f"Follow migration steps to update dependency usage for version {version}",
            'pattern_type': 'dependency_migration',
            'folder': 'SwiftDependencies/Migration',
            'tags': ['swift-dependencies', 'migration', 'breaking-changes', f'version-{version}'],
            'content': content,
            'breaking_changes': breaking_changes[:5],
            'version': version,
            'source_document': title,
            'folder_path': folder_path
        }

    def _create_anti_pattern(self, title: str, content: str, folder_path: str) -> Dict:
        """Create anti-pattern documentation"""
        # Look for warnings and common mistakes
        warnings = []
        lines = content.split('\n')
        for line in lines:
            if any(keyword in line.lower() for keyword in ['avoid', 'warning', 'danger', 'mistake', 'incorrect']):
                if len(line) > 15 and len(line) < 200:
                    warnings.append(line.strip())

        return {
            'id': f"deps-anti-{hash(title) % 10000}",
            'title': f"Dependency Anti-Pattern: {title}",
            'problem': "Common pitfalls and mistakes when using Swift Dependencies",
            'solution': "Recognize and avoid these anti-patterns for robust dependency management",
            'pattern_type': 'dependency_anti_pattern',
            'folder': 'SwiftDependencies/AntiPatterns',
            'tags': ['swift-dependencies', 'anti-pattern', 'pitfalls', 'best-practices'],
            'content': content,
            'warnings': warnings[:5],
            'source_document': title,
            'folder_path': folder_path
        }

    def _create_dependency_api_pattern(self, title: str, code_block: str, folder_path: str) -> Dict:
        """Create dependency API usage pattern"""
        # Extract dependency-related types and functions
        dependency_types = re.findall(r'(@Dependency|DependencyKey|DependencyValues|DependencyClient)\w*', code_block)
        dependency_types = list(set(dependency_types))

        # Extract function signatures
        functions = re.findall(r'func\s+(\w+)', code_block)
        functions = list(set(functions))

        return {
            'id': f"deps-api-{hash(title) % 10000}",
            'title': f"Dependencies API: {title}",
            'problem': f"Need to use {title} correctly with Swift Dependencies",
            'solution': f"Follow proper {title} usage pattern for dependency injection",
            'pattern_type': 'dependency_api_usage',
            'folder': 'SwiftDependencies/API',
            'tags': ['swift-dependencies', 'api', 'dependency-injection'] + [t.lower() for t in dependency_types[:3]],
            'content': code_block,
            'dependency_types_used': dependency_types,
            'functions_used': functions,
            'source_document': title,
            'folder_path': folder_path
        }

    def _create_dependency_pattern(self, title: str, code_block: str, folder_path: str) -> Dict:
        """Create general dependency implementation pattern"""
        return {
            'id': f"deps-implementation-{hash(title) % 10000}",
            'title': f"Dependencies Implementation: {title}",
            'problem': "Need to implement proper Swift Dependencies patterns",
            'solution': "Use this dependency injection pattern as a reference",
            'pattern_type': 'dependency_implementation',
            'folder': 'SwiftDependencies/Implementation',
            'tags': ['swift-dependencies', 'implementation', 'dependency-injection'],
            'content': code_block,
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
        print(f"💾 Saving {len(patterns)} dependency patterns to database...")

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
                'SwiftDependencies',
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
        print("✅ Dependency patterns saved successfully")

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
Swift Dependencies

## Tags
{', '.join(pattern['tags'])}

## Source Document
{pattern['source_document']} (Location: {pattern['folder_path']})

"""

        # Add extra content based on pattern type
        if pattern['pattern_type'] == 'dependency_migration' and pattern.get('breaking_changes'):
            content += f"\n## Breaking Changes\n" + '\n'.join(f"- {change}" for change in pattern['breaking_changes']) + "\n"

        if pattern['pattern_type'] == 'dependency_api_usage':
            if pattern.get('dependency_types_used'):
                content += f"\n## Dependency Types Used\n{', '.join(pattern['dependency_types_used'])}\n"
            if pattern.get('functions_used'):
                content += f"\n## Functions Used\n{', '.join(pattern['functions_used'])}\n"

        if pattern['pattern_type'] == 'dependency_concept' and pattern.get('key_concepts'):
            content += f"\n## Key Concepts\n" + '\n'.join(f"- {concept}" for concept in pattern['key_concepts']) + "\n"

        if pattern['pattern_type'] == 'dependency_anti_pattern' and pattern.get('warnings'):
            content += f"\n## Warnings and Pitfalls\n" + '\n'.join(f"- {warning}" for warning in pattern['warnings']) + "\n"

        content += f"\n## Original Content\n{pattern['content'][:1500]}...\n"

        return content

def main():
    db_path = Path.home() / ".claude" / "resources" / "databases" / "maxwell.db"

    if not db_path.exists():
        print(f"❌ Database not found: {db_path}")
        return 1

    synthesizer = SwiftDependenciesPatternSynthesizer(str(db_path))

    # Extract patterns from Swift Dependencies documentation
    patterns = synthesizer.extract_patterns_from_swift_dependencies()

    if patterns:
        # Save synthesized patterns
        synthesizer.save_synthesized_patterns(patterns)

        print(f"\n🎉 Swift Dependencies Pattern Synthesis Complete!")
        print(f"   📝 Synthesized {len(patterns)} dependency patterns from Swift Dependencies documentation")
        print(f"   🏷️ Pattern types: dependency_concept, dependency_migration, dependency_anti_pattern, dependency_api_usage, dependency_implementation")

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