# TCA Canonical Sources

This file lists the authoritative sources for TCA documentation that Maxwell references.

## Primary Sources

| Source | URL | Type | Purpose | Last Verified |
|--------|-----|------|---------|---------------|
| **DocC Source Repository** | https://github.com/pointfreeco/swift-composable-architecture/tree/main/Sources/ComposableArchitecture/Documentation.docc | GitHub | **AI Agent Consumption** | 2025-01-22 |
| **Swift Package Index** | https://swiftpackage-index.com/pointfreeco/swift-composable-architecture/documentation | Documentation | **Human Consumption** | 2025-01-22 |
| **Point-Free TCA Collection** | https://www.pointfree.co/collections/composable-architecture | Website | **Learning Videos** | 2025-01-22 |

## Key Articles in DocC

| Article | Path | Topic | Relevance |
|---------|------|-------|-----------|
| **SharingState** | Articles/SharingState.md | @Shared patterns | ⭐⭐⭐⭐⭐ Critical |
| **Navigation** | Articles/Navigation.md | Navigation patterns | ⭐⭐⭐⭐⭐ Critical |
| **DependencyManagement** | Articles/DependencyManagement.md | Dependencies | ⭐⭐⭐⭐⭐ Critical |
| **TestingTCA** | Articles/TestingTCA.md | Testing strategies | ⭐⭐⭐⭐ Important |
| **ObservationBackport** | Articles/ObservationBackport.md | @Observative patterns | ⭐⭐⭐ Important |
| **Performance** | Articles/Performance.md | Performance optimization | ⭐⭐⭐ Helpful |

## Migration Guides

| Version | Article | Status | Notes |
|---------|---------|--------|-------|
| **1.18** | Articles/MigrationGuides/MigratingTo1.18.md | Current | Latest version |
| **1.17** | Articles/MigrationGuides/MigratingTo1.17.md | Previous | Key features introduced |
| **1.16** | Articles/MigrationGuides/MigratingTo1.16.md | Historical | Reference only |

## Related Point-Free Libraries

| Library | GitHub | Documentation | Used With |
|---------|--------|---------------|-----------|
| **Dependencies** | https://github.com/pointfreeco/swift-dependencies | https://www.pointfree.co/collections/dependencies | Dependency injection |
| **Navigation** | https://github.com/pointfreeco/swift-navigation | https://www.pointfree.co/collections/navigation | Navigation patterns |
| **Swift Testing** | https://github.com/pointfreeco/swift-testing | https://www.pointfree.co/collections/swift-testing | TCA testing |

## AI vs Human Documentation Consumption

### Why Maxwell Uses DocC Source Repository

**The Problem with Swift Package Index:**
- AI agents cannot consume rendered documentation on Swift Package Index
- Interactive JavaScript interfaces are not accessible to text-based AI tools
- Human-friendly navigation prevents automated pattern extraction

**The Solution - DocC Source Repository:**
- **Raw Markdown Files**: `.md` files are directly consumable by AI agents
- **Structured Content**: Well-organized article hierarchy for systematic extraction
- **Git Version Control**: Links to specific commits/versions for accurate attribution
- **No Rendering Dependency**: Pure text content without JavaScript complexity

### Usage Guidelines

**For AI Agents (Maxwell):**
- Use **DocC Source Repository** for pattern extraction and analysis
- Access raw markdown files directly from the GitHub repository
- Reference specific file paths for accurate citations
- Track file modifications for freshness monitoring

**For Human Developers:**
- Use **Swift Package Index** for beautifully rendered documentation
- Navigate through interactive examples and code snippets
- Benefit from search functionality and cross-references
- Get the best human-optimized reading experience

**For Learning (Point-Free Videos):**
- Use **Point-Free TCA Collection** for conceptual understanding
- Watch video tutorials alongside code examples
- Get deeper insights into architectural decisions
- Understand the philosophy behind TCA design

### Verification Script

## Verification Script

To verify these sources are still accessible:

```bash
#!/bin/bash
echo "Verifying TCA canonical sources..."

# Check DocC source repository (AI consumption)
curl -s -o /dev/null -w "%{http_code}" "https://github.com/pointfreeco/swift-composable-architecture/tree/main/Sources/ComposableArchitecture/Documentation.docc"
echo " - TCA DocC Source (AI): $([ "$status_code" = "200" ] && echo "✅ OK" || echo "❌ Failed")"

# Check Swift Package Index (human consumption)
curl -s -o /dev/null -w "%{http_code}" "https://swiftpackage-index.com/pointfreeco/swift-composable-architecture/documentation"
echo " - Swift Package Index (Human): $([ "$status_code" = "200" ] && echo "✅ OK" || echo "❌ Failed")"

# Check Point-Free site (learning)
curl -s -o /dev/null -w "%{http_code}" "https://www.pointfree.co/collections/composable-architecture"
echo " - Point-Free TCA (Learning): $([ "$status_code" = "200" ] && echo "✅ OK" || echo "❌ Failed")"

# Test AI agent consumption
echo ""
echo "🤖 Testing AI Agent Consumption:"
if curl -s "https://raw.githubusercontent.com/pointfreeco/swift-composable-architecture/main/Sources/ComposableArchitecture/Documentation.docc/Articles/SharingState.md" | grep -q "# Sharing state"; then
    echo " ✅ Raw markdown accessible to AI agents"
else
    echo " ❌ Raw markdown not accessible"
fi

# Test human consumption
echo ""
echo "👤 Testing Human Consumption:"
if curl -s "https://swiftpackage-index.com/pointfreeco/swift-composable-architecture/documentation" | grep -q "Sharing state"; then
    echo " ✅ Rendered documentation accessible to humans"
else
    echo " ❌ Rendered documentation not accessible"
fi
```

## Update Policy

This file should be updated when:
- Major TCA version changes occur
- New critical documentation articles are added
- URL structures change
- New Point-Free libraries become relevant for TCA development

**Last Updated**: 2025-01-22
**Next Review**: When TCA 1.19+ is released