#!/bin/bash

set -e

echo "🚀 Maxwell v4.0 Installation"
echo "=============================="
echo "📦 Personal discovery knowledge base - file-based architecture"
echo ""

# Configuration
MAXWELL_SOURCE="/Volumes/Plutonian/_Developer/Smith-Tools/Maxwell"
MAXWELL_DATA="/Volumes/Plutonian/_Developer/Smith-Tools/Maxwell-data-private"
DEST_SKILLS="$HOME/.claude/skills"
DEST_DISCOVERIES="$HOME/.claude/resources/discoveries"

# Validate source directories
if [ ! -d "$MAXWELL_SOURCE" ]; then
    echo "❌ Maxwell source not found: $MAXWELL_SOURCE"
    exit 1
fi

if [ ! -d "$MAXWELL_DATA" ]; then
    echo "❌ Maxwell data not found: $MAXWELL_DATA"
    exit 1
fi

# 1. Clean up old Maxwell installations
echo "🧹 Cleaning old Maxwell installations..."
rm -rf "$DEST_SKILLS/maxwell-knowledge" 2>/dev/null || true
rm -rf "$DEST_SKILLS/maxwell-librarian" 2>/dev/null || true
rm -rf "$DEST_SKILLS/maxwell-meta" 2>/dev/null || true
rm -rf "$DEST_SKILLS/maxwell" 2>/dev/null || true
rm -rf "$DEST_DISCOVERIES" 2>/dev/null || true
if [ -f "$HOME/.claude/resources/databases/maxwell.db" ]; then
    mv "$HOME/.claude/resources/databases/maxwell.db" \
       "$HOME/.claude/resources/databases/maxwell-v3-ARCHIVED.db" 2>/dev/null || true
fi
echo "   ✅ Old installations cleaned"

# 2. Create directories
echo "📁 Creating directories..."
mkdir -p "$DEST_SKILLS"
mkdir -p "$DEST_DISCOVERIES"
mkdir -p "$HOME/.local/bin"
echo "   ✅ Directories created"

# 3. Deploy Maxwell skill
echo "📦 Deploying Maxwell v4.0 skill..."
if [ ! -d "$MAXWELL_SOURCE/skills/maxwell" ]; then
    echo "   ❌ Maxwell skill not found at $MAXWELL_SOURCE/skills/maxwell"
    exit 1
fi

cp -r "$MAXWELL_SOURCE/skills/maxwell" "$DEST_SKILLS/"
echo "   ✅ Skill deployed to $DEST_SKILLS/maxwell/"

# 3b. Deploy Maxwell CLI wrapper
echo "📦 Deploying Maxwell CLI wrapper..."
if [ ! -f "$MAXWELL_SOURCE/cli/maxwell" ]; then
    echo "   ⚠️  Maxwell CLI wrapper not found at $MAXWELL_SOURCE/cli/maxwell"
    echo "   Skipping CLI deployment (not required for basic functionality)"
else
    cp "$MAXWELL_SOURCE/cli/maxwell" "$HOME/.local/bin/maxwell"
    chmod +x "$HOME/.local/bin/maxwell"
    echo "   ✅ Maxwell CLI deployed to $HOME/.local/bin/maxwell"

    # Add ~/.local/bin to PATH if needed
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        echo ""
        echo "   ⚠️  Note: $HOME/.local/bin is not in your PATH"
        echo "   Add to your shell profile (.bashrc, .zshrc, etc):"
        echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
fi

# 4. Deploy discovery data
echo "📚 Deploying personal discoveries..."
DISCOVERY_COUNT=$(find "$MAXWELL_DATA" -maxdepth 1 -name "*.md" -type f | wc -l | tr -d ' ')

if [ "$DISCOVERY_COUNT" -eq 0 ]; then
    echo "   ⚠️  No discovery files found in $MAXWELL_DATA"
else
    cp "$MAXWELL_DATA"/*.md "$DEST_DISCOVERIES/" 2>/dev/null || true
    echo "   ✅ Deployed $DISCOVERY_COUNT discovery files"
fi

# 5. Verify installation
echo "🔍 Verifying installation..."

if [ ! -f "$DEST_SKILLS/maxwell/SKILL.md" ]; then
    echo "   ❌ Skill verification failed: SKILL.md not found"
    exit 1
fi
echo "   ✅ Skill verified"

INSTALLED_COUNT=$(find "$DEST_DISCOVERIES" -maxdepth 1 -name "*.md" -type f | wc -l | tr -d ' ')
if [ "$INSTALLED_COUNT" -eq 0 ]; then
    echo "   ⚠️  No discoveries installed (data directory may be empty)"
else
    echo "   ✅ $INSTALLED_COUNT discoveries installed"
fi

# 6. Success summary
echo ""
echo "✅ Maxwell v4.0 installed successfully!"
echo ""
echo "📍 Locations:"
echo "   Source: $MAXWELL_SOURCE"
echo "   Data: $MAXWELL_DATA"
echo "   Skill: $DEST_SKILLS/maxwell/"
echo "   Discoveries: $DEST_DISCOVERIES/"
echo ""
echo "🎯 Next steps:"
echo "   1. Ask Claude about Swift/TCA to test Maxwell"
echo "   2. Maxwell will automatically search your discoveries"
echo "   3. Add new discoveries to Maxwell-data-private/ then reinstall"
echo ""
echo "📚 Documentation:"
echo "   Skill: $DEST_SKILLS/maxwell/README.md"
echo "   Discovery policy: $DEST_DISCOVERIES/DISCOVERY-POLICY.md"
echo ""
echo "🔄 To update:"
echo "   1. Add new discoveries to Maxwell-data-private/"
echo "   2. Commit changes: git add *.md && git commit && git push"
echo "   3. Reinstall: cd $MAXWELL_SOURCE && ./install.sh"
