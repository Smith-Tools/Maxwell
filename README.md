# Maxwell - Framework Expertise & Cross-Domain Integration System

**Maxwell** is a knowledge and expertise system for helping developers and AI agents navigate complex, multi-framework Apple development. Maxwell provides both auto-triggered skills for quick answers and a hybrid knowledge router that coordinates with sosumi for comprehensive coverage.

> **Core Insight**: Maxwell's value is its knowledge content (63 Swift implementation files and extensive framework expertise), not the architecture. The system provides practical patterns and real-world solutions for modern Apple development.

**For the architectural decision and rationale, see [`ARCHITECTURE-DECISION.md`](ARCHITECTURE-DECISION.md)** - especially if you're wondering "why Maxwell instead of upgrading Smith?" or "why not consolidate everything?"

## Architecture Overview

Maxwell follows a **Hybrid Knowledge Routing** architecture that combines multiple expertise sources:

```
maxwell/
├── skills/                   # Specialized expertise modules
│   ├── skill-tca/           # The Composable Architecture expertise
│   ├── skill-shareplay/     # SharePlay & spatial experiences
│   ├── skill-pointfree/     # Point-Free ecosystem integration
│   └── skill-maxwell/       # Core routing & coordination
├── database/                # SQLite knowledge storage
│   ├── SimpleDatabase.swift # Core SQLite implementation
│   ├── SimpleMigrator.swift # Database migration tools
│   └── Package.swift        # Swift package configuration
├── TCA/                     # TCA-specific tools & validation
├── SharePlay/               # SharePlay-specific resources
├── PointFree/               # Point-Free integration layer
└── _development/            # Implementation guides & research
```

## The Simple Architecture

Maxwell follows a clean **Skill + Subagent** architecture:

1. **Maxwell Skills** (auto-triggered): Quick pattern lookup from SQLite database
2. **Maxwell Subagents** (explicit): Deep expertise with file access and sosumi integration

**Simple Workflow:**
```
Developer Question
    ↓
Auto-trigger: maxwell skill (keywords: @Shared, SharePlay, etc.)
    ↓
Simple question?
  ✅ → Return pattern from Maxwell DB (2 seconds)
  ❌ → Recommend explicit subagent invocation
    ↓
Task("maxwell-tca", ...) or Task("maxwell-shareplay", ...)
    ↓
Subagent analyzes code + Maxwell patterns + sosumi (when needed)
```

**sosumi Integration:**
- **Maxwell patterns**: Extracted patterns and curated expertise
- **Maxwell subagents**: Can call sosumi for official Apple documentation
- **Standard agent pattern**: Like any expert agent, Maxwell subagents use sosumi when needed

## Maxwell's Pattern-First Philosophy

### What Maxwell Does
- ✅ **Extracts patterns** from official documentation (TCA, SharePlay, Point-Free)
- ✅ **Curates expertise** by identifying meaningful, reusable patterns
- ✅ **Points to canonical sources** for always-current documentation
- ✅ **Maintains freshness** through manual validation and event-driven updates

### What Maxwell Doesn't Do
- ❌ **Ingest raw documentation** (sosumi handles this perfectly)
- ❌ **Auto-detect changes** in unstructured content (complex and error-prone)
- ❌ **Maintain document copies** (creates maintenance burden)
- ❌ **Compete with sosumi** (different purposes, different strengths)

### The Manual Update Philosophy
- **Event-driven**: Update patterns when problems are discovered or TCA versions change
- **Human validation**: Manual review ensures pattern correctness and relevance
- **Freshness tracking**: Timestamps help identify when patterns need review
- **Sustainable maintenance**: Focused updates rather than automatic synchronization

### Why This Matters

Modern Apple apps are multi-framework:
```
App = TCA state + SharePlay collaboration + RealityKit 3D
      + CloudKit sync + Core Data + SwiftUI/AppKit
```

A developer doesn't ask "How do I use TCA?" but rather:
**"How do I sync RealityKit entities across a TCA-managed SharePlay session?"**

This is a cross-domain question. The unified knowledge layer makes it answerable.

## Available Modules

### SharePlay Module (`skill-shareplay`)
**Specialization**: Apple's GroupActivities framework and shared experiences

- **Complete implementation guidance**: 50+ documentation files with real-world patterns
- **Cross-platform support**: iOS, iPadOS, macOS, visionOS
- **Production-ready examples**: Based on actual implementation experience
- **HIG compliance**: Apple Human Interface Guidelines integration
- **Spatial computing**: VisionOS-specific patterns and features
- **Code snippets**: Advanced concurrency patterns, session detection, error recovery

**Usage**: `skill: "maxwell-shareplay"` - Auto-triggered on SharePlay keywords

### TCA Module (`skill-tca`)
**Specialization**: The Composable Architecture (TCA) for Swift development

- **Modern Swift patterns**: Latest TCA APIs and best practices
- **Anti-pattern detection**: Common mistakes with solutions and migration paths
- **Validation rules**: Swift files for architectural enforcement
- **Testing integration**: Comprehensive testing strategies and examples
- **Decision trees**: Architectural guidance for state management
- **Performance optimization**: Type inference and dependency injection patterns

