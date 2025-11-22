# TCA Canonical Sources

This file lists the authoritative sources for TCA documentation that Maxwell references.

## Primary Sources

| Source | URL | Type | Last Verified |
|--------|-----|------|---------------|
| **Official DocC Documentation** | https://github.com/pointfreeco/swift-composable-architecture/tree/main/Sources/ComposableArchitecture/Documentation.docc | GitHub | 2025-01-22 |
| **Point-Free TCA Collection** | https://www.pointfree.co/collections/composable-architecture | Website | 2025-01-22 |

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

## Usage Notes

- **DocC Documentation**: Always prefer the latest version in the main branch
- **Point-Free Videos**: Provide deep conceptual understanding alongside patterns
- **Migration Guides**: Refer when upgrading TCA versions
- **Dependencies Library**: Essential for real-world TCA applications

## Verification Script

To verify these sources are still accessible:

```bash
#!/bin/bash
echo "Verifying TCA canonical sources..."

# Check GitHub repo
curl -s -o /dev/null -w "%{http_code}" "https://github.com/pointfreeco/swift-composable-architecture"
echo " - TCA GitHub Repository: $([ "$status_code" = "200" ] && echo "✅ OK" || echo "❌ Failed")"

# Check Point-Free site
curl -s -o /dev/null -w "%{http_code}" "https://www.pointfree.co/collections/composable-architecture"
echo " - Point-Free TCA: $([ "$status_code" = "200" ] && echo "✅ OK" || echo "❌ Failed")"

# Check Dependencies repo
curl -s -o /dev/null -w "%{http_code}" "https://github.com/pointfreeco/swift-dependencies"
echo " - Dependencies Library: $([ "$status_code" = "200" ] && echo "✅ OK" || echo "❌ Failed")"
```

## Update Policy

This file should be updated when:
- Major TCA version changes occur
- New critical documentation articles are added
- URL structures change
- New Point-Free libraries become relevant for TCA development

**Last Updated**: 2025-01-22
**Next Review**: When TCA 1.19+ is released