#!/usr/bin/env python3
"""
Swift Sharing Pattern Synthesis
Extract problem-solution patterns from Swift Sharing documentation
"""

import sqlite3
import re
from pathlib import Path
from typing import List, Dict, Tuple
import json

class SwiftSharingPatternSynthesizer:
    def __init__(self, db_path: str):
        self.conn = sqlite3.connect(db_path)

    def extract_patterns_from_swift_sharing(self) -> List[Dict]:
        """Extract sharing patterns from Swift Sharing documentation"""
        print("🧠 Synthesizing sharing patterns from Swift Sharing documentation...")

        # Get all Swift Sharing reference documents
        cursor = self.conn.execute('''
            SELECT id, title, content, folder_path, doc_type
            FROM reference
            WHERE library = 'SwiftSharing'
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
                patterns = self._extract_general_sharing_patterns(doc_id, title, content, folder_path)

            synthesized_patterns.extend(patterns)

        print(f"✅ Extracted {len(synthesized_patterns)} sharing patterns from Swift Sharing")
        return synthesized_patterns

    def _extract_article_patterns(self, doc_id: str, title: str, content: str, folder_path: str) -> List[Dict]:
        """Extract patterns from Swift Sharing articles"""
        patterns = []

        # Look for conceptual sharing patterns
        if any(keyword in title.lower() for keyword in ['observing', 'mutating', 'initialization', 'persistence']):
            pattern = self._create_conceptual_pattern(title, content, folder_path)
            if pattern:
                patterns.append(pattern)

        # Look for migration patterns
        if any(keyword in title.lower() for keyword in ['migration', 'migrating']):
            pattern = self._create_migration_pattern(title, content, folder_path)
            if pattern:
                patterns.append(pattern)

        # Look for anti-patterns and gotchas
        if 'gotchas' in title.lower() or 'dynamic' in title.lower():
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
            if any(keyword in code_block for keyword in ['@Shared', '@SharedReader', 'SharedKey', 'SharedReaderKey']):
                pattern = self._create_sharing_api_pattern(title, code_block, folder_path)
                if pattern:
                    patterns.append(pattern)

        return patterns

    def _extract_general_sharing_patterns(self, doc_id: str, title: str, content: str, folder_path: str) -> List[Dict]:
        """Extract general sharing patterns"""
        patterns = []

        # Look for Swift code with sharing concepts
        code_blocks = self._extract_code_blocks(content)
        for code_block in code_blocks:
            if '@Shared' in code_block or '@SharedReader' in code_block or 'SharedKey' in code_block:
                pattern = self._create_sharing_pattern(title, code_block, folder_path)
                if pattern:
                    patterns.append(pattern)

        return patterns

    def _create_conceptual_pattern(self, title: str, content: str, folder_path: str) -> Dict:
        """Create conceptual sharing pattern"""
        # Extract key principles and concepts
        concepts = []
        lines = content.split('\n')
        for line in lines:
            if any(keyword in line.lower() for keyword in ['should', 'recommend', 'principle', 'pattern', 'rule']):
                if len(line) > 20 and len(line) < 150:
                    concepts.append(line.strip())

        # Determine main concept based on title
        main_concept = "Sharing Concept"
        if 'observing' in title.lower():
            main_concept = "State Observation"
        elif 'mutating' in title.lower():
            main_concept = "State Mutation"
        elif 'initialization' in title.lower():
            main_concept = "Sharing Initialization"
        elif 'persistence' in title.lower():
            main_concept = "State Persistence"
        elif 'testing' in title.lower():
            main_concept = "Sharing Testing"

        return {
            'id': f"sharing-concept-{hash(title) % 10000}",
            'title': f"Sharing Concept: {title}",
            'problem': f"Need to understand {main_concept} in Swift Sharing",
            'solution': f"Follow {main_concept} principles for proper state sharing",
            'pattern_type': 'sharing_concept',
            'folder': f'SwiftSharing/{main_concept.replace(" ", "")}',
            'tags': ['swift-sharing', 'concept', 'state-sharing', main_concept.lower().replace(" ", "-")],
            'content': content,
            'key_concepts': concepts[:5],  # Limit to first 5 concepts
            'main_concept': main_concept,
            'source_document': title,
            'folder_path': folder_path
        }

    def _create_migration_pattern(self, title: str, content: str, folder_path: str) -> Dict:
        """Create migration pattern for Swift Sharing"""
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
            'id': f"sharing-migration-{hash(title) % 10000}",
            'title': f"Sharing Migration: {title}",
            'problem': f"Upgrading to Swift Sharing {version} introduces breaking changes",
            'solution': f"Follow migration steps to update state sharing for version {version}",
            'pattern_type': 'sharing_migration',
            'folder': 'SwiftSharing/Migration',
            'tags': ['swift-sharing', 'migration', 'breaking-changes', f'version-{version}'],
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
            'id': f"sharing-anti-{hash(title) % 10000}",
            'title': f"Sharing Anti-Pattern: {title}",
            'problem': "Common pitfalls and mistakes when using Swift Sharing",
            'solution': "Recognize and avoid these anti-patterns for robust state sharing",
            'pattern_type': 'sharing_anti_pattern',
            'folder': 'SwiftSharing/AntiPatterns',
            'tags': ['swift-sharing', 'anti-pattern', 'pitfalls', 'state-sharing'],
            'content': content,
            'warnings': warnings[:5],
            'source_document': title,
            'folder_path': folder_path
        }

    def _create_sharing_api_pattern(self, title: str, code_block: str, folder_path: str) -> Dict:
        """Create sharing API usage pattern"""
        # Extract sharing-related types and functions
        sharing_types = re.findall(r'(@Shared|@SharedReader|SharedKey|SharedReaderKey|InMemoryKey|AppStorageKey)\w*', code_block)
        sharing_types = list(set(sharing_types))

        # Extract function signatures
        functions = re.findall(r'func\s+(\w+)', code_block)
        functions = list(set(functions))

        return {
            'id': f"sharing-api-{hash(title) % 10000}",
            'title': f"Sharing API: {title}",
            'problem': f"Need to use {title} correctly with Swift Sharing",
            'solution': f"Follow proper {title} usage pattern for state sharing",
            'pattern_type': 'sharing_api_usage',
            'folder': 'SwiftSharing/API',
            'tags': ['swift-sharing', 'api', 'state-sharing'] + [t.lower() for t in sharing_types[:3]],
            'content': code_block,
            'sharing_types_used': sharing_types,
            'functions_used': functions,
            'source_document': title,
            'folder_path': folder_path
        }

    def _create_sharing_pattern(self, title: str, code_block: str, folder_path: str) -> Dict:
        """Create general sharing implementation pattern"""
        return {
            'id': f"sharing-implementation-{hash(title) % 10000}",
            'title': f"Sharing Implementation: {title}",
            'problem': "Need to implement proper Swift Sharing patterns",
            'solution': "Use this state sharing pattern as a reference",
            'pattern_type': 'sharing_implementation',
            'folder': 'SwiftSharing/Implementation',
            'tags': ['swift-sharing', 'implementation', 'state-sharing'],
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
        print(f"💾 Saving {len(patterns)} sharing patterns to database...")

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
                'SwiftSharing',
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
        print("✅ Sharing patterns saved successfully")

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
Swift Sharing

## Tags
{', '.join(pattern['tags'])}

## Source Document
{pattern['source_document']} (Location: {pattern['folder_path']})

"""

        # Add extra content based on pattern type
        if pattern['pattern_type'] == 'sharing_migration' and pattern.get('breaking_changes'):
            content += f"\n## Breaking Changes\n" + '\n'.join(f"- {change}" for change in pattern['breaking_changes']) + "\n"

        if pattern['pattern_type'] == 'sharing_api_usage':
            if pattern.get('sharing_types_used'):
                content += f"\n## Sharing Types Used\n{', '.join(pattern['sharing_types_used'])}\n"
            if pattern.get('functions_used'):
                content += f"\n## Functions Used\n{', '.join(pattern['functions_used'])}\n"

        if pattern['pattern_type'] == 'sharing_concept' and pattern.get('key_concepts'):
            content += f"\n## Key Concepts\n" + '\n'.join(f"- {concept}" for concept in pattern['key_concepts']) + "\n"

        if pattern['pattern_type'] == 'sharing_anti_pattern' and pattern.get('warnings'):
            content += f"\n## Warnings and Pitfalls\n" + '\n'.join(f"- {warning}" for warning in pattern['warnings']) + "\n"

        content += f"\n## Original Content\n{pattern['content'][:1500]}...\n"

        return content

def main():
    db_path = Path.home() / ".claude" / "resources" / "databases" / "maxwell.db"

    if not db_path.exists():
        print(f"❌ Database not found: {db_path}")
        return 1

    synthesizer = SwiftSharingPatternSynthesizer(str(db_path))

    # Extract patterns from Swift Sharing documentation
    patterns = synthesizer.extract_patterns_from_swift_sharing()

    if patterns:
        # Save synthesized patterns
        synthesizer.save_synthesized_patterns(patterns)

        print(f"\n🎉 Swift Sharing Pattern Synthesis Complete!")
        print(f"   📝 Synthesized {len(patterns)} sharing patterns from Swift Sharing documentation")
        print(f"   🏷️ Pattern types: sharing_concept, sharing_migration, sharing_anti_pattern, sharing_api_usage, sharing_implementation")

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