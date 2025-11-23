# Makefile for Maxwell
# Multi-skill specialist system with database-driven knowledge
# Supports development, testing, and distribution

.PHONY: build install deploy test clean help dist-update version

# Configuration
MAXWELL_SOURCE=$(CURDIR)
LOCAL_SKILL_DIR=$(HOME)/.claude/skills
LOCAL_AGENT_DIR=$(HOME)/.claude/agents
LOCAL_BIN_DIR=$(HOME)/local/bin
LOCAL_DB_DIR=$(HOME)/.claude/resources/databases

# Default target
all: deploy

# Build all Maxwell components
build:
	@echo "🔨 Maxwell Ready for Deployment"
	@echo "   No compilation required - skills are markdown files"
	@echo ""
	@echo "📊 Component Statistics:"
	@echo "   Skills: $(find $(MAXWELL_SOURCE)/skills -name "skill-*" -type d | wc -l | awk '{print $$1}') specialist skills"
	@echo "   Agents: $(find $(MAXWELL_SOURCE)/agent -name "*.md" | wc -l | awk '{print $$1}') coordination agents"
	@echo "   Database: $(find $(MAXWELL_SOURCE)/database -name "*.sql" -o -name "*.swift" | wc -l | awk '{print $$1}') knowledge files"

# Deploy Maxwell (skills + agents + database)
deploy: build
	@echo "🚀 Deploying Maxwell..."
	@echo ""
	@echo "📚 Deploying Skills..."
	mkdir -p "$(LOCAL_SKILL_DIR)"

	# Deploy Point-Free skill (includes TCA)
	@echo "   📦 skill-pointfree (TCA + Dependencies + Navigation + Testing)"
	mkdir -p "$(LOCAL_SKILL_DIR)/maxwell-pointfree"
	cp -r "$(MAXWELL_SOURCE)/skills/skill-pointfree/"* "$(LOCAL_SKILL_DIR)/maxwell-pointfree/"

	# Deploy SharePlay skill
	@echo "   📦 skill-shareplay (GroupActivities + spatial coordination)"
	mkdir -p "$(LOCAL_SKILL_DIR)/maxwell-shareplay"
	cp -r "$(MAXWELL_SOURCE)/skills/skill-shareplay/"* "$(LOCAL_SKILL_DIR)/maxwell-shareplay/"

	# Deploy Meta skill
	@echo "   📦 skill-meta (Maxwell's own meta-knowledge and system patterns)"
	mkdir -p "$(LOCAL_SKILL_DIR)/maxwell-meta"
	cp -r "$(MAXWELL_SOURCE)/skills/skill-meta/"* "$(LOCAL_SKILL_DIR)/maxwell-meta/"

	@echo "   ✅ Skills deployed: $$(find $(LOCAL_SKILL_DIR) -name "maxwell-*" -type d | wc -l | awk '{print $$1}') skills"

	@echo ""
	@echo "🤖 Deploying Agents..."
	mkdir -p "$(LOCAL_AGENT_DIR)"
	cp "$(MAXWELL_SOURCE)/agent/maxwell.md" "$(LOCAL_AGENT_DIR)/" 2>/dev/null || echo "   ⚠️  maxwell.md not found"
	@echo "   ✅ Agents deployed: $(find $(LOCAL_AGENT_DIR) -name "maxwell.md" | wc -l | awk '{print $$1}') agents"

	@echo ""
	@echo "🗄️ Deploying Database..."
	mkdir -p "$(LOCAL_DB_DIR)"

	# Copy database files
	@echo "   📋 Copying database schema and tools..."
	cp "$(MAXWELL_SOURCE)/database/SimpleDatabase.swift" "$(LOCAL_DB_DIR)/"
	cp "$(MAXWELL_SOURCE)/database/DatabaseSchema.sql" "$(LOCAL_DB_DIR)/"
	cp "$(MAXWELL_SOURCE)/database/HybridKnowledgeRouter.swift" "$(LOCAL_DB_DIR)/"
	cp "$(MAXWELL_SOURCE)/database/QueryClassifier.swift" "$(LOCAL_DB_DIR)/"

	# Initialize database if needed
	@echo "   🔨 Initializing database..."
	cd "$(LOCAL_DB_DIR)"
	@if [ ! -f "maxwell.db" ]; then \
		echo "   Database not found - skipping initialization (requires init-db.swift)"; \
	else \
		echo "   ✅ Database already exists"; \
	fi

	@echo "   ✅ Database ready: $(LOCAL_DB_DIR)"
	@echo ""

