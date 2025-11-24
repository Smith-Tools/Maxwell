#!/usr/bin/env python3
"""
Composable Architecture Pattern Synthesis
Extract problem-solution patterns from TCA (The Composable Architecture) documentation
"""

import sqlite3
import re
from pathlib import Path
from typing import List, Dict, Tuple
import json

class ComposableArchitecturePatternSynthesizer:
    def __init__(self, db_path: str):
        self.conn = sqlite3.connect(db_path)

    def extract_patterns_from_composable_architecture(self) -> List[Dict]:
        """Extract TCA patterns from Composable Architecture documentation"""
        print("🧠 Synthesizing TCA patterns from Composable Architecture documentation...")

        # Get all Composable Architecture reference documents
        cursor = self.conn.execute('''
            SELECT id, title, content, folder_path, doc_type
            FROM reference
            WHERE library = 'ComposableArchitecture'
        ''')

        synthesized_patterns = []

        for row in cursor.fetchall():
            doc_id, title, content, folder_path, doc_type = row

            # Extract patterns based on content and document type
            if 'MigrationGuides' in folder_path:
                patterns = self._extract_migration_patterns(doc_id, title, content, folder_path)
            elif 'Extensions' in folder_path:
                patterns = self._extract_extension_patterns(doc_id, title, content, folder_path)
            elif 'Articles' in folder_path:
                patterns = self._extract_article_patterns(doc_id, title, content, folder_path)
            else:
                patterns = self._extract_general_tca_patterns(doc_id, title, content, folder_path)

            synthesized_patterns.extend(patterns)

        print(f"✅ Extracted {len(synthesized_patterns)} TCA patterns from Composable Architecture")
        return synthesized_patterns

    def _extract_migration_patterns(self, doc_id: str, title: str, content: str, folder_path: str) -> List[Dict]:
        """Extract migration patterns from version upgrade guides"""
        patterns = []

        # Look for version-specific migration issues
        version_match = re.search(r'Migrating\s+to\s+([\d.]+)', title, re.IGNORECASE)
        version = version_match.group(1) if version_match else "Unknown"

        # Look for breaking changes and solutions
        breaking_changes = []
        solutions = []

        lines = content.split('\n')
        current_section = None

        for line in lines:
            line = line.strip()
            if any(keyword in line.lower() for keyword in ['breaking', 'deprecated', 'removed', 'changed']):
                breaking_changes.append(line)
            elif any(keyword in line.lower() for keyword in ['fix', 'replace', 'update', 'use', 'solution']):
                solutions.append(line)

        if breaking_changes or solutions:
            pattern = {
                'id': f"tca-migration-{hash(title) % 10000}",
                'title': f"TCA Migration: {title}",
                'problem': f"Upgrading to TCA {version} introduces breaking changes that need to be addressed",
                'solution': f"Follow migration steps to update code for TCA {version} compatibility",
                'pattern_type': 'tca_migration',
                'folder': 'ComposableArchitecture/Migration',
                'tags': ['tca', 'migration', 'breaking-changes', 'composable-architecture', f'version-{version}'],
                'content': content,
                'breaking_changes': breaking_changes[:5],  # Limit to first 5
                'migration_steps': solutions[:5],
                'source_document': title,
                'folder_path': folder_path,
                'version': version
            }
            patterns.append(pattern)

        return patterns

    def _extract_extension_patterns(self, doc_id: str, title: str, content: str, folder_path: str) -> List[Dict]:
        """Extract TCA API usage patterns from extensions documentation"""
        patterns = []

        # Look for code examples and API patterns
        code_blocks = self._extract_code_blocks(content)

        for code_block in code_blocks:
            if any(tca_keyword in code_block for tca_keyword in ['Store', 'Reducer', 'ViewStore', 'Effect', 'State', 'Action']):
                pattern = self._create_tca_api_pattern(title, code_block, folder_path)
                if pattern:
                    patterns.append(pattern)

        return patterns

    def _extract_article_patterns(self, doc_id: str, title: str, content: str, folder_path: str) -> List[Dict]:
        """Extract conceptual patterns from TCA articles"""
        patterns = []

        # Look for TCA conceptual patterns
        if any(keyword in title.lower() for keyword in ['state', 'composition', 'testing', 'side effects', 'navigation']):
            pattern = self._create_conceptual_pattern(title, content, folder_path)
            if pattern:
                patterns.append(pattern)

        # Look for performance patterns
        if 'performance' in title.lower() or 'performance' in content.lower():
            pattern = self._create_performance_pattern(title, content, folder_path)
            if pattern:
                patterns.append(pattern)

        return patterns

    def _extract_general_tca_patterns(self, doc_id: str, title: str, content: str, folder_path: str) -> List[Dict]:
        """Extract general TCA patterns"""
        patterns = []

        # Look for Swift code blocks with TCA concepts
        code_blocks = self._extract_code_blocks(content)
        for code_block in code_blocks:
            if 'struct' in code_block and ('State' in code_block or 'Action' in code_block or 'Reducer' in code_block):
                pattern = self._create_tca_pattern(title, code_block, folder_path)
                if pattern:
                    patterns.append(pattern)

        return patterns

    def _create_tca_api_pattern(self, title: str, code_block: str, folder_path: str) -> Dict:
        """Create TCA API usage pattern"""
        # Extract TCA-specific types and functions
        tca_types = re.findall(r'(Store|ViewStore|Reducer|Effect|State|Action|Scope|Binding)\w*', code_block)
        tca_types = list(set(tca_types))

        # Extract function signatures
        functions = re.findall(r'func\s+(\w+)', code_block)
        functions = list(set(functions))

        return {
            'id': f"tca-api-{hash(title) % 10000}",
            'title': f"TCA API: {title}",
            'problem': f"Need to use {title} correctly in TCA architecture",
            'solution': f"Follow proper {title} usage pattern with TCA best practices",
            'pattern_type': 'tca_api_usage',
            'folder': 'ComposableArchitecture/API',
            'tags': ['tca', 'api', 'swift', 'composable-architecture'] + [t.lower() for t in tca_types[:3]],
            'content': code_block,
            'tca_types_used': tca_types,
            'functions_used': functions,
            'source_document': title,
            'folder_path': folder_path
        }

    def _create_conceptual_pattern(self, title: str, content: str, folder_path: str) -> Dict:
        """Create conceptual TCA pattern"""
        # Extract key concepts and principles
        concepts = []
        lines = content.split('\n')
        for line in lines:
            if any(keyword in line.lower() for keyword in ['should', 'recommend', 'principle', 'pattern', 'approach']):
                if len(line) > 20 and len(line) < 150:
                    concepts.append(line.strip())

        # Determine main concept based on title
        main_concept = "TCA Concept"
        if 'state' in title.lower():
            main_concept = "State Management"
        elif 'composition' in title.lower():
            main_concept = "Feature Composition"
        elif 'testing' in title.lower():
            main_concept = "Testing Strategy"
        elif 'navigation' in title.lower():
            main_concept = "Navigation Pattern"

        return {
            'id': f"tca-concept-{hash(title) % 10000}",
            'title': f"TCA Concept: {title}",
            'problem': f"Need to understand and apply {main_concept} in TCA",
            'solution': f"Follow {main_concept} principles for consistent TCA implementation",
            'pattern_type': 'tca_concept',
            'folder': f'ComposableArchitecture/{main_concept.replace(" ", "")}',
            'tags': ['tca', 'concept', 'architecture', 'composable-architecture', main_concept.lower().replace(" ", "-")],
            'content': content,
            'key_concepts': concepts[:5],  # Limit to first 5 concepts
            'main_concept': main_concept,
            'source_document': title,
            'folder_path': folder_path
        }

    def _create_performance_pattern(self, title: str, content: str, folder_path: str) -> Dict:
        """Create TCA performance optimization pattern"""
        # Look for performance tips and optimizations
        performance_tips = []
        lines = content.split('\n')
        for line in lines:
            if any(keyword in line.lower() for keyword in ['fast', 'efficient', 'optimize', 'performance', 'reduce']):
                if len(line) > 15 and len(line) < 200:
                    performance_tips.append(line.strip())

        return {
            'id': f"tca-performance-{hash(title) % 10000}",
            'title': f"TCA Performance: {title}",
            'problem': "TCA application has performance issues that need optimization",
            'solution': "Apply TCA-specific performance optimization techniques",
            'pattern_type': 'tca_performance',
            'folder': 'ComposableArchitecture/Performance',
            'tags': ['tca', 'performance', 'optimization', 'composable-architecture'],
            'content': content,
            'optimization_tips': performance_tips[:5],
            'source_document': title,
            'folder_path': folder_path
        }

    def _create_tca_pattern(self, title: str, code_block: str, folder_path: str) -> Dict:
        """Create general TCA implementation pattern"""
        return {
            'id': f"tca-implementation-{hash(title) % 10000}",
            'title': f"TCA Implementation: {title}",
            'problem': "Need to implement proper TCA architecture patterns",
            'solution': "Use this TCA implementation pattern as a reference",
            'pattern_type': 'tca_implementation',
            'folder': 'ComposableArchitecture/Implementation',
            'tags': ['tca', 'implementation', 'swift', 'composable-architecture'],
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
        print(f"💾 Saving {len(patterns)} TCA patterns to database...")

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
                'ComposableArchitecture',
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
        print("✅ TCA patterns saved successfully")

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
Composable Architecture TCA

## Tags
{', '.join(pattern['tags'])}

## Source Document
{pattern['source_document']} (Location: {pattern['folder_path']})

"""

        # Add extra content based on pattern type
        if pattern['pattern_type'] == 'tca_migration' and pattern.get('breaking_changes'):
            content += f"\n## Breaking Changes\n" + '\n'.join(f"- {change}" for change in pattern['breaking_changes']) + "\n"

        if pattern['pattern_type'] == 'tca_migration' and pattern.get('migration_steps'):
            content += f"\n## Migration Steps\n" + '\n'.join(f"- {step}" for step in pattern['migration_steps']) + "\n"

        if pattern['pattern_type'] == 'tca_api_usage':
            if pattern.get('tca_types_used'):
                content += f"\n## TCA Types Used\n{', '.join(pattern['tca_types_used'])}\n"
            if pattern.get('functions_used'):
                content += f"\n## Functions Used\n{', '.join(pattern['functions_used'])}\n"

        if pattern['pattern_type'] == 'tca_concept' and pattern.get('key_concepts'):
            content += f"\n## Key Concepts\n" + '\n'.join(f"- {concept}" for concept in pattern['key_concepts']) + "\n"

        if pattern['pattern_type'] == 'tca_performance' and pattern.get('optimization_tips'):
            content += f"\n## Optimization Tips\n" + '\n'.join(f"- {tip}" for tip in pattern['optimization_tips']) + "\n"

        content += f"\n## Original Content\n{pattern['content'][:1500]}...\n"

        return content

def main():
    db_path = Path.home() / ".claude" / "resources" / "databases" / "maxwell.db"

    if not db_path.exists():
        print(f"❌ Database not found: {db_path}")
        return 1

    synthesizer = ComposableArchitecturePatternSynthesizer(str(db_path))

    # Extract patterns from Composable Architecture documentation
    patterns = synthesizer.extract_patterns_from_composable_architecture()

    if patterns:
        # Save synthesized patterns
        synthesizer.save_synthesized_patterns(patterns)

        print(f"\n🎉 Composable Architecture Pattern Synthesis Complete!")
        print(f"   📝 Synthesized {len(patterns)} TCA patterns from Composable Architecture documentation")
        print(f"   🏷️ Pattern types: tca_migration, tca_api_usage, tca_concept, tca_performance, tca_implementation")

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