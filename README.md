# Maxwell - AI Agent Architecture System

**Maxwell** is a modular AI agent architecture system designed for cloud-based development assistance. Each module provides specialized expertise for specific frameworks and domains, complete with agents, skills, and validation rules.

## Architecture Overview

Maxwell follows a consistent **Agent + Skill + Validation** architecture for each specialization:

```
maxwell-module/
├── agent/                    # Specialized AI agent
│   └── maxwell-{module}.md  # Agent behavior and capabilities
├── skill/                    # Knowledge base
│   ├── SKILL.md             # Main skill documentation
│   ├── guides/              # Implementation guides
│   ├── examples/            # Real-world patterns
│   ├── references/          # Documentation and research
│   ├── snippets/            # Code templates
│   └── resources/           # Additional resources
├── validation/               # Architecture enforcement rules
│   └── *.smith              # Smith validation rulesets
├── _development/            # Development and research content
└── README.md                # Module-specific documentation
```

## Available Modules

### SharePlay Module
**Specialization**: Apple's GroupActivities framework and shared experiences

- **Cross-platform support**: iOS, iPadOS, macOS, visionOS
- **40+ documentation files**: Complete implementation guidance
- **Production-ready patterns**: Based on real-world apps like GreenSpurt
- **HIG compliance**: Apple Human Interface Guidelines validation
- **Spatial computing**: VisionOS-specific patterns and features

**Usage**: `skill: "maxwell-shareplay"` or agent delegation for SharePlay implementation

### TCA Module
**Specialization**: The Composable Architecture (TCA) 1.23.0+ for Swift development

- **Modern Swift 6.2+ patterns**: Strict concurrency and latest APIs
- **Anti-pattern detection**: Common mistakes and migration paths
- **Decision trees**: Architectural guidance for state management
- **Testing integration**: Swift Testing framework support
- **Performance optimization**: Type inference and dependency injection

**Usage**: `skill: "maxwell-tca"` or agent delegation for TCA architecture

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

- ✅ **SharePlay Module**: Complete with 40+ documentation files
- ✅ **TCA Module**: Complete with modern Swift 6.2+ patterns
- 🔄 **RealityKit Module**: Framework in progress
- 🔄 **Swift Module**: Framework in progress
- 🔄 **SwiftUI Module**: Framework in progress

## License

Maxwell is designed as an open architecture system for AI development assistance. Each module may have specific licensing terms based on its content and source materials.

## Support

For module-specific issues and questions:
- **SharePlay**: Refer to `SharePlay/README.md`
- **TCA**: Refer to `TCA/README.md`
- **General**: Check module-specific documentation first

---

**Maxwell** - Building the future of AI-assisted development, one specialized module at a time.