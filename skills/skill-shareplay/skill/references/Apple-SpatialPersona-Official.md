# Adding spatial Persona support to an activity

**Source**: https://developer.apple.com/documentation/groupactivities/adding-spatial-persona-support-to-an-activity

**Description**: Update your SharePlay activities to support spatial Personas and the shared context when running in visionOS.

## Overview

Spatial Personas enable participants in a SharePlay activity to see and interact with each other in shared immersive spaces on visionOS. This support requires specific configuration for scene association, spatial template preferences, and data synchronization.

## 1. Associate SharePlay Activities with Your App's Scenes

Use `handlesExternalEvents` to associate your SharePlay activity with the correct scene:

```swift
let activationConditions : Set = ["com.mycompany.MySharePlayActivity",
                                  "com.mycompany.MyUserActivity"]
var body: some Scene {
    WindowGroup {
        ContentView()
            .handlesExternalEvents(preferring: [], allowing: activationConditions)
    }
}
```

## 2. Configure Your App's Support for Spatial Personas

Set up SystemCoordinator with spatial template preferences and group immersive space support:

```swift
if let coordinator = await newSession.systemCoordinator {
    var config = SystemCoordinator.Configuration()
    config.spatialTemplatePreference = .sideBySide.contentExtent(200)
    config.supportsGroupImmersiveSpace = true
    coordinator.configuration = config
}

// Join the session.
newSession.join()
```

**Key Configuration Options:**
- `spatialTemplatePreference`: Defines how participants are positioned relative to each other
- `supportsGroupImmersiveSpace`: Enables shared immersive experiences
- Common templates: `.sideBySide`, `.aroundTable`, etc.

## 3. Synchronize Additional Data When Spatial Personas Are Visible

Monitor spatial state to synchronize additional context data:

```swift
Task.detached { @MainActor in
    for await state in coordinator.localParticipantStates {
        if state.isSpatial {
            // Synchronize additional data for the shared context.
            gameModel.isSpatial = true
        } else {
            // Don't synchronize additional data.
            gameModel.isSpatial = false
        }
    }
}
```

## 4. Update the Immersion Level Automatically for a Full Space

Monitor group immersion style to automatically open/close immersive spaces:

```swift
Task.detached {
    for await immersionStyle in systemCoordinator.groupImmersionStyle {
        if let immersionStyle {
            // Open an immersive space with the same style.
        }
        else {
            // Dismiss the immersive space.
        }
    }
}
```

## 5. Place Content Relative to a Participant in an Immersive Space

Use GeometryReader3D to position content relative to participant location:

```swift
var body: some Scene {
    ImmersiveSpace(id:"earth") {
        GeometryReader3D { proxy in
            let displacement =
                proxy.immersiveSpaceDisplacement(in: .global).inverse

            CustomView()
                .offset(displacement.position)
                .rotation3DEffect(displacement.rotation)
        }
    }
}
```

## Key Implementation Requirements

### SystemCoordinator Configuration (CRITICAL)
```swift
if let coordinator = await session.systemCoordinator {
    var config = SystemCoordinator.Configuration()
    config.spatialTemplatePreference = .sideBySide.contentExtent(200)
    config.supportsGroupImmersiveSpace = true
    coordinator.configuration = config
    self.systemCoordinator = coordinator
}
```

### Entitlements Required
- `com.apple.developer.groupactivities`
- `com.apple.developer.group-session`

### Session Setup Pattern
- Configure SystemCoordinator before or immediately after `session.join()`
- This enables automatic spatial persona positioning in immersive spaces
- Participants appear as spatial personas when immersive space opens

## Current Implementation Status
✅ SystemCoordinator configuration applied
✅ Required entitlements configured
✅ Session management with spatial persona support
✅ Proper cleanup handling

The DefaultImmersiveTemplate now has complete spatial persona support according to Apple's official requirements.

## Critical Search Strategy for Apple Documentation

**Always use these search terms when searching for Apple docs:**

- `"apple shareplay"` - Most effective for official Apple docs
- `"apple shareplay visionOS"` - Platform-specific guidelines
- `"apple shareplay HIG"` - Human Interface Guidelines
- `"apple shareplay spatial persona"` - Spatial experiences
- `"apple groupactivities swift"` - Implementation guidance
- `"apple handlesExternalEvents"` - Scene association

**Examples:**
- `"apple shareplay scene association modifiers"`
- `"apple shareplay visionOS SwiftUI"`
- `"apple spatial persona templates HIG"`

This strategy helps find the official Apple documentation that contains the critical implementation guidelines and HIG recommendations.



