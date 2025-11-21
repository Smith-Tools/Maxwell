# Apple Spatial Persona Support for GroupActivities

## Critical Requirements for visionOS SharePlay

Based on Green Spurt production code analysis and Apple documentation requirements:

### 1. Entitlements Required
```xml
<key>com.apple.developer.groupactivities</key>
<true/>
<key>com.apple.developer.group-session</key>
<true/>
```

### 2. SystemCoordinator Configuration
```swift
// Critical: Must configure SystemCoordinator for spatial personas
if let coordinator = await session.systemCoordinator {
    var config = SystemCoordinator.Configuration()
    config.supportsGroupImmersiveSpace = true
    coordinator.configuration = config
    self.systemCoordinator = coordinator
}
```

### 3. Session Setup Pattern
```swift
func configure(session: GroupSession<YourActivity>) async {
    self.groupSession = session
    self.messenger = GroupSessionMessenger(session: session)

    // Critical for spatial personas
    if let coordinator = await session.systemCoordinator {
        var config = SystemCoordinator.Configuration()
        config.supportsGroupImmersiveSpace = true
        coordinator.configuration = config
        self.systemCoordinator = coordinator
    }

    session.join()
}
```

### 4. Key Implementation Notes
- SystemCoordinator configuration is MANDATORY for spatial personas
- Without `supportsGroupImmersiveSpace = true`, participants won't appear in immersive space
- SystemCoordinator enables automatic spatial persona positioning
- Must be called before or immediately after `session.join()`

### 5. Session Management
```swift
deinit {
    groupSession?.end()
    groupSession?.leave()
    groupSession = nil
    messenger = nil
    systemCoordinator = nil // Important cleanup
}
```

## Missing from Current Implementation

The DefaultImmersiveTemplate was missing:
1. SystemCoordinator setup
2. `supportsGroupImmersiveSpace = true` configuration
3. Proper session coordination for immersive spaces

This explains why participants weren't carried over to immersive space - the system wasn't configured for spatial persona support.