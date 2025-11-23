#!/bin/bash

set -e

echo "🚀 Maxwell Installation (Multi-Skill Architecture v3.0)"
echo "======================================================"
echo "📦 Version Controlled: Specialized skills + Maxwell agent orchestrator"
echo "🔧 Deploys: 5 domain skills + Maxwell agent with embedded knowledge"
echo ""

# Configuration
MAXWELL_SOURCE="/Volumes/Plutonian/_Developer/Smith-Tools/Maxwell"
LOCAL_SKILL_DIR="/Users/elkraneo/.claude/skills"
LOCAL_AGENT_DIR="/Users/elkraneo/.claude/agents"

# Validate source directory
if [ ! -d "$MAXWELL_SOURCE" ]; then
    echo "❌ Maxwell source not found: $MAXWELL_SOURCE"
    exit 1
fi

# Check required components
echo "🔍 Validating Maxwell components..."
MISSING_COMPONENTS=()

# Check Maxwell agent
if [ ! -f "$MAXWELL_SOURCE/agent/maxwell.md" ]; then
    MISSING_COMPONENTS+=("agent/maxwell.md")
fi

# Check specialized skills
REQUIRED_SKILLS=("maxwell-pointfree" "maxwell-shareplay" "maxwell-swift" "maxwell-visionos" "maxwell-meta")
for skill in "${REQUIRED_SKILLS[@]}"; do
    if [ ! -d "$MAXWELL_SOURCE/skills/$skill" ]; then
        MISSING_COMPONENTS+=("skills/$skill")
    fi
done

