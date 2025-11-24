#!/usr/bin/env python3
"""
Maxwell Librarian Skill - Simplified Test Version
Private knowledge base management for importing documentation, detecting duplicates, and synthesizing patterns
"""

import sys
import os
from pathlib import Path

# Add the tools directory to the path
skill_dir = Path(__file__).parent
tools_dir = skill_dir / "tools"
sys.path.insert(0, str(tools_dir))

class MaxwellLibrarianSimple:
    """Simplified skill interface for Maxwell Librarian"""

    def __init__(self):
        print("🔧 Maxwell Librarian - Simplified Test Version")
        print("📍 Skills directory:", skill_dir)
        print("🔧 Tools directory:", tools_dir)
        print("📄 Available tools:", [f.name for f in tools_dir.glob("*.py")])

    def test_basic_functionality(self):
        """Test basic skill functionality"""
        print(f"\n🧪 Testing Basic Functionality")
        print(f"=" * 40)

        # Test 1: Check directory structure
        print(f"📁 Directory Structure Check:")
        print(f"   ✅ Skill directory exists: {skill_dir.exists()}")
        print(f"   ✅ Tools directory exists: {tools_dir.exists()}")
        print(f"   ✅ SKILL.md exists: {(skill_dir / 'SKILL.md').exists()}")

        # Test 2: Check tool files
        tool_files = list(tools_dir.glob("*.py"))
        print(f"   ✅ Tool files found: {len(tool_files)}")
        for tool_file in tool_files:
            print(f"      📄 {tool_file.name}")

        # Test 3: Try to import a simple module
        print(f"\n🔧 Module Import Test:")
        try:
            import sqlite3
            print(f"   ✅ sqlite3 module available")
        except ImportError as e:
            print(f"   ❌ sqlite3 import error: {e}")

        # Test 4: Check database path
        db_path = Path.home() / ".claude" / "resources" / "databases" / "maxwell.db"
        print(f"   ✅ Database path: {db_path}")
        print(f"   ✅ Database exists: {db_path.exists()}")

        if db_path.exists():
            try:
                conn = sqlite3.connect(str(db_path))
                cursor = conn.execute("SELECT name FROM sqlite_master WHERE type='table'")
                tables = [row[0] for row in cursor.fetchall()]
                print(f"   ✅ Database tables: {tables}")
                conn.close()
            except Exception as e:
                print(f"   ⚠️ Database connection error: {e}")

        return True

    def show_help(self):
        """Show help information"""
        print("Maxwell Librarian - Private Knowledge Base Management")
        print("=" * 60)
        print("\nAvailable Commands (Simplified Version):")
        print("  test                          - Test basic functionality")
        print("  help                          - Show this help")
        print("\nFull Version Commands:")
        print("  import <docs_path> <library>  - Import documentation")
        print("  check-duplicates <path> <lib> - Analyze duplicates")
        print("  validate <library>            - Validate library")
        print("  report <library>              - Generate report")
        print("  health                        - Check knowledge base health")

def main():
    """Main skill entry point"""
    if len(sys.argv) < 2:
        librarian = MaxwellLibrarianSimple()
        librarian.show_help()
        return 0

    command = sys.argv[1]
    librarian = MaxwellLibrarianSimple()

    try:
        if command == "test":
            success = librarian.test_basic_functionality()
            return 0 if success else 1

        elif command == "help":
            librarian.show_help()
            return 0

        else:
            print(f"ℹ️ Command '{command}' available in full version")
            print("Use 'help' to see available commands in this simplified version")
            return 0

    except KeyboardInterrupt:
        print(f"\n❌ Operation cancelled by user")
        return 1
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == '__main__':
    exit(main())