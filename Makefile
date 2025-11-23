# Maxwell Multi-Skill System Makefile
# Provides common development and maintenance tasks

.PHONY: help install validate clean check-deps update-deps status test

# Default target
help:
	@echo "🚀 Maxwell Multi-Skill System"
	@echo "================================"
	@echo ""
	@echo "Available Commands:"
	@echo "  install      - Install Maxwell skills and agents (uses install.sh)"
	@echo "  validate     - Validate Maxwell components and knowledge"
	@echo "  status       - Show current installation status"
	@echo "  check-deps   - Check system dependencies"
	@echo "  clean        - Remove installed skills and agents"
	@echo "  test         - Test knowledge search and retrieval"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make install    # Install all components"
	@echo "  make validate   # Validate installation"
	@echo "  make status     # Check current status"

# Configuration
MAXWELL_SOURCE := $(shell pwd)
LOCAL_SKILL_DIR := $(HOME)/.claude/skills
LOCAL_AGENT_DIR := $(HOME)/.claude/agents
REQUIRED_SKILLS := maxwell-pointfree maxwell-shareplay maxwell-swift maxwell-visionos maxwell-meta

# Installation target (delegates to install.sh)
install:
	@echo "🚀 Installing Maxwell Multi-Skill System..."
	@./install.sh

# Validate Maxwell components
validate:
	@echo "🔍 Validating Maxwell Components..."
	@echo "Source Directory: $(MAXWELL_SOURCE)"
	@echo ""
	@echo "Checking Maxwell Agent:"
	@if [ -f "$(MAXWELL_SOURCE)/agent/maxwell.md" ]; then \
		echo "   ✅ Maxwell Agent: agent/maxwell.md"; \
	else \
		echo "   ❌ Maxwell Agent: agent/maxwell.md (MISSING)"; \
	fi
	@echo ""
	@echo "Checking Specialized Skills:"
	@for skill in $(REQUIRED_SKILLS); do \
		if [ -d "$(MAXWELL_SOURCE)/skills/$$skill" ]; then \
			files=$$(find "$(MAXWELL_SOURCE)/skills/$$skill" -name "*.md" | wc -l); \
			echo "   ✅ $$skill: $$skill/ ($$files files)"; \
		else \
			echo "   ❌ $$skill: $$skill/ (MISSING)"; \
		fi; \
	done
	@echo ""
	@echo "Knowledge Distribution:"
	@total=0; \
	for skill in $(REQUIRED_SKILLS); do \
		if [ -d "$(MAXWELL_SOURCE)/skills/$$skill/knowledge" ]; then \
			count=$$(find "$(MAXWELL_SOURCE)/skills/$$skill/knowledge" -name "*.md" 2>/dev/null | wc -l); \
			echo "   ✅ $$skill: $$count embedded knowledge files"; \
			total=$$((total + count)); \
		else \
			echo "   ⚠️  $$skill: No embedded knowledge"; \
		fi; \
	done; \
	echo "   📖 Total Embedded Knowledge: $$total documents"