if [ ${#MISSING_COMPONENTS[@]} -gt 0 ]; then
    echo "❌ Missing required components:"
    for component in "${MISSING_COMPONENTS[@]}"; do
        echo "   - $component"
    done
    exit 1
fi

echo "   ✅ Maxwell Agent Found"
echo "   ✅ Specialized Skills Found: ${#REQUIRED_SKILLS[@]} skills"

# 1. Create directories
echo ""
echo "📁 Creating required directories..."
mkdir -p "$LOCAL_SKILL_DIR"
mkdir -p "$LOCAL_AGENT_DIR"

# 2. Remove old installations (cleanup)
echo "🧹 Cleaning up old installations..."
echo "   Removing: Old unified skill, central knowledge base, and legacy skills"
rm -rf "$LOCAL_SKILL_DIR/maxwell-knowledge" 2>/dev/null || true
rm -rf "$LOCAL_SKILL_DIR/maxwell-knowledge-base" 2>/dev/null || true
rm -rf "$LOCAL_SKILL_DIR/maxwell-pointfree" 2>/dev/null || true
rm -rf "$LOCAL_SKILL_DIR/maxwell-shareplay" 2>/dev/null || true
rm -rf "$LOCAL_SKILL_DIR/maxwell-swift" 2>/dev/null || true
rm -rf "$LOCAL_SKILL_DIR/maxwell-visionos" 2>/dev/null || true
rm -rf "$LOCAL_SKILL_DIR/maxwell-meta" 2>/dev/null || true
rm -rf "$LOCAL_AGENT_DIR/maxwell" 2>/dev/null || true

# 3. Deploy Maxwell Agent Orchestrator
echo "🎭 Deploying Maxwell Agent Orchestrator..."
mkdir -p "$LOCAL_AGENT_DIR/maxwell"
cp -r "$MAXWELL_SOURCE/agent/"* "$LOCAL_AGENT_DIR/maxwell/"

echo "   ✅ Maxwell Agent: $LOCAL_AGENT_DIR/maxwell/"

# 4. Deploy Specialized Skills
echo ""
echo "🏗️ Deploying Specialized Skills..."

for skill in "${REQUIRED_SKILLS[@]}"; do
    skill_name=$(basename "$skill")
    echo "   Deploying: $skill_name"

    # Create skill directory
    mkdir -p "$LOCAL_SKILL_DIR/$skill_name"
    rm -rf "$LOCAL_SKILL_DIR/$skill_name"/*

    # Copy skill files
    cp -r "$MAXWELL_SOURCE/skills/$skill/"* "$LOCAL_SKILL_DIR/$skill_name/"

    # Copy embedded knowledge if it exists
    if [ -d "$MAXWELL_SOURCE/skills/$skill/knowledge" ]; then
        echo "     📚 Copying embedded knowledge for $skill_name"
        mkdir -p "$LOCAL_SKILL_DIR/$skill_name/knowledge"
        cp -r "$MAXWELL_SOURCE/skills/$skill/knowledge/"* "$LOCAL_SKILL_DIR/$skill_name/knowledge/"
        knowledge_count=$(find "$LOCAL_SKILL_DIR/$skill_name/knowledge" -name "*.md" 2>/dev/null | wc -l)
        echo "       ✅ $knowledge_count knowledge files embedded"
    else
        echo "     ⚠️  No embedded knowledge found for $skill_name"
    fi

    echo "     ✅ $skill_name: $(find "$LOCAL_SKILL_DIR/$skill_name" -name "*.md" | wc -l) files"
done

# 5. Knowledge Deployment Summary
echo ""
echo "📚 Knowledge Deployment Summary:"
total_knowledge=0
for skill in "${REQUIRED_SKILLS[@]}"; do
    skill_count=$(find "$LOCAL_SKILL_DIR/$skill/knowledge" -name "*.md" 2>/dev/null | wc -l)
    total_knowledge=$((total_knowledge + skill_count))
    echo "   ✅ $skill: $skill_count embedded knowledge files"
done
echo "   📖 Total Embedded Knowledge: $total_knowledge documents"
echo "   🏗️ Architecture: Knowledge embedded in skill directories (no central repository)"

# 6. System Status Report
echo ""
echo "📊 Maxwell Multi-Skill System Status:"
echo "   🎭 Maxwell Agent: 1 orchestrator"
echo "   🏗️ Specialized Skills: ${#REQUIRED_SKILLS[@]} domain skills"
echo "   📚 Embedded Knowledge: $total_knowledge total documents"
echo "   💾 Total Storage: $(du -sh "$LOCAL_SKILL_DIR" | cut -f1)"

# 7. Installation Success Summary
echo ""
echo "🎉 Multi-Skill Installation Complete!"
echo "====================================="
echo ""
echo "📦 Components Installed:"
echo "   ✅ Maxwell Agent: $LOCAL_AGENT_DIR/maxwell/"
echo "   ✅ Point-Free Expert: $LOCAL_SKILL_DIR/maxwell-pointfree/ (with embedded TCA knowledge)"
echo "   ✅ SharePlay Expert: $LOCAL_SKILL_DIR/maxwell-shareplay/ (with embedded collaborative knowledge)"
echo "   ✅ Swift Expert: $LOCAL_SKILL_DIR/maxwell-swift/ (ready for user content)"
echo "   ✅ visionOS Expert: $LOCAL_SKILL_DIR/maxwell-visionos/ (with embedded spatial knowledge)"
echo "   ✅ Meta Expert: $LOCAL_SKILL_DIR/maxwell-meta/ (with embedded self-reflection knowledge)"
echo "   🏗️ Architecture: Knowledge embedded in skill directories (no central repository)"
echo ""

echo "🎯 Multi-Skill Architecture Benefits:"
echo "   🧠 Specialized Expertise: Each skill focuses on its domain"
echo "   🔄 Agent Orchestration: Maxwell coordinates cross-domain queries"
echo "   📊 Size Optimization: Skills stay within memory constraints"
echo "   🎯 Auto-Triggering: Skills activate on domain keywords"
echo "   🔗 Mix-and-Match: Agent synthesizes knowledge from multiple skills"

echo "💡 Usage Examples:"
echo "   Single Domain (Skill Auto-Triggered):"
echo "     'How do I implement @Shared state in TCA?' → maxwell-pointfree activates"
echo "     'How do I create Spatial Personas?' → maxwell-visionos activates"
echo ""
echo "   Cross-Domain (Agent Orchestrated):"
echo "     'Build collaborative TCA app with SharePlay' → Maxwell orchestrates both skills"
echo "     'Architecture decision for visionOS spatial app' → Maxwell synthesizes 3 skills"

echo "🚀 Maxwell Agent Orchestration:"
echo "   🎭 Maxwell agent coordinates specialized skills"
echo "   🔗 Cross-domain knowledge synthesis"
echo "   📈 Progressive learning through prerequisite chains"
echo "   🎯 Decision frameworks with quantitative criteria"

echo "🔧 Skill Auto-Trigger Keywords:"
echo "   🔥 maxwell-pointfree: Point-Free, TCA, @Shared, @Bindable, Reducer, TestStore"
echo "   🚀 maxwell-shareplay: SharePlay, GroupActivities, collaborative, multiplayer"
echo "   🌟 maxwell-swift: Swift macros, meta-programming, code generation, Smith, architecture"
echo "   👓 maxwell-visionos: visionOS, RealityKit, ARKit, Spatial Personas, immersive"
echo "   🧠 maxwell-meta: Maxwell, self-reflection, skill coordination, knowledge synthesis"

echo "🎯 Ready for Mixed-Domain Queries!"
echo "   • Single Domain: Skills auto-trigger on keywords"
echo "   • Multi-Domain: Maxwell orchestrates multiple skills"
echo "   • Complex Integration: Agent synthesizes knowledge and provides decision frameworks"

echo "🔗 Quick Test:"
echo "   Ask Claude: 'How do I implement @Shared state in TCA?' (Single skill)"
echo "   Ask Claude: 'Build collaborative TCA app with SharePlay' (Agent orchestration)"
echo "   Ask Claude: 'Architecture patterns for visionOS spatial computing' (3-skill synthesis)"