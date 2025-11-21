# SharePlay Knowledge Base: Complete Implementation Guide

## 🎯 Overview

This is the **definitive SharePlay knowledge base** for visionOS development, covering everything from basic session management to advanced spatial collaboration with mixed reality features.

---

## 📚 Documentation Structure

### **🏛️ Core Implementation Guides**

1. **[Foundations](./guides/foundations.md)** - Essential SharePlay concepts and setup
2. **[Activity Definition](./guides/activity-definition.md)** - Complete activity configuration and ShareLink integration
3. **[Data Synchronization](./guides/data-synchronization.md)** - Real-time messaging and state management
4. **[Scene Management](./guides/scene-management.md)** - Windows, spaces, and multi-scene coordination
5. **[Spatial Features](./guides/spatial-features.md)** - VisionOS spatial personas and immersive experiences

### **🚀 Advanced Integration Patterns**

6. **[VisionOS 26 Features](./guides/visionos26-features.md)** - Latest APIs and capabilities
7. **[Nearby Sharing](./guides/nearby-sharing.md)** - Same-room collaboration with ARKit
8. **[Production Patterns](./guides/production-patterns.md)** - Real-world implementation strategies
9. **[GroupActivityAssociation](./guides/scene-association.md)** - Modern declarative scene coordination

### **🧰 Reference Materials**

- **[API Reference](./reference/api.md)** - Complete API documentation
- **[WWDC Sessions](./reference/wwdc-sessions.md)** - Key session analyses
- **[Sample Code](./reference/samples.md)** - Production app analyses
- **[Troubleshooting](./reference/troubleshooting.md)** - Common issues and solutions

---

## 🚀 Quick Start

### **For New Apps (Recommended Approach)**

```swift
// 1. Define your activity
struct MyActivity: GroupActivity, Transferable {
    static let activityIdentifier = "com.myapp.myactivity"

    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "My Activity"
        metadata.type = .generic
        return metadata
    }
}

// 2. Add hidden ShareLink for system integration
ShareLink(
    item: MyActivity(),
    preview: SharePreview("My Activity")
).hidden()

// 3. Configure scene association
.windowGroup
.groupActivityAssociation(.primary("main-activity"))
```

### **For Existing Apps**

Use the migration guide in [Scene Association](./guides/scene-association.md) to upgrade from legacy patterns.

---

## 🎯 Implementation Paths

### **Basic SharePlay**
1. Read [Foundations](./guides/foundations.md)
2. Follow [Activity Definition](./guides/activity-definition.md)
3. Implement [Data Synchronization](./guides/data-synchronization.md)

### **Spatial Experiences (visionOS)**
1. Complete basic implementation
2. Add [Scene Management](./guides/scene-management.md)
3. Implement [Spatial Features](./guides/spatial-features.md)

### **Advanced Production Apps**
1. Study [Production Patterns](./guides/production-patterns.md)
2. Review [Examples](./examples/)
3. Check [VisionOS 26 Features](./guides/visionos26-features.md)

---

## 🔧 Essential Setup

### **Required Configuration**

```swift
// 1. Enable multiple scenes (Info.plist)
<key>UIApplicationSupportsMultipleScenes</key>
<true/>

// 2. GroupActivities entitlement
// 3. Scene association setup
// 4. SystemCoordinator configuration (for spatial features)
```

### **Required Dependencies**

- `import GroupActivities`
- `import SwiftUI`
- VisionOS: `import RealityKit` (for spatial features)

## Quick Start

### 1. Using the SharePlay Skill

The SharePlay Skill is automatically triggered by queries containing:
- "SharePlay"
- "GroupActivities"
- "shared experience"
- "multiplayer"
- "collaborative"

**Example Usage:**
```
"How do I implement SharePlay for my visionOS collaborative whiteboard?"
"What's the best pattern for synchronizing state in a SharePlay session?"
"My SharePlay session isn't working with immersive spaces, what could be wrong?"
```

### 2. Using the Research Sub-Agent

For project-specific analysis, use the SharePlay Researcher:

```bash
# Analyze a specific feature
claude code --agent shareplay-researcher "Analyze the collaborative drawing feature for SharePlay integration"

# Project-wide assessment
claude code --agent shareplay-researcher "Assess the entire visionOS project for SharePlay opportunities"

# Investigation
claude code --agent shareplay-researcher "Investigate current GroupActivities usage and identify gaps"
```

### 3. Implementation Workflow

#### Recommended Development Process:

1. **Research Phase** (Research Sub-Agent)
   ```bash
   claude code --agent shareplay-researcher "Analyze [feature-name] for SharePlay"
   ```
   → Generates `docs/shareplay-[feature]-analysis.md`

2. **Planning Phase** (Templates)
   ```bash
   cp templates/implementation-plan-template.md docs/shareplay-[feature]-plan.md
   ```
   → Customize the plan based on research analysis

