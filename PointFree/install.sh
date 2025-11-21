#!/bin/bash

# PointFree Module Installation Script
# Installs maxwell-pointfree skill and agent in Claude

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Installing PointFree Maxwell Module...${NC}"

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SKILL_DIR="${SCRIPT_DIR}/skill"
AGENT_DIR="${SCRIPT_DIR}/agent"

# Check if directories exist
if [ ! -d "$SKILL_DIR" ]; then
    echo -e "${RED}❌ Skill directory not found: $SKILL_DIR${NC}"
    exit 1
fi

if [ ! -d "$AGENT_DIR" ]; then
    echo -e "${RED}❌ Agent directory not found: $AGENT_DIR${NC}"
    exit 1
fi

# Create Claude directories if they don't exist
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
AGENTS_DIR="$CLAUDE_DIR/agents"

echo -e "${YELLOW}📁 Creating Claude directories...${NC}"
mkdir -p "$SKILLS_DIR"
mkdir -p "$AGENTS_DIR"

# Install skill
echo -e "${YELLOW}🔧 Installing maxwell-pointfree skill...${NC}"
if [ -L "$SKILLS_DIR/maxwell-pointfree" ]; then
    echo -e "${YELLOW}⚠️  Removing existing skill symlink...${NC}"
    rm "$SKILLS_DIR/maxwell-pointfree"
fi

ln -sf "$SKILL_DIR" "$SKILLS_DIR/maxwell-pointfree"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Skill installed successfully${NC}"
else
    echo -e "${RED}❌ Failed to install skill${NC}"
    exit 1
fi

# Install agent
echo -e "${YELLOW}🔧 Installing maxwell-pointfree agent...${NC}"
if [ -L "$AGENTS_DIR/maxwell-pointfree.md" ]; then
    echo -e "${YELLOW}⚠️  Removing existing agent symlink...${NC}"
    rm "$AGENTS_DIR/maxwell-pointfree.md"
fi

AGENT_FILE="$AGENT_DIR/maxwell-pointfree.md"
if [ -f "$AGENT_FILE" ]; then
    ln -sf "$AGENT_FILE" "$AGENTS_DIR/maxwell-pointfree.md"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Agent installed successfully${NC}"
    else
        echo -e "${RED}❌ Failed to install agent${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Agent file not found: $AGENT_FILE${NC}"
    exit 1
fi

# Verify installation
echo -e "${YELLOW}🔍 Verifying installation...${NC}"

if [ -L "$SKILLS_DIR/maxwell-pointfree" ] && [ -d "$SKILLS_DIR/maxwell-pointfree" ]; then
    echo -e "${GREEN}✅ Skill link verified${NC}"
else
    echo -e "${RED}❌ Skill link verification failed${NC}"
fi

if [ -L "$AGENTS_DIR/maxwell-pointfree.md" ] && [ -f "$AGENTS_DIR/maxwell-pointfree.md" ]; then
    echo -e "${GREEN}✅ Agent link verified${NC}"
else
    echo -e "${RED}❌ Agent link verification failed${NC}"
fi

# Check if required skills exist
echo -e "${YELLOW}🔍 Checking dependencies...${NC}"

if [ -d "$SKILLS_DIR/maxwell-tca" ]; then
    echo -e "${GREEN}✅ maxwell-tca skill found${NC}"
else
    echo -e "${YELLOW}⚠️  maxwell-tca skill not found - TCA delegation will be limited${NC}"
fi

# Show installation summary
echo ""
echo -e "${BLUE}🎉 PointFree Module Installation Complete!${NC}"
echo ""
echo -e "${GREEN}📍 Installed Components:${NC}"
echo -e "  • Skill: $SKILLS_DIR/maxwell-pointfree"
echo -e "  • Agent: $AGENTS_DIR/maxwell-pointfree.md"
echo ""
echo -e "${BLUE}🚀 Usage:${NC}"
echo -e "  • Skill: ${YELLOW}skill: \"maxwell-pointfree\"${NC}"
echo -e "  • Agent: Available in Claude agent delegation"
echo ""
echo -e "${BLUE}📚 Features:${NC}"
echo -e "  • Framework detection and routing"
echo -e "  • Specialist delegation (TCA, Dependencies, Navigation)"
echo -e "  • Integration pattern synthesis"
echo -e "  • Cross-framework validation"
echo ""
echo -e "${GREEN}✨ Ready to coordinate Point-Free ecosystem development!${NC}"