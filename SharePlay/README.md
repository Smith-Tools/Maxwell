# Maxwell SharePlay Skill & Agent

A comprehensive Claude skill and agent for Apple SharePlay development, providing expert guidance, production-ready code patterns, and Human Interface Guidelines compliance.

## 🚀 Quick Start

### Installation
```bash
# Navigate to the SharePlay directory
cd /Volumes/Plutonian/_Developer/Maxwells/source/SharePlay

# Run the installer
./install.sh
```

### Usage
After installation and restarting Claude:

- **Ask general SharePlay questions**: "How do I implement participant management?"
- **Use the agent**: `/maxwell-shareplay` for dedicated SharePlay assistance
- **Access the skill**: `skill: SharePlay` for specialized knowledge

## 📁 Project Structure

```
SharePlay/
├── skill/                    # Claude skill content
│   ├── SKILL.md             # Main skill documentation
│   ├── snippets/            # Production-ready code examples
│   ├── guides/              # Implementation guides
│   ├── references/          # Apple documentation & research
│   ├── hig-principles.md    # Human Interface Guidelines
│   └── design-validation-framework.md  # HIG compliance testing
├── agent/                   # Claude agent configuration
│   └── maxwell-shareplay.md # Agent configuration
├── install.sh              # Installation script
└── README.md               # This file
```

## 🎯 What's Included

### Skill Contents
- **Production Code**: Verified SDK implementations with no placeholders
- **Error Recovery**: Comprehensive patterns for participant disconnection, conflict resolution
- **Concurrency Patterns**: Advanced async/await, actor-based state management, backpressure control
- **HIG Compliance**: Complete design validation framework and UI components
- **Documentation**: 40+ guides, examples, and reference materials

### Agent Configuration
- **Specialized Knowledge**: Focused on SharePlay and GroupActivities framework
- **Best Practices**: Production-tested patterns and approaches
- **Platform Expertise**: visionOS, iOS, and macOS specific guidance

## 🔧 Key Features

### ✅ Verified SDK Integration
- Uses actual Xcode 26.1.0 SDK signatures
- No theoretical or placeholder implementations
- Real-world tested code patterns

### 🎨 Design Compliance
- Complete HIG implementation guidelines
- Automated validation framework
- Accessibility-first approach

### 🛡️ Production Ready
- Comprehensive error handling
- Network condition adaptation
- Performance optimization patterns

### 📱 Platform Coverage
- **visionOS**: Spatial computing and immersive experiences
- **iOS**: Mobile SharePlay with battery optimization
- **macOS**: Desktop integration and multitasking

## 📚 Documentation Highlights

### Core Guides
- `SKILL.md` - Complete skill overview and capabilities
- `hig-principles.md` - Apple HIG for SharePlay experiences
- `design-validation-framework.md` - Automated testing and compliance

### Code Examples
- `snippets/basic-shareplay-setup.swift` - Essential setup patterns
- `snippets/error-recovery-patterns.swift` - Robust error handling
- `snippets/advanced-concurrency-patterns.swift` - Performance optimization
- `snippets/hig-compliance-components.swift` - Ready-to-use UI components

### References
- Apple SharePlay HIG and documentation
- WWDC session notes and insights
- SDK verification results and findings

## 🎯 Skill Capabilities

The Maxwell SharePlay skill can help with:

- **Session Management**: Setup, lifecycle, participant handling
- **UI Implementation**: HIG-compliant components and layouts
- **Performance**: Optimization, concurrency, memory management
- **Platform Integration**: visionOS spatial features, iOS/ macOS specifics
- **Error Handling**: Recovery patterns, network resilience
- **Testing**: Validation frameworks, accessibility compliance
- **Best Practices**: Production-tested patterns and approaches

## 🔄 Updates

The skill is actively maintained with:
- Latest Apple SDK updates
- New platform features and guidelines
- Performance optimizations
- Additional code patterns and examples

## 🤝 Contributing

To update the skill:
1. Modify files in the `skill/` or `agent/` directories
2. Run `./install.sh` to apply changes
3. Restart Claude to load updates

## 📄 License

This skill contains Apple documentation excerpts and examples for educational purposes. The original code and documentation are provided under fair use for developer assistance.

---

**Version**: 2.0.0
**Last Updated**: November 2025
**Compatibility**: visionOS 2.0+, iOS 17.0+, macOS 14.0+