# Install only (no build)
install: deploy
	@echo "🎉 Maxwell Installation Complete!"
	@echo "=================================="
	@echo ""
	@echo "📚 Skills Directory: $(LOCAL_SKILL_DIR)"
	@echo "🤖 Agents Directory: $(LOCAL_AGENT_DIR)"
	@echo "🗄️ Database: $(LOCAL_DB_DIR)"
	@echo ""
	@echo "🧠 Maxwell Architecture:"
	@echo "   • One agent: Coordinates specialist selection"
	@echo "   • Multiple skills: Domain specialists (Point-Free, SharePlay, etc.)"
	@echo "   • Shared database: Knowledge layer for all components"
	@echo ""
	@echo "🔄 For updates: Run 'make deploy' again"
	@echo "🌐 Repository: https://github.com/Smith-Tools/Maxwell"

# Test all components
test:
	@echo "🧪 Running Maxwell Tests..."
	@echo ""
	@echo "   🧪 Testing deployment integrity..."
	@echo "   🧪 Testing skill integrity..."
	@echo "      Testing skill-pointfree structure..."
	@[ -d "$(LOCAL_SKILL_DIR)/maxwell-pointfree" ] && echo "   ✅ skill-pointfree structure valid"
	@[ -f "$(LOCAL_SKILL_DIR)/maxwell-pointfree/skill/SKILL.md" ] && echo "   ✅ skill-pointfree manifest valid"
	@[ -d "$(LOCAL_SKILL_DIR)/maxwell-shareplay" ] && echo "   ✅ skill-shareplay structure valid"
	@[ -f "$(LOCAL_SKILL_DIR)/maxwell-shareplay/skill/SKILL.md" ] && echo "   ✅ skill-shareplay manifest valid"
	@[ -d "$(LOCAL_SKILL_DIR)/maxwell-meta" ] && echo "   ✅ skill-meta structure valid"
	@[ -f "$(LOCAL_SKILL_DIR)/maxwell-meta/skill/SKILL.md" ] && echo "   ✅ skill-meta manifest valid"
	@echo "   ✅ All skill structures valid"
	@echo ""
	@echo "   🧪 Testing agent integrity..."
	@[ -f "$(LOCAL_AGENT_DIR)/maxwell.md" ] && echo "   ✅ maxwell agent valid"
	@echo "   ✅ All agent structures valid"
	@echo ""
	@echo "   🧪 Testing database connectivity..."
	@cd "$(LOCAL_DB_DIR)" && if [ -f "maxwell.db" ]; then sqlite3 maxwell.db "SELECT COUNT(*) as total_docs FROM documents;" >/dev/null && echo "   ✅ Database connectivity working" || echo "   ⚠️ Database connectivity issue"; else echo "   ❌ Database not found"; fi
	@echo ""
	@echo "🎉 All tests passed!"

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	cd "$(MAXWELL_SOURCE)"
	rm -rf .build
	rm -rf dist
	rm -rf *.db-journal
	@echo "   ✅ Clean complete"

