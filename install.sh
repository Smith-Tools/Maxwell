#!/bin/bash

set -e

echo "🚀 Maxwell Installation (Repository → Local Claude Skills + Database)"
echo "================================================================="
echo "📦 Version Controlled: This script lives in the repository root"
echo "🔧 Deploys: Skills, Agents, Database, and Development Tools"
echo ""

# Configuration
MAXWELL_SOURCE="/Volumes/Plutonian/_Developer/Smith Tools/Maxwell"
LOCAL_SKILL_DIR="/Users/elkraneo/.claude/skills"
LOCAL_AGENT_DIR="/Users/elkraneo/.claude/agents"
LOCAL_BIN_DIR="$HOME/.local/bin"
DB_DIR="$MAXWELL_SOURCE/database"
LOCAL_DB_DIR="$HOME/.claude/resources/databases"

# Validate source directory
if [ ! -d "$MAXWELL_SOURCE" ]; then
    echo "❌ Maxwell source not found: $MAXWELL_SOURCE"
    exit 1
fi

echo "📋 Source validated: $MAXWELL_SOURCE"

# 1. Clean previous installation
echo "🧹 Cleaning previous installation..."
rm -rf "$LOCAL_SKILL_DIR/maxwell-pointfree"
rm -rf "$LOCAL_SKILL_DIR/maxwell-shareplay"
rm -rf "$LOCAL_SKILL_DIR/maxwell-architect"
rm -rf "$LOCAL_AGENT_DIR/maxwell-tca"
mkdir -p "$LOCAL_SKILL_DIR"
mkdir -p "$LOCAL_AGENT_DIR"
mkdir -p "$LOCAL_BIN_DIR"
mkdir -p "$LOCAL_DB_DIR"

# 2. Deploy Skills
echo "🏗️ Deploying Maxwell Skills..."

# Deploy Point-Free skill (includes TCA)
echo "   📦 skill-pointfree (includes TCA authority)..."
mkdir -p "$LOCAL_SKILL_DIR/maxwell-pointfree"
cp -r "$MAXWELL_SOURCE/skills/skill-pointfree/"* "$LOCAL_SKILL_DIR/maxwell-pointfree/"

# Deploy SharePlay skill
echo "   📦 skill-shareplay..."
mkdir -p "$LOCAL_SKILL_DIR/maxwell-shareplay"
cp -r "$MAXWELL_SOURCE/skills/skill-shareplay/"* "$LOCAL_SKILL_DIR/maxwell-shareplay/"

# Deploy Architectural skill
echo "   📦 skill-architectural..."
mkdir -p "$LOCAL_SKILL_DIR/maxwell-architectural"
cp -r "$MAXWELL_SOURCE/skills/skill-architectural/"* "$LOCAL_SKILL_DIR/maxwell-architectural/"

# 3. Deploy Agents
echo "🤖 Deploying Maxwell Agents..."

# Deploy TCA agent
echo "   📦 maxwell-tca agent..."
mkdir -p "$LOCAL_AGENT_DIR/maxwell-tca"
cp "$MAXWELL_SOURCE/agent/maxwell-tca.md" "$LOCAL_AGENT_DIR/maxwell-tca/"

# 4. Setup Database
echo "🗄️ Setting up Maxwell Database..."

# Copy database files
echo "   📋 Copying database schema and tools..."
cp "$MAXWELL_SOURCE/database/SimpleDatabase.swift" "$LOCAL_DB_DIR/"
cp "$MAXWELL_SOURCE/database/DatabaseSchema.sql" "$LOCAL_DB_DIR/"
cp "$MAXWELL_SOURCE/database/HybridKnowledgeRouter.swift" "$LOCAL_DB_DIR/"
cp "$MAXWELL_SOURCE/database/QueryClassifier.swift" "$LOCAL_DB_DIR/"

# Initialize database if it doesn't exist
DB_PATH="$LOCAL_DB_DIR/maxwell.db"
if [ ! -f "$DB_PATH" ]; then
    echo "   🔨 Initializing Maxwell database..."
    cd "$LOCAL_DB_DIR"
    swift init-db.swift
else
    echo "   ✅ Database already exists at $DB_PATH"
fi

echo ""
echo "🎉 Installation Complete!"
echo "=================================="
echo ""
echo "📚 Local Skills Directory: $LOCAL_SKILL_DIR"
echo "🤖 Local Agents Directory: $LOCAL_AGENT_DIR"
echo "🗄️ Database: $LOCAL_DB_DIR/maxwell.db"
echo ""
echo "💡 Next Steps:"
echo "   1. Test skills: Ask Claude about TCA, SharePlay, or Maxwell architecture"
echo "   2. Add patterns: Use database tools to expand knowledge"
echo "   3. Create new specialists: Follow skill-pointfree pattern"