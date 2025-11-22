# Domain Specialist Template

## Template for Creating New Maxwell Domain Specialists

### Directory Structure Pattern

Based on successful Point-Free and SharePlay skills:

```
skill-domain/
├── SKILL.md                    # Skill definition and triggers
├── guides/                     # How-to guides for domain
│   ├── DOMAIN-PATTERNS.md      # Core patterns and best practices
│   ├── DOMAIN-INTEGRATION.md   # Integration with other domains
│   ├── DOMAIN-TESTING.md      # Domain-specific testing
│   └── README.md              # Guide overview
├── examples/                   # Complete feature examples
│   └── README.md              # Example overview
├── references/                 # Official documentation
│   ├── README.md              # Reference overview
│   └── domain-specific.md      # Links to external docs
├── validation/                 # Domain validation rules
│   ├── Rule_2_1_DomainPattern.md
│   ├── Rule_2_2_IntegrationPattern.md
│   └── README.md              # Validation overview
└── data/                       # Domain-specific data (if needed)
    └── README.md
```

### SKILL.md Template

```markdown
---
name: maxwell-domain
description: Specialist expertise for [Domain] development patterns, best practices, and architectural decisions. Authoritative guidance on [specific technologies, frameworks, concepts].
tags:
  - "[Domain]"
  - "[Keywords 1]"
  - "[Keywords 2]"
  - "[Keywords 3]"
triggers:
  - "[Trigger 1]"
  - "[Trigger 2]"
  - "[Trigger 3]"
  - "[Trigger 4]"
version: "1.0.0"
author: "Claude Code Skill - Maxwell Architecture"
---

# Domain Expertise Skill

**For:** [Target audience] working with [Domain] technologies
**Purpose:** Specialized guidance on [Domain] patterns, integration, and best practices
**Authority Level:** [canonical/expert/derived] - [Source of authority]
**Frameworks:** [List specific frameworks]

## 🎯 What This Skill Does

### Core Responsibilities

- **Pattern Authority**: Definitive source for [Domain] patterns and best practices
- **Integration Guidance**: How to work with other Maxwell skills (Point-Free, SharePlay, etc.)
- **Anti-Pattern Detection**: Common mistakes and deprecated approaches in [Domain]
- **Testing Strategies**: Domain-specific testing patterns and tools
- **Architecture Decisions**: Decision trees for [Domain] architectural choices

### When to Use This Skill

**You should invoke this skill when:**

```
# Domain-specific questions
"[Domain-specific question 1]"
"[Domain-specific question 2]"
"How should I [domain task]?"
"[Domain framework] best practices"

# Integration questions
"How do I integrate [Domain] with TCA?"
"[Domain] + SharePlay coordination"
"[Domain] architectural patterns"
```

## 🔄 Integration with Other Skills

### skill-pointfree (Point-Free Authority)
- **skill-domain**: [Domain] expertise and implementation details
- **skill-pointfree**: TCA integration patterns when needed
- **When combined**: Use skill-pointfree for TCA + [Domain], skill-domain for pure [Domain]

### skill-shareplay (SharePlay Specialist)
- **skill-domain**: [Domain] patterns in SharePlay context
- **skill-shareplay**: SharePlay coordination and GroupSession management
- **When combined**: skill-shareplay for SharePlay specifics, skill-domain for [Domain] expertise

### skill-architectural (Architecture Specialist)
- **skill-domain**: [Domain] patterns and integration strategies
- **skill-architectural**: Cross-domain architectural decisions
- **When combined**: skill-domain provides [Domain] knowledge, skill-architectural handles broader questions

## 📖 Core [Domain] Knowledge Areas

### 1. **[Domain] Pattern Foundations** (guides/DOMAIN-PATTERNS.md)
- Pattern 1: [Core pattern description]
- Pattern 2: [Core pattern description]
- Common mistakes and anti-patterns
- Performance considerations

### 2. **[Domain] Integration** (guides/DOMAIN-INTEGRATION.md)
- Integration with TCA patterns
- Integration with SharePlay patterns
- Cross-domain coordination strategies
- Dependency management

### 3. **[Domain] Testing** (guides/DOMAIN-TESTING.md)
- Testing strategies and tools
- Integration testing
- Performance testing
- Debugging approaches

### 4. **Validation Rules** (validation/)
- **Rule X.1**: [Validation rule 1]
- **Rule X.2**: [Validation rule 2]
- [Rule X.3**: [Validation rule 3]

## 🚨 Critical Anti-Patterns

**Domain-specific anti-patterns to avoid:**

| ❌ Anti-Pattern | ✅ Correct Approach | Why |
|------------------|------------------|-----|
| [Domain anti-pattern 1] | [Correct approach] | [Reason] |
| [Domain anti-pattern 2] | [Correct approach] | [Reason] |

## 🏗️ [Domain] Implementation Patterns

### Pattern 1: [Implementation Pattern]
```swift
// ✅ Modern Approach
[Correct implementation example]

// ❌ Deprecated Approach (Anti-Pattern)
[Deprecated implementation example]
```

### Pattern 2: [Integration Pattern]
```swift
// ✅ Integration Approach
[Integration example]
```

## 🎯 Decision Trees

### [Domain] Decision Tree
```
[Decision tree structure]
├─ Choice A → Approach A
├─ Choice B → Approach B
└─ Default → Default approach
```

## 🧪 Testing Patterns

### Domain Testing Strategy
```swift
[Test example for domain]
```

## 🔗 Related Resources

### Official [Domain] Documentation
- [Official link 1]
- [Official link 2]

### Maxwell Modules
- **skill-pointfree**: [Integration point 1]
- **skill-shareplay**: [Integration point 2]
- **skill-architectural**: [Integration point 3]

### Integration Guides
- **guides/DOMAIN-INTEGRATION.md** - Cross-domain patterns
- **validation/** - [Validation references]

## 📚 Documentation Organization

```
skill-domain/
├── SKILL.md                    ← You are here
├── guides/                    ← Domain guides
│   ├── DOMAIN-PATTERNS.md     ← Core patterns
│   ├── DOMAIN-INTEGRATION.md  ← Integration patterns
│   ├── DOMAIN-TESTING.md      ← Testing strategies
│   └── README.md              ← Guide overview
├── examples/                  ← Complete examples
├── references/                ← External documentation
├── validation/                ← Validation rules
└── data/                      ← Domain data
```

---

**[Domain] Expert v1.0.0 - Production Ready**

Specialized [Domain] expertise for modern development.

*Last updated: [Current date]*