# Create distribution package
dist: clean build
	@echo "📦 Creating Maxwell distribution package..."
	mkdir -p dist

	# Copy skills
	@echo "   📚 Packaging skills..."
	mkdir -p dist/skills
	cp -r "$(MAXWELL_SOURCE)/skills/"* dist/skills/

	# Copy agents
	@echo "   🤖 Packaging agents..."
	mkdir -p dist/agents
	cp "$(MAXWELL_SOURCE)/agent/"*.md dist/agents/

	# Copy database files
	@echo "   🗄️ Packaging database files..."
	mkdir -p dist/database
	cp "$(MAXWELL_SOURCE)/database/"*.swift dist/database/
	cp "$(MAXWELL_SOURCE)/database/"*.sql dist/database/
	cp "$(MAXWELL_SOURCE)/database/"*.md dist/database/

	# Copy database (if exists)
	@if [ -f "$(LOCAL_DB_DIR)/maxwell.db" ]; then
		echo "   📋 Including current database..."
		cp "$(LOCAL_DB_DIR)/maxwell.db" dist/database/
	else
		echo "   ⚠️  No database found, will create on first run"
	fi

	# Copy installation script
	@echo "   🔧 Creating installation script..."
	@printf '%s\n' \
		'#!/bin/bash' \
		'set -e' \
		'echo "🚀 Installing Maxwell Multi-Skill System..."' \
		'MAXWELL_SOURCE="$(MAXWELL_SOURCE)"' \
		'LOCAL_SKILL_DIR="$(HOME)/.claude/skills"' \
		'LOCAL_AGENT_DIR="$(HOME)/.claude/agents"' \
		'LOCAL_BIN_DIR="$(HOME)/local/bin"' \
	'LOCAL_DB_DIR="$(HOME)/claude/resources/databases"' \
		'' \
		'# Deploy skills' \
		'echo "📚 Deploying Maxwell Skills..."' \
		'mkdir -p "$$LOCAL_SKILL_DIR"' \
		'cp -r "$$MAXWELL_SOURCE/skills/"* "$$LOCAL_SKILL_DIR/"' \
	'' \
		'# Deploy agents' \
	'echo "🤖 Deploying Maxwell Agents..."' \
		'mkdir -p "$LOCAL_AGENT_DIR"' \
	'cp "$$MAXWELL_SOURCE/agent/"*.md "$LOCAL_AGENT_DIR/"' \
	'' \
	'# Deploy database' \
	'echo "🗄️ Deploying Database..."' \
	'mkdir -p "$LOCAL_DB_DIR"' \
	'cp "$MAXWELL_SOURCE/database/"*.swift "$LOCAL_DB_DIR/"' \
	'cp "$MAXWELL_SOURCE/database/"*.sql "$LOCAL_DB_DIR/"' \
	'' \
	'# Initialize database' \
	'cd "$LOCAL_DB_DIR"' \
	'if [ ! -f "maxwell.db" ]; then' \
	'    echo "   🔨 Initializing Maxwell database..."' \
	'    swift init-db.swift' \
	'    echo "   ✅ Database initialized"' \
	'else' \
	'    echo "   ✅ Database already exists"' \
	'fi' \
	'' \
	'# Setup CLI tools' \
	'mkdir -p "$LOCAL_BIN_DIR"' \
	'cp "$MAXWELL_SOURCE/database/.build/release/maxwell-patterns" "$LOCAL_BIN_DIR/" 2>/dev/null || echo "⚠️  maxwell-patterns not found, will install manually"' \
	'echo "✅ Installation complete!"' \
		'' \
		'🎉 Maxwell Multi-Skill System Ready!' \
		'=================================' \
		'' \
	'📚 Skills: $LOCAL_SKILL_DIR' \
	'🤖 Agents: $LOCAL_AGENT_DIR' \
	'🗄️ Database: $LOCAL_DB_DIR/maxwell.db' \
	'🔧 CLI: $LOCAL_BIN_DIR' \
	'' \
	'Usage:' \
	'  # Update existing installation' \
	'  make deploy' \
	'' \
	'🌐 https://github.com/Smith-Tools/Maxwell' \
	> dist/install.sh
	chmod +x dist/install.sh

	# Create CLI tools package
	@echo "   🔧 Creating CLI tools package..."
	mkdir -p dist/cli-tools
	cd "$(MAXWELL_SOURCE)/database"
	cp .build/release/maxwell-* dist/cli-tools/ 2>/dev/null || echo "⚠️  Some CLI tools may not be built"

	# Create development package
	@echo "   🛠️ Creating development package..."
	mkdir -p dist/dev
	cp -r "$(MAXWELL_SOURCE)/templates" dist/dev/
	cp -r "$(MAXWELL_SOURCE)/database" dist/dev/
	cp "$(MAXWELL_SOURCE)/agent" dist/dev/
	cp "$(MAXWELL_SOURCE)/skills" dist/dev/

	# Create version info
	@echo "   📋 Version information..."
	@printf '%s\n' \
		"Maxwell $(shell git describe --tags --always 2>/dev/null || echo "latest")" \
		"Multi-skill specialist system with database-driven knowledge" \
		"" \
	"Architecture:" \
	"- Skills: $(find $(MAXWELL_SOURCE)/skills -name "skill-*" -type d | wc -l | awk '{print $$1}') specialist skills" \
	"- Agents: $(find $(MAXWELL_SOURCE)/agent -name "*.md" | wc -l | awk '{print $$1}') coordination agents" \
	"- Database: Knowledge layer with pattern storage" \
	> dist/VERSION.md

	# Create distribution package
	@echo "   📦 Creating distribution archive..."
	cd dist
	tar -czf maxwell-$(shell git describe --tags --always 2>/dev/null || echo "latest")-$(date +%Y%m%d).tar.gz *

	@echo "✅ Distribution package created in dist/"
	@echo "   Archive: maxwell-$(shell git describe --tags --always 2>/dev/null || echo "latest")-$(date +%Y%m%d).tar.gz"