**Usage**: `skill: "maxwell-tca"` - Auto-triggered on TCA keywords

### Point-Free Module (`skill-pointfree`)
**Specialization**: Point-Free ecosystem coordination and integration

- **Multi-framework coordination**: TCA, Dependencies, Navigation, Testing
- **Decision trees**: Framework selection and integration patterns
- **Integration patterns**: Full-stack examples and delegation protocols
- **Framework detection**: Automatic routing to appropriate specialists
- **Anti-pattern validation**: Cross-framework architectural rules

**Usage**: `skill: "pointfree"` - Multi-framework coordination expertise

### Maxwell Core (`skill-maxwell`)
**Specialization**: Framework expertise routing and cross-domain coordination

- **Multi-framework expertise**: TCA, SharePlay, RealityKit integration patterns
- **Auto-triggering**: Intelligent keyword detection and routing
- **Cross-domain recommendations**: When to escalate to comprehensive analysis
- **Knowledge synthesis**: Combines multiple expertise areas

**Usage**: `skill: "maxwell"` - Core routing and framework expertise

## Development Workflow

Maxwell enables a sophisticated AI development loop:

1. **Main Agent** receives feature request
2. **Delegation** to specialized sub-agent based on domain requirements
3. **Guided Implementation** with patterns and architectural advice
4. **Smith Validation** runs rules from the same module
5. **Violation Reports** identify architectural issues
6. **Iterative Refinement** until validation passes
7. **Integration** of completed feature

## Installation

### Cloud Deployment
Each Maxwell module is designed to be deployed as:

1. **Agent Installation**: Register the specialized agent in your cloud agent registry
2. **Skill Installation**: Add the knowledge base to your skills registry
3. **Validation Rules**: Configure Smith validation with the module's rulesets

### Usage Patterns

#### Skill-Based Access
```bash
# Direct skill invocation
skill: "maxwell-shareplay"  # SharePlay expertise
skill: "maxwell-tca"        # TCA expertise
```

#### Agent Delegation
Main agents can delegate to specialized agents:
```
delegate_to: "maxwell-shareplay"  # For GroupActivities implementation
delegate_to: "maxwell-tca"        # For TCA architecture
```

#### Validation Integration
```bash
# Run Smith validation with module rules
smith validate --rules tca/validation/
smith validate --rules shareplay/validation/
```

## Validation System

Maxwell includes the **Smith Validation** framework for architectural enforcement:

- **Architecture Compliance**: Ensures implementations follow best practices
- **Pattern Validation**: Verifies correct usage of framework patterns
- **Quality Gates**: Acts like unit tests for architectural decisions
- **Violation Reporting**: Detailed feedback on implementation issues
- **Iterative Improvement**: Guides refinement until compliance is achieved

## Module Standards

All Maxwell modules adhere to strict quality standards:

- **Production-Ready Code**: No deprecated APIs or experimental patterns
- **Apple Compliance**: Validated against official documentation and HIG
- **Real-World Examples**: Based on production applications, not toy examples
- **Comprehensive Testing**: Complete validation coverage
- **Documentation Quality**: Clear, actionable guidance with examples
- **Cross-Platform Support**: Consistent patterns across Apple platforms

## Contributing

### Module Structure
New modules should follow the established architecture:

1. **Create module directory** with standard structure
2. **Implement agent behavior** in `agent/maxwell-{module}.md`
3. **Develop comprehensive skill** documentation and examples
4. **Create validation rules** for Smith integration
5. **Test thoroughly** before deployment

### Quality Requirements

- **9.2+ quality rating** for expertise and completeness
- **Production readiness** with no experimental code
- **Documentation completeness** with examples and patterns
- **Validation coverage** for all architectural decisions
- **Cross-platform consistency** where applicable

## Development Status

### ✅ Completed & Deployed
- **SharePlay Module**: Implementation guides with canonical source references
- **TCA Module**: Pattern storage with searchable SQLite database
- **Point-Free Module**: Multi-framework coordination expertise
- **Maxwell Core**: Pattern-only skill with manual update philosophy
- **Database Implementation**: SQLite pattern storage (not documentation ingestion)

### 🔄 Core Architecture
- **Pattern-First Philosophy**: Maxwell extracts and curates patterns, not raw docs
- **Canonical Source References**: Markdown tables pointing to authoritative documentation
- **SQLite Pattern Database**: Simple, searchable pattern storage
- **Manual Update Workflow**: Event-driven pattern updates when needed
- **Freshness Tracking**: Manual validation timestamps for pattern health

### 📋 Available for Extension
- **RealityKit Module**: Placeholder exists, ready for spatial computing patterns
- **Swift Module**: Placeholder exists, ready for language-level expertise
- **SwiftUI Module**: Placeholder exists, ready for UI framework patterns

## License

Maxwell is designed as an open architecture system for AI development assistance. Each module may have specific licensing terms based on its content and source materials.

## Support

For module-specific issues and questions:
- **SharePlay**: Refer to `SharePlay/README.md`
- **TCA**: Refer to `TCA/README.md`
- **General**: Check module-specific documentation first

---

**Maxwell** - Building the future of AI-assisted development, one specialized module at a time.