3. **Implementation Phase** (Main Agent + Skill + Snippets)
   ```
   "Read docs/shareplay-[feature]-analysis.md and implement the SharePlay integration using the SharePlay Skill"
   ```

4. **Testing Phase** (Examples + Skill)
   - Use testing scenarios from `examples/`
   - Follow test requirements from SharePlay Skill

## File Structure

```
/Volumes/Plutonian/_Developer/Maxwells/source/SharePlay/
├── SKILL.md                           # Core SharePlay expertise
├── research-agent-config.md          # Research sub-agent configuration
├── README.md                         # This file
├── examples/                         # Concrete implementation examples
│   ├── window-menubar-integration.md
│   └── waiting-room-mechanics.md
├── snippets/                         # Reusable code patterns
│   └── basic-shareplay-setup.swift
└── templates/                        # Planning and documentation templates
    └── implementation-plan-template.md
```

## Usage Patterns

### Pattern 1: Feature Development
```
User: "I want to add SharePlay to my visionOS 3D model viewer"

Claude: (Uses SharePlay Skill)
"Let me help you implement SharePlay for your 3D model viewer. Based on the SharePlay Skill, here's the approach..."

[Implementation proceeds using Skill guidance and snippets]
```

### Pattern 2: Project Analysis
```
User: "Analyze my visionOS project for SharePlay opportunities"

Claude: (Invokes Research Sub-Agent)
"I'll use the SharePlay Researcher to analyze your project and generate recommendations..."

[Research agent produces docs/shareplay-overview.md]
```

### Pattern 3: Problem Solving
```
User: "My SharePlay session crashes when transitioning to immersive space"

Claude: (Uses SharePlay Skill + Examples)
"This sounds like an issue with session state during transitions. Let me check the SharePlay Skill and the immersive space example..."
```

## Skill Evolution

This system is designed to evolve with visionOS and SharePlay capabilities:

### Extending the Skill
1. **New Framework Support**: Add patterns to `SKILL.md`
2. **Advanced Examples**: Add to `examples/` directory
3. **Code Patterns**: Add to `snippets/` directory
4. **New Templates**: Create specialized templates

### Updating Knowledge
- Monitor Apple documentation updates
- Test new visionOS features with SharePlay
- Update patterns based on real-world usage
- Share learnings back to the community

## Success Scenarios Supported

### ✅ Window Menu Bar Integration
**Files**: `examples/window-menubar-integration.md`
**Key Features**:
- SharePlay controls in window menu
- Immersive space transition coordination
- Session state preservation

### ✅ Waiting Room Mechanics
**Files**: `examples/waiting-room-mechanics.md`
**Key Features**:
- Minimum participant thresholds
- Synchronized start countdowns
- Real-time participant management

### ✅ Basic Setup & Integration
**Files**: `snippets/basic-shareplay-setup.swift`
**Key Features**:
- Core GroupActivity setup
- Session management
- State synchronization basics

## Quality Assurance

### Skill Quality Checks
- ✅ Framework-agnostic patterns
- ✅ Comprehensive anti-patterns section
- ✅ Clear implementation workflows
- ✅ Testing requirements defined
- ✅ Evolution strategy included

### Research Agent Quality
- ✅ Standardized output templates
- ✅ Clear analysis boundaries
- ✅ Architecture-agnostic recommendations
- ✅ Comprehensive context analysis

### Implementation Resources
- ✅ Real-world example scenarios
- ✅ Reusable code snippets
- ✅ Comprehensive planning templates
- ✅ Clear documentation

## Troubleshooting

### Common Issues

**Skill Not Triggering**
- Check for trigger keywords: "SharePlay", "GroupActivities", etc.
- Use explicit reference: "Using the SharePlay Skill, help me..."

**Research Agent Not Available**
- Ensure agent is configured per `research-agent-config.md`
- Check that allowed tools are properly configured

**Implementation Problems**
- Refer to anti-patterns in `SKILL.md`
- Check examples for similar scenarios
- Use research agent for project-specific analysis

## Best Practices

### For Development Teams
1. **Always start with research analysis** for complex features
2. **Use the Skill consistently** across all SharePlay work
3. **Follow the testing requirements** from the Skill
4. **Update patterns** based on real implementation experience

### For Individual Developers
1. **Read the relevant examples** before starting implementation
2. **Use the planning template** for organized development
3. **Reference anti-patterns** to avoid common mistakes
4. **Test with real devices** and network conditions

## Contributing

### Adding New Knowledge
1. Update relevant sections in `SKILL.md`
2. Add examples to `examples/` directory
3. Create code snippets for `snippets/`
4. Document new patterns in templates

### Feedback Loop
1. Use the system on real projects
2. Identify gaps or issues
3. Update based on lessons learned
4. Share improvements with the team

---

**Version**: 1.0.0
**Last Updated**: [Current Date]
**Maintainer**: [Your Name/Team]