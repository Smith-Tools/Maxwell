# Skill Architectural

**Specializes in:** Claude Code Skills, Sub-Agent Architecture, and Multi-Domain Specialist Systems

> **Domain Expertise:** Maxwell's own architectural patterns and real-world development practice

## When to Use This Skill

Use this architectural skill when:
- Designing multi-skill specialist systems
- Deciding between skills vs sub-agents
- Understanding Claude Code composition patterns
- Documenting architectural decisions
- Learning from Maxwell's real-world evolution

## Core Expertise Areas

### 1. Claude Code Skills vs Sub-Agents
- **Skills**: Domain expertise, reusable logic
- **Sub-Agents**: Autonomous behavior, complex routing
- **Composition**: When to use each, how they work together

### 2. Multi-Domain Specialist Architecture
- **Pattern**: One orchestrator + N domain specialists
- **Database**: Shared knowledge layer
- **Routing**: Intelligent domain detection
- **Boundaries**: Clear responsibility separation

### 3. Real-World Development Patterns
- **Evolution**: How architectures change in practice
- **Compromises**: Practical vs ideal solutions
- **Documentation**: Self-documenting systems
- **Learning**: Capturing architectural knowledge

## Maxwell's Architecture (Live Example)

### Current Implementation
```
Maxwell/
├── agent/              # Sub-agent orchestrator
├── skills/             # Domain specialists
│   ├── skill-tca/      # TCA expertise
│   ├── skill-shareplay/ # SharePlay expertise
│   └── skill-pointfree/ # PointFree expertise
└── database/           # Shared SQLite knowledge layer
```

### Architectural Decisions Made
- **Multi-skill**: Domain specialist pattern over monolithic approach
- **Shared database**: Cross-domain pattern visibility
- **Agent-level contradiction detection**: Lightweight orchestration
- **No central skill**: Avoid monolithic centralization

### Lessons Learned
- **Domain isolation** beats monolithic simplicity
- **Shared data layer** enables cross-domain insights
- **Lightweight orchestration** keeps system manageable
- **Self-documentation** captures architectural evolution

## Composition Guidelines

### When to Use Skills
- **Domain expertise**: TCA, SharePlay, VisionOS patterns
- **Reusable logic**: Pattern detection, database operations
- **Clear boundaries**: Well-defined problem spaces

### When to Use Sub-Agents
- **Complex routing**: Multi-step decision trees
- **Autonomous behavior**: Independent problem solving
- **State management**: Maintaining conversation context

### When to Combine
- **Specialist orchestration**: Maxwell's current pattern
- **Multi-domain problems**: Cross-cutting concerns
- **Complex workflows**: Multiple domain expertise needed

## Real-World Patterns

### Pattern 1: Specialist Architecture
```
Problem: Need expertise across multiple domains
Solution: One orchestrator + N domain specialists
Trade-offs: Complexity vs depth of expertise
```

### Pattern 2: Shared Knowledge Layer
```
Problem: Cross-domain pattern visibility
Solution: Centralized database with domain isolation
Trade-offs: Coupling vs shared insights
```

### Pattern 3: Lightweight Orchestration
```
Problem: Coordinating specialists without monolith
Solution: Agent-level startup checks + routing
Trade-offs: Limited control vs simplicity
```

## Anti-Patterns to Avoid

### ❌ Monolithic Skill
- **Problem**: Single skill handles all domains
- **Issue**: Becomes massive, hard to maintain
- **Alternative**: Domain specialist pattern

### ❌ No Shared Data
- **Problem**: Each skill isolated database
- **Issue**: No cross-domain pattern detection
- **Alternative**: Shared SQLite with domain boundaries

### ❌ Over-Engineering
- **Problem**: Complex automatic redirection
- **Issue**: Unnecessary complexity
- **Alternative**: Simple try/fallback routing

## Documentation Philosophy

### Self-Documenting Systems
- **Capture decisions**: Why we chose this architecture
- **Record trade-offs**: What we gained vs lost
- **Document evolution**: How and why things changed
- **Include failures**: What didn't work and why

### Living Documentation
- **Real examples**: Use actual implementation patterns
- **Practical advice**: Based on actual experience
- **Continuous updates**: Architecture evolves, docs follow
- **Honest assessment**: Both successes and challenges

---

**This skill documents Maxwell's own architectural journey - turning development reality into reusable knowledge.**

**Last Updated:** 2025-01-22
**Architecture Version:** Multi-domain specialist pattern
**Key Learning:** Domain isolation + shared data layer = optimal balance