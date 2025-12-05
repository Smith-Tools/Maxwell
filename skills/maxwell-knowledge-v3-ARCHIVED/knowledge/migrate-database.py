#!/usr/bin/env python3

"""
Maxwell Enhanced Database Migration
Adds two-table architecture with folder-based reference organization
"""

import sqlite3
import json
import os
from pathlib import Path
from datetime import datetime
import argparse

class MaxwellDatabaseMigrator:
    def __init__(self, db_path: str):
        self.db_path = db_path
        self.conn = sqlite3.connect(db_path)

    def migrate_to_hybrid_schema(self):
        """Add reference table and migrate existing knowledge to patterns table"""
        print("🔄 Migrating Maxwell database to hybrid schema...")

        # Check if patterns table exists, if not create it from knowledge
        cursor = self.conn.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='patterns'")
        if not cursor.fetchone():
            print("   📋 Creating patterns table from existing knowledge...")
            self.conn.execute('''
                CREATE TABLE patterns AS SELECT * FROM knowledge
            ''')

            # Add new columns to patterns table
            self.conn.execute('''
                ALTER TABLE patterns ADD COLUMN folder_path TEXT
            ''')

            self.conn.execute('''
                ALTER TABLE patterns ADD COLUMN doc_type TEXT DEFAULT 'pattern'
            ''')

            self.conn.execute('''
                ALTER TABLE patterns ADD COLUMN library TEXT DEFAULT 'maxwell'
            ''')

            self.conn.execute('''
                ALTER TABLE patterns ADD COLUMN summary TEXT
            ''')

            # Initialize new columns
            self.conn.execute('''
                UPDATE patterns SET
                    folder_path = folder,
                    doc_type = 'pattern',
                    library = 'maxwell'
            ''')

            print(f"   ✅ Migrated {self.conn.execute('SELECT COUNT(*) FROM patterns').fetchone()[0]} records to patterns table")

        # Add reference table if it doesn't exist
        cursor = self.conn.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='reference'")
        if not cursor.fetchone():
            print("   📚 Creating reference table...")
            self.conn.execute('''
                CREATE TABLE reference (
                    id TEXT PRIMARY KEY,
                    title TEXT NOT NULL,
                    content TEXT,
                    folder_path TEXT,  -- Preserve folder structure
                    doc_type TEXT,     -- 'api', 'article', 'extension', 'tutorial'
                    library TEXT,      -- 'SQLiteData', 'SwiftUI', etc.
                    file_path TEXT,    -- Original file path
                    word_count INTEGER,
                    summary TEXT,      -- Human-readable summary for first line
                    tags TEXT,         # JSON array of tags
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            ''')

        # Create FTS tables
        print("   🔍 Setting up full-text search indexes...")
        self.conn.execute('''
            CREATE VIRTUAL TABLE IF NOT EXISTS patterns_fts USING fts5(
                content, title, folder, tags,
                content='patterns', content_rowid='rowid'
            )
        ''')

        self.conn.execute('''
            CREATE VIRTUAL TABLE IF NOT EXISTS reference_fts USING fts5(
                content, title, folder_path, doc_type, library, summary,
                content='reference', content_rowid='rowid'
            )
        ''')

        # Rebuild patterns FTS
        self._rebuild_patterns_fts()

        self.conn.commit()
        print("✅ Database migration completed successfully")

    def _rebuild_patterns_fts(self):
        """Rebuild patterns FTS with new structure"""
        patterns = self.conn.execute('SELECT rowid, title, content, folder, tags FROM patterns').fetchall()

        for rowid, title, content, folder, tags in patterns:
            self.conn.execute('''
                INSERT INTO patterns_fts (rowid, content, title, folder, tags)
                VALUES (?, ?, ?, ?, ?)
            ''', (rowid, content, title, folder, tags))

        print(f"✅ Rebuilt FTS index for {len(patterns)} patterns")

    def import_reference_documentation(self, docs_path: str, library_name: str):
        """Import documentation with folder structure preservation"""
        print(f"📚 Importing {library_name} documentation from {docs_path}")

        docs_root = Path(docs_path)
        if not docs_root.exists():
            print(f"❌ Documentation path not found: {docs_path}")
            return False

        imported_count = 0

        for md_file in docs_root.rglob("*.md"):
            try:
                # Read file content
                with open(md_file, 'r', encoding='utf-8') as f:
                    content = f.read()

                # Determine folder structure relative to docs root
                relative_path = md_file.relative_to(docs_root)
                folder_path = str(relative_path.parent) if relative_path.parent != Path('.') else "root"

                # Classify document type based on folder and content
                doc_type = self._classify_document_type(folder_path, content)

                # Generate summary and tags
                summary = self._generate_summary(content)
                tags = self._extract_tags(content, library_name, doc_type)

                # Generate unique ID
                doc_id = f"{library_name}_{md_file.stem}_{hash(str(relative_path)) % 10000}"

                # Insert into database
                self.conn.execute('''
                    INSERT OR REPLACE INTO reference
                    (id, title, content, folder_path, doc_type, library,
                     file_path, word_count, summary, tags)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ''', (
                    doc_id,
                    self._extract_title(content),
                    content,
                    folder_path,
                    doc_type,
                    library_name,
                    str(relative_path),
                    len(content.split()),
                    summary,
                    json.dumps(tags)
                ))

                # Update FTS
                rowid = self.conn.execute('SELECT last_insert_rowid()').fetchone()[0]
                self.conn.execute('''
                    INSERT INTO reference_fts
                    (rowid, content, title, folder_path, doc_type, library, summary)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                ''', (rowid, content, self._extract_title(content), folder_path, doc_type, library_name, summary))

                imported_count += 1
                print(f"   ✅ Imported: {relative_path}")

            except Exception as e:
                print(f"   ❌ Error importing {md_file}: {e}")

        self.conn.commit()
        print(f"🎉 Successfully imported {imported_count} documents from {library_name}")
        return True

    def _classify_document_type(self, folder_path: str, content: str) -> str:
        """Classify document type based on folder and content analysis"""
        folder_lower = folder_path.lower()

        if 'article' in folder_lower or 'articles' in folder_lower:
            return 'article'
        elif 'extension' in folder_lower or 'extensions' in folder_lower:
            return 'extension'
        elif 'api' in folder_lower or 'reference' in folder_lower:
            return 'api'
        elif 'tutorial' in folder_lower or 'guide' in folder_lower:
            return 'tutorial'
        elif content.startswith('#') and any(word in content[:200].lower() for word in ['method', 'function', 'property', 'class']):
            return 'api'
        else:
            return 'documentation'

    def _generate_summary(self, content: str) -> str:
        """Generate human-readable summary for first-line response"""
        lines = content.split('\n')

        # Try to extract main title and first paragraph
        title = ""
        first_paragraph = ""

        for line in lines:
            line = line.strip()
            if line.startswith('# ') and not title:
                title = line[2:].strip()
            elif line and not line.startswith('#') and not first_paragraph and len(line) > 20:
                first_paragraph = line[:100] + "..." if len(line) > 100 else line
                break

        if title and first_paragraph:
            return f"{title}: {first_paragraph}"
        elif title:
            return title
        elif first_paragraph:
            return first_paragraph
        else:
            return content[:80] + "..." if len(content) > 80 else content

    def _extract_title(self, content: str) -> str:
        """Extract the main title from content"""
        for line in content.split('\n')[:10]:  # Check first 10 lines
            line = line.strip()
            if line.startswith('# '):
                return line[2:].strip()
        # Fallback to first line
        return content.split('\n')[0][:50] + "..." if len(content.split('\n')[0]) > 50 else content.split('\n')[0]

    def _extract_tags(self, content: str, library_name: str, doc_type: str) -> list:
        """Extract relevant tags from content"""
        tags = [library_name.lower(), doc_type.lower()]

        # Add common keywords based on content analysis
        content_lower = content.lower()

        # Technology-specific tags
        if 'sqlite' in content_lower:
            tags.append('sqlite')
        if 'swift' in content_lower:
            tags.append('swift')
        if 'database' in content_lower:
            tags.append('database')
        if 'query' in content_lower:
            tags.append('querying')
        if 'migration' in content_lower:
            tags.append('migration')
        if 'sync' in content_lower:
            tags.append('synchronization')
        if 'cloudkit' in content_lower:
            tags.append('cloudkit')
        if 'grdb' in content_lower:
            tags.append('grdb')

        # Operation-specific tags
        if 'delete' in content_lower:
            tags.append('deletion')
        if 'insert' in content_lower:
            tags.append('insertion')
        if 'update' in content_lower:
            tags.append('update')
        if 'fetch' in content_lower or 'select' in content_lower:
            tags.append('fetching')

        return list(set(tags))  # Remove duplicates

    def get_statistics(self):
        """Get database statistics"""
        stats = {}

        # Patterns stats
        pattern_count = self.conn.execute('SELECT COUNT(*) FROM patterns').fetchone()[0]
        pattern_words = self.conn.execute('SELECT SUM(word_count) FROM patterns').fetchone()[0]

        # Reference stats
        reference_count = self.conn.execute('SELECT COUNT(*) FROM reference').fetchone()[0]
        reference_words = self.conn.execute('SELECT SUM(word_count) FROM reference').fetchone()[0]

        # Library breakdown
        libraries = self.conn.execute('SELECT library, COUNT(*) FROM reference GROUP BY library').fetchall()

        stats['patterns'] = {'count': pattern_count, 'words': pattern_words or 0}
        stats['reference'] = {'count': reference_count, 'words': reference_words or 0}
        stats['libraries'] = dict(libraries)
        stats['total_documents'] = pattern_count + reference_count
        stats['total_words'] = (pattern_words or 0) + (reference_words or 0)

        return stats

