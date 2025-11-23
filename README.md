# Maxwell - Multi-Skill Specialist System

**Maxwell** is a production-ready knowledge coordination system for helping developers navigate complex, multi-framework Apple development. It provides both auto-triggered skills for quick pattern lookups and a unified orchestrator agent for complex multi-domain tasks.

> **Architecture**: Maxwell uses a real Swift CLI binary (maxwell command) backed by SQLite database. Skills call the binary via Bash to access shared knowledge. No fake infrastructure.

## Current Architecture

Maxwell operates on a **4-tier architecture**:

```
Layer 1: Entry Points
├── Auto-triggered skills (quick keyword-based answers)
└── Maxwell agent (complex multi-domain questions)

Layer 2: Specialized Skills (auto-triggered)
├── skill-pointfree (TCA authority: @Shared, @Bindable, Reducer, TestStore)
├── skill-shareplay (SharePlay: GroupActivities, spatial coordination)
└── skill-meta (Maxwell's own architecture and system patterns)

Layer 3: Knowledge Access
└── maxwell CLI binary
    ├── maxwell search "query" [--domain] [--limit]
    ├── maxwell pattern "name"
    ├── maxwell domain TCA|SharePlay
    ├── maxwell init
    └── maxwell migrate /path

Layer 4: Data Layer
└── SQLite Database (~/.claude/resources/databases/maxwell.db)
    ├── 153 migrated documents
    ├── Full-text search (FTS5)
    └── Pattern + metadata tables
```

## Directory Structure

```
maxwell/
├── skills/
│   ├── skill-pointfree/     # TCA authority (auto-triggered)
│   ├── skill-shareplay/     # SharePlay expert (auto-triggered)
│   └── skill-meta/          # Maxwell's meta-knowledge
├── agent/
│   └── maxwell.md           # Main orchestrator (explicit invoke)
├── database/
│   ├── Sources/
│   │   ├── MaxwellCLI/main.swift      # CLI binary with 5 subcommands
│   │   └── MaxwellDatabase/           # Type-safe SQLite wrapper
│   ├── Package.swift        # Swift package (ArgumentParser, SQLite.swift)
│   └── maxwell.db           # Version-controlled database
├── install.sh               # Complete deployment script
└── README.md               # This file
```

## How Maxwell Works

### Entry Points

**Auto-triggered Skills** (fast, keyword-based):
- Ask: "How do I use @Shared in TCA with multiple views?"
- skill-pointfree auto-triggers on `@Shared` + `TCA`
- Runs: `maxwell search "@Shared" --domain TCA`
- Returns relevant patterns in ~2 seconds

**Maxwell Agent** (comprehensive, multi-domain):
- Ask: "I have TCA code that needs review and optimization"
- Explicit invoke: `@maxwell`
- Reads code files, queries maxwell database, synthesizes answers
- Handles cross-domain questions (TCA + SharePlay, etc.)

### Knowledge Access

All skills and the agent access patterns via the **maxwell CLI binary**:

```bash
# Search across all domains
maxwell search "Reducer composition" --limit 5

# Search specific domain
maxwell search "@Shared" --domain TCA

# Find pattern by name
maxwell pattern "TCA @Shared Single Owner"

# List all patterns in domain
maxwell domain SharePlay

# Database management
maxwell init              # Initialize empty database
maxwell migrate /path     # Migrate markdown files
```

### Database

SQLite database with 153 documents:
- **70 markdown files** from skill content
- **83 pattern entries** with metadata
- **Full-text search** (FTS5) for fast queries
- **Location**: `~/.claude/resources/databases/maxwell.db`
- **Type-safe queries** via SQLite.swift library

## Installation & Deployment

### Quick Start

```bash
cd /Volumes/Plutonian/_Developer/Smith\ Tools/Maxwell
./install.sh
```

The script:
1. ✅ Builds maxwell CLI binary from Swift
2. ✅ Initializes SQLite database
3. ✅ Migrates 70 markdown documents
4. ✅ Deploys 3 skills (pointfree, shareplay, meta)
5. ✅ Deploys maxwell agent
6. ✅ Verifies installation

### Verification

```bash
# Test the binary
maxwell search "TCA @Shared"

# Test with Claude
# Ask a question with framework keywords
# Watch skills auto-trigger
```

## Specialized Skills

### skill-pointfree
**TCA Authority** - The Composable Architecture expertise

Auto-triggers on: `@Shared`, `@Bindable`, `Reducer`, `TestStore`, `TCA`

Provides:
- TCA pattern guidance and best practices
- Dependency injection patterns
- Testing strategies
- Cross-framework integration with Point-Free libraries

### skill-shareplay
**SharePlay Expert** - Apple's GroupActivities framework

Auto-triggers on: `SharePlay`, `GroupActivities`, `collaborative`

Provides:
- GroupActivities implementation patterns
- Spatial coordinate synchronization
- Cross-platform support (iOS, visionOS, macOS)
- Real-world production examples

### skill-meta
**Maxwell's Self-Knowledge** - Architecture and composition patterns

Auto-triggers on: `Maxwell`, `architecture`, `patterns`, `skills`

Provides:
- Multi-skill architecture guidance
- Pattern composition strategies
- Maxwell system documentation
- Skill development templates

## Maxwell Agent

**Explicit invocation**: `@maxwell`

Complex multi-domain questions:
- Code review and optimization
- Cross-framework integration (TCA + SharePlay)
- Architectural guidance
- Complex problem synthesis

Features:
- File reading and analysis
- Database query capability
- Multi-skill orchestration
- Code generation and suggestions

## Design Principles

### Type Safety
- Swift compile-time checked queries
- Zero unsafe code in database layer
- Proper null handling for optional fields

### Real Infrastructure
- Actual Swift CLI binary (not fake shell scripts)
- Real SQLite database with proper schema
- Version-controlled database state

### Separation of Concerns
- Auto-triggered skills: Quick pattern lookups
- Maxwell agent: Complex analysis
- maxwell binary: Single source of truth

### Scalability
- Easy to add new pattern documents
- CLI subcommands support future extensions
- Skill composition without code changes

## Development Status

✅ **Complete and Production-Ready**
- Real Swift CLI binary with 5 subcommands
- 153 documents migrated to SQLite
- 3 operational skills with auto-triggering
- Maxwell orchestrator agent
- Complete installation script
- Type-safe database layer (SQLite.swift)
- Zero unsafe code

## File Structure

**Core Files:**
- `install.sh` - Complete deployment orchestration
- `agent/maxwell.md` - Main orchestrator (220+ lines)
- `database/Sources/MaxwellCLI/main.swift` - CLI implementation
- `database/Sources/MaxwellDatabase/SimpleDatabase.swift` - Type-safe SQLite

**Skills:**
- `skills/skill-pointfree/skill/SKILL.md` - TCA authority
- `skills/skill-shareplay/skill/SKILL.md` - SharePlay expert
- `skills/skill-meta/skill/SKILL.md` - Maxwell's knowledge

**Documentation:**
- `README.md` - This file (current architecture)
- `ARCHITECTURE-DECISION.md` - Why this design
- `KNOWLEDGE-MAINTENANCE.md` - How to extend patterns
- `START-HERE.md` - Getting started guide

## Next Steps

After installation:

1. Verify binary: `maxwell search "TCA @Shared"`
2. Test auto-triggering: Ask a question with framework keywords
3. Test Maxwell agent: `@maxwell` for complex questions
4. Extend patterns: Add new documents to skills, run `maxwell migrate`

---

**Maxwell v2.0** - Multi-skill specialist system with unified knowledge coordination.