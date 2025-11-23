#!/bin/bash

set -e

echo "🚀 Maxwell Installation (Complete Setup: Binary + Database + Skills)"
echo "===================================================================="
echo "📦 Version Controlled: This script lives in the repository root"
echo "🔧 Deploys: Swift CLI Binary, Database, Skills, and Agents"
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

if [ ! -d "$DB_DIR" ]; then
    echo "❌ Maxwell database directory not found: $DB_DIR"
    exit 1
fi

echo "📋 Source validated: $MAXWELL_SOURCE"

# 1. Create directories
echo "📁 Creating required directories..."
mkdir -p "$LOCAL_SKILL_DIR"
mkdir -p "$LOCAL_AGENT_DIR"
mkdir -p "$LOCAL_BIN_DIR"
mkdir -p "$LOCAL_DB_DIR"

# 2. Build Maxwell CLI Binary
echo "🔨 Building maxwell-cli binary from Swift..."
cd "$DB_DIR"

if ! swift build --configuration release 2>/dev/null; then
    echo "❌ Failed to build maxwell-cli binary"
    exit 1
fi

# Copy binary to PATH
BINARY_PATH="$DB_DIR/.build/release/Maxwell"
if [ ! -f "$BINARY_PATH" ]; then
    echo "❌ Built binary not found at $BINARY_PATH"
    exit 1
fi

echo "📦 Installing maxwell binary to $LOCAL_BIN_DIR..."
cp "$BINARY_PATH" "$LOCAL_BIN_DIR/maxwell"
chmod +x "$LOCAL_BIN_DIR/maxwell"

# Verify binary is accessible
if ! command -v maxwell &> /dev/null; then
    echo "⚠️  maxwell binary not in PATH. Add this to your shell profile:"
    echo "   export PATH=\"$LOCAL_BIN_DIR:\$PATH\""
fi

# 3. Deploy Database
echo "🗄️ Setting up Maxwell Database..."

# Copy version-controlled database
DB_PATH="$LOCAL_DB_DIR/maxwell.db"
echo "   📋 Copying version-controlled database to $DB_PATH..."
cp "$MAXWELL_SOURCE/database/maxwell.db" "$DB_PATH"

# Verify database integrity
echo "   🔍 Verifying database integrity..."
DOC_COUNT=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM documents;" 2>/dev/null || echo "0")
if [ "$DOC_COUNT" -eq 0 ]; then
    echo "   ⚠️ Database appears empty, initializing..."
    cd "$DB_DIR" && maxwell init
fi

# 4. Deploy Skills
echo "🏗️ Deploying Maxwell Skills..."

# Deploy Point-Free skill (includes TCA)
echo "   📦 skill-pointfree (TCA authority)..."
mkdir -p "$LOCAL_SKILL_DIR/maxwell-pointfree"
rm -rf "$LOCAL_SKILL_DIR/maxwell-pointfree"/*
cp -r "$MAXWELL_SOURCE/skills/skill-pointfree/"* "$LOCAL_SKILL_DIR/maxwell-pointfree/" 2>/dev/null || true

# Deploy SharePlay skill
echo "   📦 skill-shareplay..."
mkdir -p "$LOCAL_SKILL_DIR/maxwell-shareplay"
rm -rf "$LOCAL_SKILL_DIR/maxwell-shareplay"/*
cp -r "$MAXWELL_SOURCE/skills/skill-shareplay/"* "$LOCAL_SKILL_DIR/maxwell-shareplay/" 2>/dev/null || true

# Deploy Meta skill
echo "   📦 skill-meta (Maxwell's own meta-knowledge)..."
mkdir -p "$LOCAL_SKILL_DIR/maxwell-meta"
rm -rf "$LOCAL_SKILL_DIR/maxwell-meta"/*
cp -r "$MAXWELL_SOURCE/skills/skill-meta/"* "$LOCAL_SKILL_DIR/maxwell-meta/" 2>/dev/null || true

# 5. Deploy Agents
echo "🤖 Deploying Maxwell Agent..."

# Deploy Maxwell agent (main coordinator)
echo "   📦 maxwell (multi-skill coordinator)..."
mkdir -p "$LOCAL_AGENT_DIR"
cp "$MAXWELL_SOURCE/agent/maxwell.md" "$LOCAL_AGENT_DIR/maxwell.md"

# 6. Verify Installation
echo ""
echo "🔍 Verifying installation..."

if [ ! -f "$LOCAL_BIN_DIR/maxwell" ]; then
    echo "❌ maxwell binary not found"
    exit 1
fi

if [ ! -f "$DB_PATH" ]; then
    echo "❌ maxwell.db not found"
    exit 1
fi

if [ ! -d "$LOCAL_SKILL_DIR/maxwell-meta" ]; then
    echo "❌ skill-meta not found"
    exit 1
fi

echo ""
echo "🎉 Installation Complete!"
echo "===================================="
echo ""
echo "📦 Components Installed:"
echo "   ✅ maxwell CLI binary: $LOCAL_BIN_DIR/maxwell"
echo "   ✅ Database: $DB_PATH"
echo "   ✅ Skills: $LOCAL_SKILL_DIR/"
echo "   ✅ Agent: $LOCAL_AGENT_DIR/maxwell.md"
echo ""
echo "📊 Database Status:"
maxwell domain TCA 2>/dev/null | head -3 || echo "   (Database patterns will appear here after next run)"
echo ""
echo "💡 Next Steps:"
echo "   1. Verify binary: maxwell search \"TCA @Shared\""
echo "   2. Test with Claude: Ask about TCA or SharePlay"
echo "   3. Maxwell skills will auto-trigger on framework keywords"
echo "   4. Maxwell agent is available for complex multi-domain questions"
echo ""
echo "🔗 Quick Commands:"
echo "   maxwell search \"pattern query\"                    # Search all patterns"
echo "   maxwell domain TCA                                  # List TCA patterns"
echo "   maxwell pattern \"Pattern Name\"                    # Find specific pattern"