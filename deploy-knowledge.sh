#!/bin/bash

set -e

echo "🧠 Maxwell Knowledge Deployment Script"
echo "====================================="
echo "🔄 Deploying from Maxwell-data-private to Claude knowledge repository"

# Configuration
MAXWELL_DATA_SOURCE="/Volumes/Plutonian/_Developer/Smith-Tools/Maxwell-data-private"
CLAUDE_KNOWLEDGE_TARGET="/Users/elkraneo/.claude/resources/knowledge/maxwell"
MAXWELL_SKILL_KNOWLEDGE="/Users/elkraneo/.claude/skills/maxwell-knowledge/knowledge"

# Validate source directory
if [ ! -d "$MAXWELL_DATA_SOURCE" ]; then
    echo "❌ Maxwell data source not found: $MAXWELL_DATA_SOURCE"
    exit 1
fi

# Create target directories
echo "📁 Creating target directories..."
mkdir -p "$CLAUDE_KNOWLEDGE_TARGET"
mkdir -p "$MAXWELL_SKILL_KNOWLEDGE"

# 1. Deploy knowledge files to Claude repository
echo "📚 Copying knowledge files to Claude repository..."
# Remove existing files to ensure clean sync
rm -rf "$CLAUDE_KNOWLEDGE_TARGET"/*
# Copy new files
cp -r "$MAXWELL_DATA_SOURCE"/* "$CLAUDE_KNOWLEDGE_TARGET/"

# Count deployed files
DEPLOYED_COUNT=$(find "$CLAUDE_KNOWLEDGE_TARGET" -name "*.md" | wc -l)
echo "   ✅ Deployed $DEPLOYED_COUNT knowledge files"

# 2. Update Maxwell knowledge database
echo "🗄️  Updating Maxwell knowledge database..."
cd "$MAXWELL_SKILL_KNOWLEDGE"
if [ -f "maxwell-knowledge-base.py" ]; then
    python3 maxwell-knowledge-base.py --update

    # Show database statistics
    python3 maxwell-knowledge-base.py --stats

    echo "   ✅ Database updated successfully"
else
    echo "   ⚠️  maxwell-knowledge-base.py not found, skipping database update"
fi

# 3. Deploy updated skill (if needed)
echo "🔧 Ensuring Maxwell skill is deployed..."
MAXWELL_INSTALL_SCRIPT="/Volumes/Plutonian/_Developer/Smith-Tools/Maxwell/install.sh"
if [ -f "$MAXWELL_INSTALL_SCRIPT" ]; then
    echo "   Running Maxwell installation script..."
    "$MAXWELL_INSTALL_SCRIPT"
else
    echo "   ⚠️  Maxwell install script not found"
fi

# 4. Verification
echo ""
echo "🔍 Verification Results:"
echo "   Source: $MAXWELL_DATA_SOURCE ($(find "$MAXWELL_DATA_SOURCE" -name "*.md" | wc -l) files)"
echo "   Target: $CLAUDE_KNOWLEDGE_TARGET ($(find "$CLAUDE_KNOWLEDGE_TARGET" -name "*.md" | wc -l) files)"
echo "   Database: $MAXWELL_SKILL_KNOWLEDGE/maxwell.db"

# Check database integrity
if [ -f "/Users/elkraneo/.claude/resources/databases/maxwell.db" ]; then
    DB_COUNT=$(sqlite3 /Users/elkraneo/.claude/resources/databases/maxwell.db "SELECT COUNT(*) FROM knowledge;" 2>/dev/null || echo "0")
    echo "   Database records: $DB_COUNT"
fi

echo ""
echo "✅ Knowledge deployment complete!"
echo ""
echo "💡 Usage:"
echo "   @agent-maxwell 'your question here' - Natural language queries"
echo "   @skill-maxwell-knowledge 'specific query' - Direct database access"
echo ""
echo "🔄 Workflow:"
echo "   1. Add/edit files in: $MAXWELL_DATA_SOURCE"
echo "   2. Run: ./deploy-knowledge.sh"
echo "   3. Test with Maxwell agent"