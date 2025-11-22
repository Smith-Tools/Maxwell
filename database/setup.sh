#!/bin/bash

# Maxwell Database Setup Script
#
# This script sets up the SQLite database and migrates all documentation
# from TCA and Smith frameworks into the unified Maxwell knowledge base.

set -e  # Exit on any error

echo "🔧 Maxwell Database Setup"
echo "=========================="

# Check if we're in the right directory
if [[ ! -f "Package.swift" ]]; then
    echo "❌ Error: Please run this script from the database directory"
    echo "   Expected to find Package.swift in current directory"
    exit 1
fi

# Check if Swift is available
if ! command -v swift &> /dev/null; then
    echo "❌ Error: Swift is not installed or not in PATH"
    echo "   Please install Swift from https://swift.org/download/"
    exit 1
fi

# Check if the source documentation directories exist
TCA_PATH="/Volumes/Plutonian/_Developer/Maxwells/TCA"
SMITH_PATH="/Volumes/Plutonian/_Developer/_deprecated/Smith"

echo "🔍 Checking source directories..."

if [[ ! -d "$TCA_PATH" ]]; then
    echo "⚠️  Warning: TCA directory not found at $TCA_PATH"
    echo "   TCA documentation migration will be skipped"
else
    echo "✅ TCA directory found: $TCA_PATH"
fi

if [[ ! -d "$SMITH_PATH" ]]; then
    echo "⚠️  Warning: Smith directory not found at $SMITH_PATH"
    echo "   Smith documentation migration will be skipped"
else
    echo "✅ Smith directory found: $SMITH_PATH"
fi

# Create database directory
DB_DIR="/Volumes/Plutonian/_Developer/Maxwells/database"
mkdir -p "$DB_DIR"

echo "📦 Resolving Swift packages..."

# Resolve Swift packages
swift package resolve

echo "🏗️  Building migration tool..."

# Build the migration tool
swift build -c release

echo "🚀 Starting database migration..."

# Create database directory if it doesn't exist
mkdir -p "$DB_DIR"

# Run the migration
if [[ -f ".build/release/MaxwellMigrator" ]]; then
    .build/release/MaxwellMigrator
elif [[ -f ".build/debug/MaxwellMigrator" ]]; then
    .build/debug/MaxwellMigrator
else
    echo "❌ Error: Could not find MaxwellMigrator executable"
    echo "   Trying to build in debug mode..."
    swift build
    if [[ -f ".build/debug/MaxwellMigrator" ]]; then
        .build/debug/MaxwellMigrator
    else
        echo "❌ Build failed. Please check the build output above."
        exit 1
    fi
fi

echo ""
echo "✅ Setup completed successfully!"
echo ""
echo "📁 Database location: $DB_DIR/maxwell.db"
echo ""
echo "🔍 Query examples:"
echo "   sqlite3 $DB_DIR/maxwell.db 'SELECT COUNT(*) FROM documents;'"
echo "   sqlite3 $DB_DIR/maxwell.db 'SELECT category, COUNT(*) FROM documents GROUP BY category;'"
echo ""
echo "📖 Usage in Swift code:"
echo "   let db = try MaxwellDatabase(databasePath: \"$DB_DIR/maxwell.db\")"
echo "   let docs = try db.searchDocuments(query: \"@Bindable\")"
echo ""
echo "🧪 Test the database:"
echo "   swift test"