# Show installation status
status:
	@echo "📊 Maxwell Installation Status"
	@echo "============================="
	@echo ""
	@echo "Source Directory:"
	@echo "   📁 Maxwell: $(MAXWELL_SOURCE)"
	@echo ""
	@echo "Target Directories:"
	@echo "   🎯 Skills: $(LOCAL_SKILL_DIR)"
	@echo "   🎯 Agents: $(LOCAL_AGENT_DIR)"
	@echo ""
	@echo "Installation Status:"
	@if [ -d "$(LOCAL_AGENT_DIR)/maxwell" ]; then \
		echo "   ✅ Maxwell Agent: Installed"; \
		ls -la "$(LOCAL_AGENT_DIR)/maxwell/" | grep -v "^total" | wc -l | sed 's/^/      /; s/$$/ files/'; \
	else \
		echo "   ❌ Maxwell Agent: Not installed"; \
	fi
	@echo ""
	@for skill in $(REQUIRED_SKILLS); do \
		if [ -d "$(LOCAL_SKILL_DIR)/$$skill" ]; then \
			files=$$(find "$(LOCAL_SKILL_DIR)/$$skill" -name "*.md" 2>/dev/null | wc -l); \
			knowledge=$$(find "$(LOCAL_SKILL_DIR)/$$skill/knowledge" -name "*.md" 2>/dev/null | wc -l 2>/dev/null || echo 0); \
			echo "   ✅ $$skill: Installed ($$files files, $$knowledge knowledge)"; \
		else \
			echo "   ❌ $$skill: Not installed"; \
		fi; \
	done
	@echo ""
	@echo "Storage Usage:"
	@if [ -d "$(LOCAL_SKILL_DIR)" ]; then \
		size=$$(du -sh "$(LOCAL_SKILL_DIR)" 2>/dev/null | cut -f1); \
		echo "   💾 Skills: $$size"; \
	else \
		echo "   💾 Skills: Not installed"; \
	fi
	@if [ -d "$(LOCAL_AGENT_DIR)" ]; then \
		size=$$(du -sh "$(LOCAL_AGENT_DIR)" 2>/dev/null | cut -f1); \
		echo "   💾 Agents: $$size"; \
	else \
		echo "   💾 Agents: Not installed"; \
	fi

# Check system dependencies
check-deps:
	@echo "🔧 Checking Text File Dependencies"
	@echo "=================================="
	@echo ""
	@echo "Required System Tools:"
	@for tool in bash find cp rm mkdir du wc; do \
		if command -v $$tool >/dev/null 2>&1; then \
			echo "   ✅ $$tool: $$(which $$tool)"; \
		else \
			echo "   ❌ $$tool: NOT FOUND (needed for text file operations)"; \
		fi; \
	done
	@echo ""
	@echo "Optional Tools:"
	@for tool in git make; do \
		if command -v $$tool >/dev/null 2>&1; then \
			echo "   ✅ $$tool: $$(which $$tool)"; \
		else \
			echo "   ⚠️  $$tool: Not found (development workflow disabled)"; \
		fi; \
	done
	@echo ""
	@echo "✅ Maxwell is pure text - no compilation or binaries needed"

# Clean installation
clean:
	@echo "🧹 Cleaning Maxwell Installation..."
	@echo ""
	@echo "Removing installed skills and agents:"
	@for skill in $(REQUIRED_SKILLS); do \
		if [ -d "$(LOCAL_SKILL_DIR)/$$skill" ]; then \
			echo "   Removing: $$skill"; \
			rm -rf "$(LOCAL_SKILL_DIR)/$$skill"; \
		fi; \
	done
	@if [ -d "$(LOCAL_AGENT_DIR)/maxwell" ]; then \
		echo "   Removing: maxwell agent"; \
		rm -rf "$(LOCAL_AGENT_DIR)/maxwell"; \
	fi
	@echo ""
	@echo "✅ Cleaning complete"

# Test knowledge search
test:
	@echo "🧪 Testing Knowledge Search..."
	@echo ""
	@echo "Testing skill knowledge access:"
	@for skill in $(REQUIRED_SKILLS); do \
		if [ -d "$(MAXWELL_SOURCE)/skills/$$skill/knowledge" ]; then \
			count=$$(find "$(MAXWELL_SOURCE)/skills/$$skill/knowledge" -name "*.md" 2>/dev/null | wc -l); \
			echo "   ✅ $$skill: $$count searchable documents"; \
		else \
			echo "   ⚠️  $$skill: No knowledge directory"; \
		fi; \
	done
	@echo ""
	@echo "Testing agent configuration:"
	@if [ -f "$(MAXWELL_SOURCE)/agent/maxwell.md" ]; then \
		echo "   ✅ Maxwell agent configuration found"; \
	else \
		echo "   ❌ Maxwell agent configuration missing"; \
	fi

# Update dependencies (placeholder for future use)
update-deps:
	@echo "📦 Update Knowledge Dependencies"
	@echo "================================"
	@echo "✅ No external dependencies to update"
	@echo "Maxwell uses only embedded text knowledge"
	@echo ""
	@echo "To update knowledge content:"
	@echo "1. Pull latest changes: git pull"
	@echo "2. Reinstall skills: make install"
	@echo "3. Validate content: make validate"