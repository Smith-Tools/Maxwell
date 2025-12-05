#!/usr/bin/env python3
"""
Duplicate Detection Module for Maxwell Librarian
Analyzes new documentation against existing knowledge base to detect duplicates and overlaps
"""

import sqlite3
import os
import hashlib
import re
from pathlib import Path
from typing import Dict, List, Tuple, Set
import json

class DuplicateDetector:
    def __init__(self):
        self.db_path = Path.home() / ".claude" / "resources" / "databases" / "maxwell.db"
        self.conn = sqlite3.connect(self.db_path)

    def analyze_content(self, docs_path: str, library_name: str) -> Dict:
        """Comprehensive analysis of new documentation for duplicates and overlaps"""
        print(f"🔍 Analyzing {docs_path} for duplicates...")

        # Get new documentation info
        new_files = self._get_document_files(docs_path)
        print(f"📄 Found {len(new_files)} documentation files")

        # Analyze different types of duplicates
        exact_duplicates = self._find_exact_duplicates(new_files)
        topic_overlaps = self._find_topic_overlaps(new_files, library_name)
        library_conflicts = self._find_library_conflicts(new_files, library_name)
        version_conflicts = self._find_version_conflicts(new_files, library_name)

        analysis = {
            'total_files': len(new_files),
            'exact_duplicates': exact_duplicates,
            'topic_overlaps': topic_overlaps,
            'library_conflicts': library_conflicts,
            'version_conflicts': version_conflicts,
            'new_unique_content': self._calculate_unique_content(new_files, analysis),
            'recommendations': self._generate_recommendations(analysis),
            'library_name': library_name
        }

        self._display_analysis(analysis)
        return analysis

    def _get_document_files(self, docs_path: str) -> List[Dict]:
        """Get all markdown files with their metadata"""
        docs_root = Path(docs_path)
        files = []

        if not docs_root.exists():
            print(f"❌ Documentation path not found: {docs_path}")
            return files

        for md_file in docs_root.rglob("*.md"):
            try:
                with open(md_file, 'r', encoding='utf-8') as f:
                    content = f.read()

                files.append({
                    'path': str(md_file),
                    'relative_path': str(md_file.relative_to(docs_root)),
                    'size': len(content),
                    'word_count': len(content.split()),
                    'hash': self._calculate_content_hash(content),
                    'title': self._extract_title(content),
                    'tags': self._extract_tags(content),
                    'content_preview': content[:500] + ("..." if len(content) > 500 else "")
                })
            except Exception as e:
                print(f"⚠️ Error reading {md_file}: {e}")

        return files

    def _calculate_content_hash(self, content: str) -> str:
        """Calculate hash of normalized content"""
        # Normalize content (remove extra whitespace, normalize line endings)
        normalized = re.sub(r'\s+', ' ', content.strip())
        return hashlib.md5(normalized.encode()).hexdigest()[:16]

    def _extract_title(self, content: str) -> str:
        """Extract the main title from markdown content"""
        lines = content.split('\n')
        for line in lines[:10]:  # Check first 10 lines
            line = line.strip()
            if line.startswith('# '):
                return line[2:].strip()
        return "Untitled"

    def _extract_tags(self, content: str) -> List[str]:
        """Extract tags from content"""
        tags = set()
        content_lower = content.lower()

        # Common technology tags
        tech_tags = ['swift', 'swiftui', 'uikit', 'combinable', 'tca', 'visionos', 'arkit', 'realitykit',
                     'coredata', 'cloudkit', 'metal', 'shareplay', 'spatial persona', 'systemcoordinator']

        for tag in tech_tags:
            if tag in content_lower:
                tags.add(tag)

        return list(tags)

    def _find_exact_duplicates(self, new_files: List[Dict]) -> List[Dict]:
        """Find files that are identical to existing content"""
        duplicates = []

        try:
            # Check reference table for exact duplicates
            cursor = self.conn.execute('''
                SELECT title, content, folder_path, library FROM reference
            ''')

            existing_content = {(row[0], row[1]): row for row in cursor.fetchall()}

            for new_file in new_files:
                with open(new_file['path'], 'r', encoding='utf-8') as f:
                    content = f.read()

                normalized_new = re.sub(r'\s+', ' ', content.strip())
                for existing_title, (existing_content, folder_path, library) in existing_content.items():
                    normalized_existing = re.sub(r'\s+', ' ', existing_content.strip())

                    if normalized_new == normalized_existing:
                        duplicates.append({
                            'new_file': new_file['relative_path'],
                            'existing_title': existing_title,
                            'existing_library': library,
                            'existing_path': folder_path,
                            'match_type': 'exact_content'
                        })
        except Exception as e:
            print(f"⚠️ Error checking exact duplicates: {e}")

        print(f"🔍 Found {len(duplicates)} exact duplicates")
        return duplicates

    def _find_topic_overlaps(self, new_files: List[Dict], library_name: str) -> List[Dict]:
        """Find content with overlapping topics in existing libraries"""
        overlaps = []

        try:
            # Check if content overlaps with existing libraries
            cursor = self.conn.execute('''
                SELECT DISTINCT library FROM reference
            ''')
            existing_libraries = [row[0] for row in cursor.fetchall()]

            for new_file in new_files:
                new_content = new_file['content_preview']
                new_tags = new_file['tags']

                for existing_lib in existing_libraries:
                    # Simple overlap detection based on tags and content keywords
                    overlap_score = self._calculate_overlap_score(new_content, new_tags, existing_lib)

                    if overlap_score > 0.3:  # 30% overlap threshold
                        overlaps.append({
                            'new_file': new_file['relative_path'],
                            'existing_library': existing_lib,
                            'overlap_score': overlap_score,
                            'common_tags': self._find_common_tags(new_tags, existing_lib)
                        })
        except Exception as e:
            print(f"⚠️ Error checking topic overlaps: {e}")

        print(f"🔍 Found {len(overlaps)} topic overlaps")
        return overlaps

    def _calculate_overlap_score(self, content: str, tags: List[str], existing_lib: str) -> float:
        """Calculate overlap score between new content and existing library"""
        try:
            # Get sample content from existing library
            cursor = self.conn.execute('''
                SELECT content FROM reference WHERE library = ? LIMIT 5
            ''', (existing_lib,))

            existing_samples = [row[0] for row in cursor.fetchall()]

            score = 0.0

            # Tag overlap (40% weight)
            existing_tags = set()
            for sample in existing_samples:
                existing_tags.update(self._extract_tags(sample))

            tag_overlap = len(set(tags) & existing_tags)
            if len(tags) > 0:
                score += (tag_overlap / len(tags)) * 0.4

            # Content keyword overlap (60% weight)
            content_overlap = 0
            for sample in existing_samples:
                content_overlap += len(set(content.lower().split()) & set(sample.lower().split()))

            if len(content.split()) > 0:
                content_score = (content_overlap / len(content.split())) / len(existing_samples)
                score += content_score * 0.6

            return score
        except Exception as e:
            print(f"⚠️ Error calculating overlap score: {e}")
            return 0.0

    def _find_common_tags(self, new_tags: List[str], existing_lib: str) -> List[str]:
        """Find common tags between new content and existing library"""
        try:
            cursor = self.conn.execute('''
                SELECT DISTINCT tags FROM reference WHERE library = ? AND tags IS NOT NULL
            ''', (existing_lib,))

            existing_tags = set()
            for row in cursor.fetchall():
                try:
                    tags = json.loads(row[0])
                    existing_tags.update(tags)
                except:
                    continue

            return list(set(new_tags) & existing_tags)
        except Exception as e:
            print(f"⚠️ Error finding common tags: {e}")
            return []

    def _find_library_conflicts(self, new_files: List[Dict], library_name: str) -> List[Dict]:
        """Find content that conflicts with existing library definitions"""
        conflicts = []

        # This would check if new content belongs to a different library than specified
        # Implementation would depend on how you define library boundaries

        return conflicts

    def _find_version_conflicts(self, new_files: List[Dict], library_name: str) -> List[Dict]:
        """Find version conflicts (newer versions of existing content)"""
        conflicts = []

        try:
            # Look for version indicators in titles or content
            version_pattern = r'\b(\d+\.\d+)\b'

            cursor = self.conn.execute('''
                SELECT title, library FROM reference WHERE library = ? OR library LIKE ?
            ''', (library_name, f'%{library_name}%'))

            existing_versions = {}
            for title, lib in cursor.fetchall():
                version_match = re.search(version_pattern, title)
                if version_match:
                    existing_versions[title] = version_match.group(1)

            for new_file in new_files:
                version_match = re.search(version_pattern, new_file['title'])
                if version_match:
                    new_version = version_match.group(1)

                    for existing_title, existing_version in existing_versions.items():
                        if self._is_same_content_type(new_file['title'], existing_title):
                            if float(new_version) > float(existing_version):
                                conflicts.append({
                                    'new_file': new_file['relative_path'],
                                    'existing_title': existing_title,
                                    'old_version': existing_version,
                                    'new_version': new_version,
                                    'conflict_type': 'version_upgrade'
                                })
        except Exception as e:
            print(f"⚠️ Error checking version conflicts: {e}")

        print(f"🔍 Found {len(conflicts)} version conflicts")
        return conflicts

    def _is_same_content_type(self, title1: str, title2: str) -> bool:
        """Determine if two titles refer to the same content type"""
        # Simple heuristic: compare key words
        words1 = set(title1.lower().replace('-', ' ').split())
        words2 = set(title2.lower().replace('-', ' ').split())

        common_words = words1 & words2
        return len(common_words) >= 3 or (len(common_words) > 0 and len(common_words) / min(len(words1), len(words2)) > 0.5)

    def _calculate_unique_content(self, new_files: List[Dict], analysis: Dict) -> Dict:
        """Calculate how much content is truly unique after filtering duplicates"""
        excluded_files = set()

        # Mark files with exact duplicates
        for dup in analysis['exact_duplicates']:
            excluded_files.add(dup['new_file'])

        # Mark files with high topic overlap
        for overlap in analysis['topic_overlaps']:
            if overlap['overlap_score'] > 0.7:  # 70% overlap threshold
                excluded_files.add(overlap['new_file'])

        unique_files = [f for f in new_files if f['relative_path'] not in excluded_files]

        return {
            'total_files': len(new_files),
            'excluded_files': len(excluded_files),
            'unique_files': len(unique_files),
            'uniqueness_percentage': (len(unique_files) / len(new_files)) * 100 if new_files else 0
        }

    def _generate_recommendations(self, analysis: Dict) -> List[str]:
        """Generate actionable recommendations based on analysis"""
        recommendations = []

        # Exact duplicates recommendation
        if analysis['exact_duplicates']:
            recommendations.append(f"⛔️ Skip {len(analysis['exact_duplicates'])} files - exact duplicates already exist")

        # Topic overlaps recommendation
        if analysis['topic_overlaps']:
            high_overlap = [o for o in analysis['topic_overlaps'] if o['overlap_score'] > 0.7]
            if high_overlap:
                recommendations.append(f"⚠️ Review {len(high_overlap)} files with >70% topic overlap - may be redundant")

        # Version conflicts recommendation
        if analysis['version_conflicts']:
            recommendations.append(f"📈 Update {len(analysis['version_conflicts'])} existing files with newer versions")

        # Unique content recommendation
        unique = analysis.get('new_unique_content', {})
        if unique.get('unique_files', 0) > 0:
            recommendations.append(f"✅ Import {unique['unique_files']} unique files ({unique['uniqueness_percentage']:.1f}% uniqueness)")

        # Overall strategy recommendation
        if unique.get('uniqueness_percentage', 0) < 50:
            recommendations.append("📋 Consider reviewing content - low uniqueness suggests significant overlap")
        elif unique.get('uniqueness_percentage', 0) > 80:
            recommendations.append("🎉 High uniqueness - this content adds significant value")
        else:
            recommendations.append("📝 Moderate uniqueness - good candidate for import")

        return recommendations

    def _display_analysis(self, analysis: Dict):
        """Display the analysis results in a user-friendly format"""
        print(f"\n📊 Duplicate Analysis Results")
        print(f"=" * 40)
        print(f"📁 Total files: {analysis['total_files']}")
        print(f"🔍 Exact duplicates: {len(analysis['exact_duplicates'])}")
        print(f"📝 Topic overlaps: {len(analysis['topic_overlaps'])}")
        print(f"📈 Version conflicts: {len(analysis['version_conflicts'])}")

        unique = analysis.get('new_unique_content', {})
        print(f"✅ Unique files: {unique.get('unique_files', 0)} ({unique.get('uniqueness_percentage', 0):.1f}%)")

        print(f"\n📋 Recommendations:")
        for recommendation in analysis.get('recommendations', []):
            print(f"   {recommendation}")

def main():
    if len(os.sys.argv) < 3:
        print("Usage: python3 duplicate_detector.py <docs_path> <library_name>")
        return 1

    docs_path = os.sys.argv[1]
    library_name = os.sys.argv[2]

    detector = DuplicateDetector()
    analysis = detector.analyze_content(docs_path, library_name)

    return 0

if __name__ == '__main__':
    exit(main())