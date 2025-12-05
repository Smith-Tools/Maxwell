# Maxwell Knowledge System v4.0

**Personal discovery knowledge base for Swift/TCA development** - A simplified file-based system providing instant access to your documented learnings and case studies.

## 🎯 What Maxwell v4.0 Provides

### **🧠 Personal Discovery Knowledge Base**
- **Files**: 44 personal discoveries covering Swift/TCA learnings
- **Performance**: Instant search with Grep across all files (<5ms)
- **Coverage**: Smith framework, SwiftUI, TCA, visionOS, debugging patterns
- **Access**: Simple file-based search - no database overhead

### **🎭 Maxwell Skill**
- **Automatic Discovery Access**: Searches personal discoveries for Swift/TCA questions
- **Simple Integration**: Uses built-in Grep/Read/Glob tools
- **No Database**: File-based architecture, no imports or migrations
- **Git-Tracked**: Version control and diffs work naturally

## 🏗️ Architecture

```
Maxwell Knowledge System v4.0
├── Source (/Smith-Tools/Maxwell/)
│   ├── skills/maxwell/
│   │   ├── SKILL.md              # Skill definition
│   │   └── README.md             # Documentation
│   ├── install.sh                # Deployment script
│   └── Makefile                  # Build automation
│
├── Data (/Smith-Tools/Maxwell-data-private/)
│   ├── DISCOVERY-*.md            # 44 personal discoveries
│   ├── DISCOVERY-POLICY.md       # Documentation guidelines
│   ├── EVOLUTION.md              # Historical learnings
│   └── AGENT-ROUTING.md          # Agent patterns
│
└── Installed (~/.claude/)
    ├── skills/maxwell/           # Deployed skill
    └── resources/discoveries/    # Deployed discoveries
```

## 🚀 Quick Start

### **Installation**
```bash
cd /Volumes/Plutonian/_Developer/Smith-Tools/Maxwell
./install.sh
```

### **Usage**
```bash
# Maxwell auto-activates for Swift/TCA questions
"What patterns did I discover for nested TCA reducers?"
"How do I handle module boundary violations?"
"What's the issue with inline reducers in GreenSpurt?"
```

## 📝 Knowledge Base

### **Structure**
- **Location**: `~/.claude/resources/discoveries/`
- **Files**: 44 markdown files
- **Types**:
  - DISCOVERY-*.md (numbered case studies)
  - DISCOVERY-POLICY.md (documentation guidelines)
  - EVOLUTION.md (historical patterns)
  - AGENT-ROUTING.md (agent coordination)
  - Supporting architecture docs

### **Discovery Coverage**
- **TCA**: Reducer patterns, state management, nested reducers
- **SwiftUI**: View lifecycle, state objects, compilation issues
- **visionOS**: Spatial computing, RealityKit integration
- **Smith Framework**: Architecture decisions, module boundaries
- **Debugging**: Compiler errors, performance, common issues

## 🔍 How to Use Maxwell

### **Search Discoveries**
Agents use Grep to find relevant discoveries:
```
Grep:
  pattern: "nested reducer"
  path: "~/.claude/resources/discoveries"
  -i: true
```

### **Read a Discovery**
Read the full content:
```
Read:
  file_path: "~/.claude/resources/discoveries/DISCOVERY-14-NESTED-REDUCER-GOTCHAS.md"
```

### **Add New Discoveries**
1. Create markdown file: `DISCOVERY-NN-YOUR-TITLE.md`
2. Follow DISCOVERY-POLICY.md guidelines
3. File is immediately searchable

## 🔧 Development

### **Update Maxwell Skill**
```bash
cd skills/maxwell
# Edit SKILL.md or README.md
git add SKILL.md README.md
git commit -m "Update Maxwell skill"
git push
```

### **Add Discoveries**
```bash
cd ../Maxwell-data-private
# Add your markdown files
git add *.md
git commit -m "Add new discoveries"
git push

# Reinstall to update ~/.claude/resources/discoveries/
cd ../Maxwell
./install.sh
```

### **Reinstall**
```bash
cd /Volumes/Plutonian/_Developer/Smith-Tools/Maxwell
./install.sh
```

## 📊 What Changed from v3.0

| Aspect | v3.0 | v4.0 |
|--------|------|------|
| Storage | SQLite database | Markdown files |
| Search Tool | Python script | Grep (built-in) |
| Documents | 234 (mostly third-party) | 44 (personal discoveries) |
| Performance | Sub-millisecond | Millisecond |
| Maintenance | Database migrations | Edit files directly |
| Infrastructure | Complex | Simple |

## ✅ Key Benefits

1. **Simplicity** - No database, no Python, no migrations
2. **Transparency** - Human-readable markdown files
3. **Git-Friendly** - Version control and diffs work naturally
4. **Fast** - Grep searches 44 files instantly
5. **Maintainable** - Edit files directly, changes are immediate
6. **Personal** - Only your discoveries, no noise

## 🔀 Rollback to v3.0

If needed, old Maxwell v3.0 architecture is archived:

```bash
# Restore old components
mv ~/.claude/skills/maxwell-knowledge-ARCHIVED ~/.claude/skills/maxwell-knowledge
mv ~/.claude/skills/maxwell-librarian-ARCHIVED ~/.claude/skills/maxwell-librarian
mv ~/.claude/skills/maxwell-meta-ARCHIVED ~/.claude/skills/maxwell-meta
mv ~/.claude/resources/databases/maxwell-ARCHIVED.db ~/.claude/resources/databases/maxwell.db

# Remove v4.0
rm -rf ~/.claude/skills/maxwell
```

## 📚 Files

- **SKILL.md** - This skill's definition (auto-triggers on Swift/TCA questions)
- **skills/maxwell/README.md** - Detailed architecture documentation
- **DEPLOY.md** - Historical deployment notes (old v3.0 architecture)
- **install.sh** - Installation script
- **Makefile** - Build automation

## 🤝 Integration with Other Skills

- `sosumi` - Apple documentation (SwiftUI, UIKit, WWDC)
- `smith` - Smith framework validation
- Standard tools - Grep, Read, Glob

Maxwell focuses on **personal discoveries only**. For third-party documentation, use `sosumi` or `WebSearch`.

---

**Maxwell v4.0: Simple, personal, and discovery-focused. Just markdown files and built-in tools.**
