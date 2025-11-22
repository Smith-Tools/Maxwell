# SharePlay Canonical Sources

This file lists the authoritative sources for SharePlay documentation that Maxwell references.

## Primary Sources

| Source | URL | Type | Last Verified |
|--------|-----|------|---------------|
| **Apple GroupActivities Documentation** | https://developer.apple.com/documentation/groupactivities | Official Apple | 2025-01-22 |
| **Apple SharePlay HIG** | https://developer.apple.com/design/human-interface-guidelines/shareplay/ | Apple Design Guidelines | 2025-01-22 |
| **Apple SharePlay Videos** | https://developer.apple.com/videos/play/?q=shareplay | Apple Developer Videos | 2025-01-22 |

## Critical Documentation

| Topic | Path | Description | Relevance |
|-------|------|-------------|-----------|
| **GroupSession** | GroupActivities/GroupSession.html | Main session management | ⭐⭐⭐⭐⭐ Critical |
| **GroupSessionMessenger** | GroupActivities/GroupSessionMessenger.html | Data synchronization | ⭐⭐⭐⭐⭐ Critical |
| **GroupActivity** | GroupActivities/GroupActivity.html | Activity definition | ⭐⭐⭐⭐⭐ Critical |
| **GroupStateObserver** | GroupActivities/GroupStateObserver.html | State change observation | ⭐⭐⭐⭐ Important |

## Platform-Specific Topics

| Platform | Documentation | Notes | Relevance |
|----------|--------------|-------|-----------|
| **iOS** | Standard SharePlay APIs | Primary platform | ⭐⭐⭐⭐⭐ Critical |
| **iPadOS** | Same as iOS + iPad considerations | Multi-user iPad apps | ⭐⭐⭐⭐ Important |
| **macOS** | macOS SharePlay support | Catalyst apps | ⭐⭐⭐ Helpful |
| **visionOS** | Spatial SharePlay experiences | Vision Pro apps | ⭐⭐⭐⭐ Critical |

## Key WWDC Sessions

| Year | Session | Topic | Relevance |
|------|--------|-------|-----------|
| **2025** | Session 318 - Share visionOS experiences with nearby people | visionOS + SharePlay | ⭐⭐⭐⭐⭐ Latest |
| **2024** | Multiple sessions on spatial persona integration | visionOS features | ⭐⭐⭐⭐⭐ Current |
| **2023** | Building Spatial SharePlay Experiences | Early visionOS | ⭐⭐⭐⭐ Historical |
| **2022** | SharePlay introduction and best practices | iOS + iPadOS | ⭐⭐⭐⭐ Foundations |

## Human Interface Guidelines

| Section | Path | Guidelines | Relevance |
|---------|------|-----------|-----------|
| **Setup Flows** | Getting started | User onboarding experience | ⭐⭐⭐⭐⭐ Critical |
| **Multiplayer Experience** | Design patterns | Multi-user UX considerations | ⭐⭐⭐⭐ Important |
| **Spatial Computing** | visionOS guidelines | 3D collaboration design | ⭐⭐⭐⭐⭐ Critical |
| **Accessibility** | Inclusive design | Accessibility requirements | ⭐⭐⭐ Important |

## Common Implementation Patterns

| Pattern | Apple Documentation | Best Practices | Relevance |
|---------|-------------------|---------------|-----------|
| **Session Management** | GroupSession lifecycle | Proper cleanup and state | ⭐⭐⭐⭐⭐ Critical |
| **Data Synchronization** | GroupSessionMessenger usage | Efficient data sharing | ⭐⭐⭐⭐⭐ Critical |
| **Participant Management** | Join/Leave flows | User experience design | ⭐⭐⭐⭐⭐ Critical |
| **Error Handling** | Error recovery patterns | Robust error handling | ⭐⭐⭐⭐ Important |
| **Performance** | Optimization guidelines | Responsive user experience | ⭐⭐⭐ Helpful |

## Related Apple Frameworks

| Framework | Documentation | Integration | Relevance |
|-----------|----------------|------------|-----------|
| **RealityKit** | https://developer.apple.com/documentation/realitykit/ | 3D content sharing | ⭐⭐⭐⭐⭐ Critical |
| **ARKit** | https://developer.apple.com/documentation/arkit/ | AR experiences | ⭐⭐⭐⭐ Important |
| **Core Data** | https://developer.apple.com/documentation/coredata/ | Data persistence | ⭐⭐⭐ Helpful |
| **CloudKit** | https://developer.apple.com/documentation/cloudkit/ | Cloud synchronization | ⭐⭐⭐ Helpful |

## Verification Script

```bash
#!/bin/bash
echo "Verifying SharePlay canonical sources..."

# Check Apple GroupActivities docs
curl -s -o /dev/null -w "%{http_code}" "https://developer.apple.com/documentation/groupactivities"
echo " - Apple GroupActivities: $([ "$status_code" = "200" ] && echo "✅ OK" || echo "❌ Failed")"

# Check SharePlay HIG
curl -s -o /dev/null -w "%{http_code}" "https://developer.apple.com/design/human-interface-guidelines/shareplay/"
echo " - SharePlay HIG: $([ "$status_code" = "200" ] && echo "✅ OK" || echo "❌ Failed")"

# Check SharePlay videos
curl -s -o /dev/null -w "%{http_code}" "https://developer.apple.com/videos/play/?q=shareplay"
echo " - SharePlay Videos: $([ "$status_code" = "200" ] && echo "✅ OK" || echo "❌ Failed")"

# Check RealityKit docs (critical integration)
curl -s -o /dev/null -w "%{http_code}" "https://developer.apple.com/documentation/realitykit"
echo " - RealityKit Docs: $([ "$status_code" = "200" ] && echo "✅ OK" || echo "❌ Failed")"
```

## Update Policy

This file should be updated when:
- New SharePlay features are announced (especially visionOS)
- Apple updates the SharePlay HIG
- New WWDC sessions relevant to SharePlay are released
- URL structures change
- New integration patterns become common

**Last Updated**: 2025-01-22
**Next Review**: After major Apple developer conference (WWDC)
**High Priority Changes**: visionOS SharePlay updates, spatial persona integration