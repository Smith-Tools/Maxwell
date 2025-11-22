#!/bin/bash

# TCA Skill & Agent Installation Script
# Installs the TCA skill and agent to Claude's directories

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
SKILL_TARGET_DIR="$HOME/.claude/skills/maxwell-tca"

# Agent source - check project-level directories first, then user-level
# (agent can be in TCA project root Maxwells/.claude, TCA source/.claude, or TCA source/agent/)
PROJECT_ROOT_AGENT_DIR="$(dirname "$(dirname "$SOURCE_DIR")")/.claude/agents"
PROJECT_AGENT_DIR="$SOURCE_DIR/.claude/agents"
TCA_AGENT_DIR="$SOURCE_DIR/agent"
USER_AGENT_FILE="$HOME/.claude/agents/maxwell-tca.md"
AGENT_SOURCE_FILE=""

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

    # Check for agent source file (multiple locations supported)
    if [[ -f "$TCA_AGENT_DIR/maxwell-tca.md" ]]; then
        AGENT_SOURCE_FILE="$TCA_AGENT_DIR/maxwell-tca.md"
        log_info "Found agent at: $AGENT_SOURCE_FILE"
    elif [[ -f "$PROJECT_AGENT_DIR/maxwell-tca.md" ]]; then
        AGENT_SOURCE_FILE="$PROJECT_AGENT_DIR/maxwell-tca.md"
        log_info "Found agent at: $AGENT_SOURCE_FILE"
    elif [[ -f "$PROJECT_ROOT_AGENT_DIR/maxwell-tca.md" ]]; then
        AGENT_SOURCE_FILE="$PROJECT_ROOT_AGENT_DIR/maxwell-tca.md"
        log_info "Found agent at: $AGENT_SOURCE_FILE"
    elif [[ -f "$USER_AGENT_FILE" ]]; then
        AGENT_SOURCE_FILE="$USER_AGENT_FILE"
        log_info "Found agent at: $AGENT_SOURCE_FILE"
    else
        log_error "Agent source file not found at:"
        log_error "  TCA source (agent dir): $TCA_AGENT_DIR/maxwell-tca.md"
        log_error "  Project level (TCA): $PROJECT_AGENT_DIR/maxwell-tca.md"
        log_error "  Project level (root): $PROJECT_ROOT_AGENT_DIR/maxwell-tca.md"
        log_error "  User level: $USER_AGENT_FILE"
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
    log_info "Installing TCA Composable Architecture skill..."

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
    log_info "Installing TCA Expert agent..."

    # Create target directory
    mkdir -p "$AGENT_TARGET_DIR"

    # Copy agent file
    log_info "Copying agent file from $AGENT_SOURCE_FILE to $AGENT_TARGET_DIR"

    cp "$AGENT_SOURCE_FILE" "$AGENT_TARGET_DIR/maxwell-tca.md"

    # Set proper permissions
    chmod 755 "$AGENT_TARGET_DIR/maxwell-tca.md"

    log_success "Agent installed to: $AGENT_TARGET_DIR/maxwell-tca.md"
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

    # Check guides directory
    if [[ -d "$SKILL_TARGET_DIR/guides" ]]; then
        local guide_count=$(find "$SKILL_TARGET_DIR/guides" -name "*.md" | wc -l)
        log_success "✓ Found $guide_count TCA guides"
    else
        log_error "✗ Guides directory not found"
        return 1
    fi

    # Check references directory
    if [[ -d "$SKILL_TARGET_DIR/references" ]]; then
        local ref_count=$(find "$SKILL_TARGET_DIR/references" -name "*.md" | wc -l)
        log_success "✓ Found $ref_count DISCOVERY reference documents"
    else
        log_warning "⚠ References directory not found"
    fi

    # Check agent installation
    if [[ -f "$AGENT_TARGET_DIR/maxwell-tca.md" ]]; then
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
    echo "📍 Agent Location: $AGENT_TARGET_DIR/maxwell-tca.md"
    echo
    echo "📋 What was installed:"
    echo "  • TCA skill with 6 comprehensive guides (2,925 lines)"
    echo "  • Decision trees for architectural choices"
    echo "  • Validation checklists (reducer, view, testing, @Shared)"
    echo "  • DISCOVERY documents for debugging"
    echo "  • Code templates and examples"
    echo "  • TCA Expert sub-agent for Claude Code"
    echo
    echo "🚀 Next steps:"
    echo "  1. Restart Claude to load the new skill and agent"
    echo "  2. Use 'skill: TCA Composable Architecture' to access expertise"
    echo "  3. The maxwell-tca agent will auto-activate for TCA-related questions"
    echo
    echo "📚 Quick reference:"
    echo "  • Main skill: $SKILL_TARGET_DIR/SKILL.md"
    echo "  • Guides: $SKILL_TARGET_DIR/guides/"
    echo "  • Guides index: $SKILL_TARGET_DIR/guides/README.md"
    echo "  • References: $SKILL_TARGET_DIR/references/"
    echo "  • Agent config: $AGENT_TARGET_DIR/maxwell-tca.md"
    echo
    echo "🎯 TCA Versions Supported:"
    echo "  • TCA 1.23.0+"
    echo "  • Swift 6.2+ (strict concurrency)"
    echo "  • All Apple platforms (iOS, macOS, visionOS, watchOS)"
    echo "════════════════════════════════════════════════════════════════"
}

# Cleanup function
cleanup() {
    if [[ $? -ne 0 ]]; then
        log_error "Installation failed. Please check the error messages above."
        echo
        echo "🔧 Manual installation steps:"
        echo "  1. Copy skill contents to: $SKILL_TARGET_DIR"
        echo "  2. Copy agent file to: $AGENT_TARGET_DIR/maxwell-tca.md"
        echo "  3. Set permissions: chmod -R 755 \$TARGET_DIR"
    fi
}

# Set up cleanup trap
trap cleanup EXIT

# Main installation flow
main() {
    echo "🚀 TCA Composable Architecture Skill & Agent Installer"
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
