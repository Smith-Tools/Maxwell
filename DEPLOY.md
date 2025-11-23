# Maxwell Deployment Guide

## 🚀 Quick Installation (Pure Text - No Binaries)

```bash
# Deploy Maxwell skills and agent with embedded knowledge
./install.sh
# Or use: make install

# Verify installation
ls ~/.claude/skills/
ls ~/.claude/agents/
```

### **Text-Only Architecture**
- ❌ **No compilation** required
- ❌ **No binaries** to install
- ❌ **No Homebrew** needed
- ✅ **Pure markdown files** copied to Claude directories
- ✅ **Zero dependencies** beyond standard system tools

## 📁 Final Architecture

```
Maxwell/
├── agent/maxwell.md                    # Maxwell orchestrator
└── skills/
    ├── maxwell-pointfree/              # TCA + Point-Free ecosystem
    │   ├── SKILL.md
    │   └── knowledge/                   # 24 TCA files (complete)
    ├── maxwell-shareplay/              # SharePlay + spatial computing
    │   ├── SKILL.md
    │   └── knowledge/                   # 28 SharePlay files
    ├── maxwell-swift/                  # Swift language (empty - user will provide)
    │   └── SKILL.md
    ├── maxwell-visionos/               # visionOS spatial computing
    │   ├── SKILL.md
    │   └── knowledge/                   # 3 visionOS files
    └── maxwell-meta/                    # Self-reflection
        ├── SKILL.md
        └── knowledge/                   # 1 meta file
```

## 🎯 Knowledge Distribution Fixed

### ✅ **Correct Domain Boundaries**
- **maxwell-pointfree**: 24 TCA + Point-Free files
- **maxwell-shareplay**: 28 SharePlay files
- **maxwell-visionos**: 3 visionOS files
- **maxwell-meta**: 1 meta-reflection file
- **maxwell-swift**: Empty (ready for your Swift content)

### ✅ **Nesting Issues Resolved**
- No more `examples/examples/` nesting
- No more `guides/guides/` nesting
- No more `resources/resources/` nesting
- Clean, flat knowledge structure

## 🔧 Usage

### **Single Domain Queries**
```
Ask: "How do I implement @Shared state in TCA?"
→ maxwell-pointfree skill activates
```

### **Cross-Domain Queries**
```
Ask: "Build collaborative TCA app with SharePlay"
→ Maxwell agent orchestrates both skills
```

### **Self-Reflection**
```
Ask: "How do Maxwell skills coordinate?"
→ maxwell-meta skill activates
```

## 📊 Release Ready (Pure Text Architecture)

Maxwell v3.0 is now a pure text system with:
- ✅ **Text-only deployment**: No binaries, no compilation, no dependencies
- ✅ **Correct knowledge distribution**: Embedded in skill directories
- ✅ **Domain boundaries enforced**: Each skill focuses on its domain
- ✅ **Clean directory structure**: No nesting issues, flat knowledge organization
- ✅ **Embedded knowledge**: Skills own their knowledge directly
- ✅ **Production ready**: Zero-overhead integration with Claude

### **Deployment Benefits**
- **Instant**: No compilation or build steps
- **Portable**: Works anywhere Claude works
- **Transparent**: All content is readable/editable markdown
- **Zero Overhead**: No additional processes or services
- **Cross-Platform**: Same experience everywhere

**Note**: maxwell-swift is empty and ready for your Swift-specific content when available.