#!/bin/bash

# SharePlay Skill & Agent Installation Script
# Installs the Maxwell SharePlay skill and agent to Claude's directories

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Paths
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SOURCE_DIR="$SOURCE_DIR/skill"
AGENT_SOURCE_DIR="$SOURCE_DIR/agent"
SKILL_TARGET_DIR="$HOME/.claude/skills/maxwell-shareplay"
AGENT_TARGET_DIR="$HOME/.claude/agents"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if source directories exist
check_prerequisites() {
    log_info "Checking prerequisites..."

    if [[ ! -d "$SKILL_SOURCE_DIR" ]]; then
        log_error "Skill source directory not found: $SKILL_SOURCE_DIR"
        exit 1
    fi

    if [[ ! -d "$AGENT_SOURCE_DIR" ]]; then
        log_error "Agent source directory not found: $AGENT_SOURCE_DIR"
        exit 1
    fi

    # Check if Claude directories exist, create if they don't
    if [[ ! -d "$HOME/.claude" ]]; then
        log_warning "Claude directory not found, creating: $HOME/.claude"
        mkdir -p "$HOME/.claude"
    fi

    log_success "Prerequisites check passed"
}

# Install skill
install_skill() {
    log_info "Installing Maxwell SharePlay skill..."

    # Remove existing target directory if it exists to ensure clean replacement
    if [[ -d "$SKILL_TARGET_DIR" ]]; then
        log_info "Removing existing skill installation at: $SKILL_TARGET_DIR"
        rm -rf "$SKILL_TARGET_DIR"
    fi

    # Create target directory
    mkdir -p "$SKILL_TARGET_DIR"

    # Copy skill contents
    log_info "Copying skill files from $SKILL_SOURCE_DIR to $SKILL_TARGET_DIR"

    # Use rsync to preserve permissions and exclude .DS_Store files
    rsync -av --exclude='.DS_Store' --exclude='*.tmp' --exclude='*.log' \
          "$SKILL_SOURCE_DIR/" "$SKILL_TARGET_DIR/"

    # Set proper permissions
    chmod -R 755 "$SKILL_TARGET_DIR"

    log_success "Skill installed to: $SKILL_TARGET_DIR"
}

# Install agent
install_agent() {
    log_info "Installing Maxwell SharePlay agent..."

    # Remove existing agent files if they exist to ensure clean replacement
    if [[ -d "$AGENT_TARGET_DIR" ]]; then
        log_info "Removing existing agent installation at: $AGENT_TARGET_DIR"
        # Remove only maxwell-shareplay files to preserve other agents
        rm -f "$AGENT_TARGET_DIR"/maxwell-shareplay*
    fi

    # Create target directory
    mkdir -p "$AGENT_TARGET_DIR"

    # Copy agent contents
    log_info "Copying agent files from $AGENT_SOURCE_DIR to $AGENT_TARGET_DIR"

    # Copy all agent files
    rsync -av --exclude='.DS_Store' --exclude='*.tmp' --exclude='*.log' \
          "$AGENT_SOURCE_DIR/" "$AGENT_TARGET_DIR/"

    # Set proper permissions
    chmod -R 755 "$AGENT_TARGET_DIR"

    log_success "Agent installed to: $AGENT_TARGET_DIR"
}

# Verify installation
verify_installation() {
    log_info "Verifying installation..."

    # Check skill installation
    if [[ -f "$SKILL_TARGET_DIR/SKILL.md" ]]; then
        log_success "✓ Skill main file found"
    else
        log_error "✗ Skill main file (SKILL.md) not found"
        return 1
    fi

    # Check snippets directory
    if [[ -d "$SKILL_TARGET_DIR/snippets" ]]; then
        local snippet_count=$(find "$SKILL_TARGET_DIR/snippets" -name "*.swift" | wc -l)
        log_success "✓ Found $snippet_count Swift code snippets"
    else
        log_warning "✗ Snippets directory not found"
    fi

    # Check agent installation
    if [[ -f "$AGENT_TARGET_DIR/maxwell-shareplay.md" ]]; then
        log_success "✓ Agent configuration file found"
    else
        log_error "✗ Agent configuration file not found"
        return 1
    fi

    log_success "Installation verification completed"
}

# Show installation summary
show_summary() {
    echo
    echo "🎉 Installation Complete!"
    echo "════════════════════════════════════════════════════════════════"
    echo
    echo "📍 Skill Location: $SKILL_TARGET_DIR"
    echo "📍 Agent Location: $AGENT_TARGET_DIR"
    echo
    echo "📋 What was installed:"
    echo "  • SharePlay skill with comprehensive documentation"
    echo "  • Production-ready code snippets and examples"
    echo "  • HIG compliance components and validation framework"
    echo "  • Claude agent configuration"
    echo
    echo "🚀 Next steps:"
    echo "  1. Restart Claude to load the new skill and agent"
    echo "  2. Use '/maxwell-shareplay' to access SharePlay expertise"
    echo "  3. Try 'skill: SharePlay' for specific SharePlay questions"
    echo
    echo "📚 Quick reference:"
    echo "  • Main skill documentation: $SKILL_TARGET_DIR/SKILL.md"
    echo "  • Code examples: $SKILL_TARGET_DIR/snippets/"
    echo "  • HIG guidelines: $SKILL_TARGET_DIR/hig-principles.md"
    echo "  • Agent config: $AGENT_TARGET_DIR/maxwell-shareplay.md"
    echo "════════════════════════════════════════════════════════════════"
}

# Cleanup function
cleanup() {
    if [[ $? -ne 0 ]]; then
        log_error "Installation failed. Please check the error messages above."
        echo
        echo "🔧 Manual installation steps:"
        echo "  1. Copy skill contents to: $SKILL_TARGET_DIR"
        echo "  2. Copy agent contents to: $AGENT_TARGET_DIR"
        echo "  3. Set permissions: chmod -R 755 \$TARGET_DIR"
    fi
}

# Set up cleanup trap
trap cleanup EXIT

# Main installation flow
main() {
    echo "🚀 Maxwell SharePlay Skill & Agent Installer"
    echo "════════════════════════════════════════════════════════════════"
    echo

    check_prerequisites
    echo

    install_skill
    echo

    install_agent
    echo

    if verify_installation; then
        show_summary
    else
        exit 1
    fi
}

# Run main function
main "$@"