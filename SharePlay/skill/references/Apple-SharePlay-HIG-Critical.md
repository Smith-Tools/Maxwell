# Apple SharePlay Human Interface Guidelines - Critical Reference

**Source**: https://developer.apple.com/design/human-interface-guidelines/shareplay/

**Critical Search Strategy**: Use terms like:
- `"apple shareplay"` - Most effective for finding official Apple docs
- `"apple shareplay visionOS"` - Platform-specific guidelines
- `"apple shareplay spatial persona"` - Spatial experiences
- `"apple shareplay HIG"` - Human Interface Guidelines

## Key HIG Principles (from session analysis)

### 1. Spatial Persona Design
- **Use Spatial Persona templates** for meaningful interactions
- **Design around shared context**, not individual experiences
- **Handle immersive content** properly in shared activities
- **Support spatial positioning** of UI elements

### 2. Scene Coordination Requirements
- **Associate both WindowGroup and ImmersiveSpace** with same SharePlay activity
- Use **handlesExternalEvents(matching:)** for proper scene association
- **Maintain consistent state** across all scenes
- **Ensure smooth transitions** between WindowGroup and ImmersiveSpace

### 3. User Experience Guidelines
- **Clear visual indicators** of SharePlay participation status
- **Intuitive controls** for starting/joining SharePlay sessions
- **Consistent participant representation** across all scenes
- **Proper feedback** for connection states and changes

### 4. Multi-Platform Considerations
- **Adapt UI** for different device capabilities
- **Handle device transitions** gracefully
- **Maintain session continuity** across form factors
- **Optimize spatial experiences** for each platform

## Implementation Pattern (from Green Spurt analysis)

```swift
// WindowGroup - Main app interface
WindowGroup {
    ContentView()
}
.handlesExternalEvents(matching: [activityIdentifier])

// ImmersiveSpace - Shared spatial experience
ImmersiveSpace(id: immersiveSpaceID) {
    ImmersiveView()
}
.handlesExternalEvents(matching: [activityIdentifier])
```

## Critical Requirements Checklist

- ✅ **SystemCoordinator configuration** with `supportsGroupImmersiveSpace = true`
- ✅ **Proper entitlements** (`com.apple.developer.groupactivities`, `com.apple.developer.group-session`)
- ✅ **Scene association** using `handlesExternalEvents(matching:)`
- ✅ **Session setup order** (SystemCoordinator → session.join())
- ✅ **Spatial persona support** for immersive experiences
- ✅ **Multi-scene coordination** between WindowGroup and ImmersiveSpace

## Missing from Current Implementation

- **HIG-compliant visual feedback** for SharePlay states
- **Consistent spatial persona positioning** guidelines
- **Cross-platform adaptation** patterns
- **Scene transition animations** for better UX

## Reference Importance

This HIG article is **critical** because it provides Apple's official guidance on:
- Proper SharePlay user experience patterns
- Spatial persona implementation standards
- Multi-scene coordination best practices
- Platform-specific design considerations

**Save this alongside other critical SharePlay documentation for complete implementation guidance.**