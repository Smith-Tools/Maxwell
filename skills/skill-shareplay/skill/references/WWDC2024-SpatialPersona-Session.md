# WWDC 2024 Session 10201: Customize spatial Persona templates in SharePlay

## Session Information
- **Title**: Customize spatial Persona templates in SharePlay
- **Duration**: 36m 26s
- **URL**: https://developer.apple.com/videos/play/wwdc2024/10201
- **Word Count**: 5,921

## Key Topics Covered
1. **Custom spatial Persona templates** for visionOS SharePlay experiences
2. **Fine-tuning Persona placement** relative to your app
3. **Sample app implementation** with SharePlay
4. **Moving participants between seats**
5. **Simulator testing** of spatial templates
6. **Best practices** for custom spatial templates

## Critical Implementation Requirements (from production code analysis)

### SystemCoordinator Configuration (Mandatory)
```swift
if let coordinator = await session.systemCoordinator {
    var config = SystemCoordinator.Configuration()
    config.supportsGroupImmersiveSpace = true
    coordinator.configuration = config
    self.systemCoordinator = coordinator
}
```

### Entitlements Required
- `com.apple.developer.groupactivities`
- `com.apple.developer.group-session`

## Implementation Status
✅ SystemCoordinator configuration added to DefaultImmersiveTemplate
✅ Proper entitlements configured
✅ Session management with spatial persona support
✅ Cleanup handling for SystemCoordinator

## Next Steps
Test spatial persona appearance in immersive space with SharePlay participants.