def main():
    parser = argparse.ArgumentParser(description='Migrate Maxwell database to hybrid schema')
    parser.add_argument('--migrate', action='store_true', help='Migrate database schema')
    parser.add_argument('--import-docs', metavar='PATH', help='Import documentation from path')
    parser.add_argument('--library', metavar='NAME', help='Library name for import')
    parser.add_argument('--stats', action='store_true', help='Show database statistics')

    args = parser.parse_args()

    db_path = Path.home() / ".claude" / "resources" / "databases" / "maxwell.db"

    if not db_path.exists():
        print(f"❌ Database not found: {db_path}")
        return 1

    migrator = MaxwellDatabaseMigrator(str(db_path))

    if args.migrate:
        migrator.migrate_to_hybrid_schema()

    if args.import_docs and args.library:
        success = migrator.import_reference_documentation(args.import_docs, args.library)
        if not success:
            return 1

    if args.stats:
        stats = migrator.get_statistics()
        print("\n📊 Maxwell Database Statistics:")
        print(f"   📚 Patterns: {stats['patterns']['count']} documents, {stats['patterns']['words']:,} words")
        print(f"   📖 Reference: {stats['reference']['count']} documents, {stats['reference']['words']:,} words")
        print(f"   📚 Libraries: {', '.join(stats['libraries'].keys())}")
        print(f"   📊 Total: {stats['total_documents']} documents, {stats['total_words']:,} words")

        for library, count in stats['libraries'].items():
            print(f"      • {library}: {count} documents")

    print("\n✅ Migration completed successfully!")
    return 0

if __name__ == '__main__':
    exit(main())