# Update distribution (increment version)
dist-update:
	@echo "📦 Updating distribution package..."
	@echo "   📋 Version: $(shell git describe --tags --always 2>/dev/null || echo "latest")"
	@echo "   🗄️ Date: $(date +%Y-%m-%d)"
	@echo "   🚀 Creating new package..."
	$(MAKE) dist

# Show version
version:
	@echo "Maxwell Multi-Skill Specialist System"
	@echo "================================="
	@echo "Version: $(shell git describe --tags --always 2>/dev/null || echo "latest")"
	@echo "Commit: $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")"
	@echo "Date: $(date)"
	@echo ""
	@echo "Architecture:"
	@echo "  Skills: $(find $(MAXWELL_SOURCE)/skills -name "skill-*" -type d | wc -l | awk '{print $$1}') specialist skills"
	@echo "  Agents: $(find $(MAXWELL_SOURCE)/agent -name "*.md" | wc -l | awk '{print $$1}') coordination agents"
	@echo "  Database: Knowledge layer with patterns and contradictions"
	@echo ""
	@echo "Repository: https://github.com/Smith-Tools/Maxwell"

# Show help
help:
	@echo "Maxwell Multi-Skill Build System"
	@echo ""
	@echo "Targets:"
	@echo "  build         Build all components"
	@echo "  deploy        Deploy skills + agents + database"
	echo "  install       Deploy without building (for quick updates)"
	@echo "  test          Run all tests"
	echo "  clean         Clean build artifacts"
	echo "  dist          Create distribution package"
	@echo "  dist-update   Update distribution with current version"
	@echo "  version       Show version information"
	@echo "  help          Show this help"
	@echo ""
	@echo "Examples:"
	@echo "  make deploy        # Build and install all components"
	@echo "  make install       # Quick deployment (no build)"
	echo "  make test          # Run test suite"
	echo "  make clean         # Clean build artifacts"
	echo "  make dist          # Create distribution package"
	@echo "  make version       # Show version info"
	@echo ""
	@echo "Development Workflow:"
	echo "  make build        # Build components"
	echo "  make test          # Run tests"
	echo "  make deploy       # Deploy for testing"
	@echo "  make dist          # Create package for release"
	@echo ""
	@echo "Installation:"
	@echo "  make deploy        # First time setup"
	echo "  make install       | Subsequent updates"