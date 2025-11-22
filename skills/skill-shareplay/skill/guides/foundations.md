# Complete SharePlay Skill: Foundation Architecture

## 🎯 Overview

This document integrates the foundational architecture from WWDC 2023 Session 10087 with our advanced implementation patterns. This represents the **complete SharePlay skill foundation** - essential knowledge that all advanced features build upon.

---

## 🏗️ Level 0: Core Architecture Foundation

### **0.1 Shared Context vs Visual Consistency**

**Critical Distinction Every Developer Must Understand:**

```swift
// Shared Context: System handles participant positioning
Connor points to Mia → Mia sees Connor pointing at her
// ✅ Automatic, no code required

// Visual Consistency: App handles content synchronization
Connor points to square in app → Mia sees Connor pointing at square
// ❌ REQUIRES developer implementation
```

### **0.2 The Spatial Detection Pattern**

```swift
@MainActor
@Observable
class SharePlayManager {
    private var isLocalSpatial = false
    private var systemCoordinator: SystemCoordinator?

    func setupSystemCoordinator(_ session: GroupSession<MyActivity>) async {
        if let coordinator = await session.systemCoordinator {
            var config = SystemCoordinator.Configuration()
            config.supportsGroupImmersiveSpace = true
            coordinator.configuration = config

            // CRITICAL: Monitor spatial state for sync decisions
            Task {
                for await localState in coordinator.localParticipantState {
                    isLocalSpatial = localState.isSpatial
                    updateSynchronizationBehavior()
                }
            }

            self.systemCoordinator = coordinator
        }
    }

    private func updateSynchronizationBehavior() {
        if isLocalSpatial {
            enableFullStateSync()  // Sync scroll, selection, etc.
        } else {
            enableBasicStateSync()  // Don't sync spatial-dependent UI
        }
    }
}
```

**Use Case**: Freeform document sharing - only sync scrolling when both participants are spatial.

---

## 🎭 Level 1: Scene Association Mastery

### **1.1 The Complete Can/Prefer Selection Logic**

**Apple's Official Selection Process (Must Understand):**

```
When group activity activates:
1. Check each scene: Can it handle the activity? → Boolean
2. Check each scene: Does it prefer the activity? → Boolean
3. Selection priority:
   🥇 Scene that both CAN AND PREFERS → SELECTED
   🥈 Multiple CAN, none PREFER → RANDOM selection
   🥉 Multiple CAN, multiple PREFER → FIRST preferrable scene
   🚫 No scene CAN handle → LAUNCH new scene
```

### **1.2 The Green Spurt Pattern Explained**

**Why This Pattern Works:**

```swift
@main
struct MyApp: App {
    var body: some Scene {
        // WindowGroup: CAN handle SharePlay, doesn't PREFER (default)
        WindowGroup {
            ContentView()
                .onAppear {
                    Task {
                        await sharePlayManager.startSessionMonitoring()
                    }
                }
        }
        // NO .handlesExternalEvents = "can anything, prefer nothing"

        // ImmersiveSpace: CAN handle SharePlay, PREFERS SharePlay
        ImmersiveSpace(id: "immersive") {
            ImmersiveView()
        }
        .handlesExternalEvents(matching: [activityID])
        // Equivalent to: "can SharePlay, prefer SharePlay"
    }
}
```

**System Decision**:
- WindowGroup: Can handle, doesn't prefer
- ImmersiveSpace: Can handle, prefers → **WINNER**

### **1.3 Scene Association Debugging**

```swift
extension SharePlayManager {
    func debugSceneAssociation(_ session: GroupSession<MyActivity>) {
        // CRITICAL: Know which scene was actually selected
        if let sceneId = session.sceneSessionIdentifier {
            logger.info("SharePlay associated with scene: \(sceneId)")

            // Useful for multi-scene debugging
            verifyExpectedScene(sceneId)
        }
    }

    private func verifyExpectedScene(_ sceneId: String) {
        // Ensure the immersive space was selected
        assert(sceneId.contains("immersive"),
               "Wrong scene associated with SharePlay!")
    }
}
```

---

## 🌐 Level 2: Template System Understanding

### **2.1 Built-in Templates with Specific Use Cases**

#### **Side-by-Side Template**
```swift
// Characteristics:
// - Default for vertical/windowed apps
// - Participants in arc facing shared app
// - Use Case: Document viewing, UI-focused experiences
systemCoordinator?.configuration.spatialTemplatePreference = .sideBySide
```

#### **Conversational Template**
```swift
// Characteristics:
// - Participants in half-circle, app in front
// - Use Case: Music apps, content-not-focused experiences
systemCoordinator?.configuration.spatialTemplatePreference = .conversational
```

#### **Surround Template**
```swift
// Characteristics:
// - ONLY available with volumetric scenes
// - Participants in circle, app in center
// - Dynamic distance based on app size
systemCoordinator?.configuration.spatialTemplatePreference = .surround
```

### **2.2 Content Extent Control**

```swift
// CRITICAL: Control participant distance from content
systemCoordinator?.configuration.spatialTemplatePreference =
    .sideBySide
    .contentExtent(1000)  // Points from center to farthest edge

// System uses this to calculate optimal participant positions
// Bigger extent = participants further away
// Smaller extent = participants closer
```

### **2.3 Template Selection Algorithm**

```swift
extension SharePlayManager {
    func selectOptimalTemplate(appType: AppType, contentSize: CGSize) {
        switch appType {
        case .documentViewer:
            // UI-focused → Side-by-side
            systemCoordinator?.configuration.spatialTemplatePreference =
                .sideBySide
                .contentExtent(contentSize.width)

        case .mediaPlayer:
            // Content-not-focused → Conversational
            systemCoordinator?.configuration.spatialTemplatePreference = .conversational
                .contentExtent(contentSize.width * 0.8)

        case .volumetricExperience:
            // 3D content → Surround
            systemCoordinator?.configuration.spatialTemplatePreference =
                .surround
                .contentExtent(max(contentSize.width, contentSize.height))
        }
    }
}
```

---

## 🚀 Level 3: Group Immersive Space Coordination

### **3.1 Group Immersive Space Configuration**

```swift
extension SharePlayManager {
    func enableGroupImmersiveSpace() {
        // CRITICAL: Enable shared immersive space
        systemCoordinator?.configuration.supportsGroupImmersiveSpace = true

        // When participants join:
        // - Private immersive space → Group immersive space
        // - Space origin moves to shared template location
        // - Shared coordinate system established
        // - Personas become visible to each other
    }
}
```

### **3.2 The Split Contacts Problem & Solution**

**Problem**: Users in different immersion styles can't see each other

```swift
// ❌ PROBLEM:
User A: Fully immersive space → Sees only contact photos
User B: Passthrough window → Sees User A as contact photo
// Result: No shared context
```

**Solution**: Group Immersion Style Coordination

```swift
extension SharePlayManager {
    func setupImmersionStyleCoordination() {
        guard let coordinator = systemCoordinator else { return }

        Task {
            // CRITICAL: Monitor group immersion style changes
            for await immersionStyle in coordinator.groupImmersionStyle {
                if let style = immersionStyle {
                    // Other participant entered immersive space
                    // Match their style to stay together
                    await openImmersiveSpace(style: style)
                } else {
                    // Other participant left immersive space
                    await handleGroupLeftImmersiveSpace()
                }
            }
        }
    }

    private func handleGroupLeftImmersiveSpace() async {
        if shouldFollowGroup {
            await dismissImmersiveSpace()
        } else {
            // Stay in immersive space, show banner to rejoin
            showRejoinGroupBanner()
        }
    }
}
```

### **3.3 Digital Crown Interaction**

```swift
// Single press on Digital Crown behavior:
// 1. Steps out of immersive space temporarily
// 2. Others remain in group space (undisturbed)
// 3. Shows SharePlay banner with "Join" button
// 4. Doesn't change groupImmersionStyle for others

extension SharePlayManager {
    func handleDigitalCrownPress() {
        // System handles this automatically
        // App just needs to respond to potential rejoin
        if canRejoinGroup {
            rejoinGroupImmersiveSpace()
        }
    }
}
```

---

## 🎯 Level 4: Spatial Consistency Implementation

### **4.1 Shared Coordinate System Usage**

```swift
extension SharePlayManager {
    func placeSharedContent(_ entity: Entity, at position: SIMD3<Float>) {
        // CRITICAL: Position relative to shared template origin
        // All participants see content at same location
        entity.position = position  // Relative to shared origin

        // Example: Place globe in center above origin
        let globePosition = SIMD3<Float>(x: 0, y: 1, z: 0)
        globeEntity.position = globePosition
        // Everyone sees globe at same spot!
    }
}
```

### **4.2 Local User Positioning**

```swift
extension SharePlayManager {
    func positionUIForLocalUser(_ uiEntity: Entity) {
        // CRITICAL: Get local user position relative to space origin
        GeometryReader3D { geometry in
            let displacement = geometry.systemExperienceDisplacement
            let localUserPosition = displacement.inverse().translation

            // Place UI relative to local user
            uiEntity.position = localUserPosition + SIMD3<Float>(x: 0, y: -0.5, z: 1)
        }

        // IMPORTANT: displacement only provides initial placement
        // Not real-time tracking of user movement
    }
}
```

### **4.3 Visual Consistency Synchronization**

```swift
extension SharePlayManager {
    private func setupMessageSynchronization() {
        guard let messenger = messenger else { return }

        Task {
            for await (message, participant) in messenger.messages(of: StateSyncMessage.self) {
                // Only sync if local participant is spatial
                if isLocalSpatial {
                    await applyStateChange(message.stateChange)
                }
            }
        }
    }

    func broadcastStateChange(_ change: StateChange) {
        guard let messenger = messenger else { return }

        Task {
            do {
                let message = StateSyncMessage(
                    change: change,
                    senderId: localParticipantId,
                    timestamp: Date()
                )
                try await messenger.send(message)
            } catch {
                logger.error("Failed to broadcast state change: \(error)")
            }
        }
    }
}
```

---

## 🔧 Level 5: Advanced Implementation Patterns

### **5.1 Hybrid Window + Immersive Apps**

```swift
enum ActivityStage {
    case browsing    // Window stage (side-by-side template)
    case exploring   // Immersive stage (custom template)
    case presenting  // Mixed stage (coordinated templates)
}

class HybridSharePlayManager {
    var currentStage: ActivityStage = .browsing

    func configureForHybridExperience() {
        // Stage 1: Window browsing
        systemCoordinator?.configuration.spatialTemplatePreference =
            .sideBySide
            .contentExtent(800)

        // Stage 2: Immersive exploration
        systemCoordinator?.configuration.supportsGroupImmersiveSpace = true

        // Stage 3: Presenting (window shows controls, immersive shows content)
        setupCoordinatedTemplates()
    }

    func transitionToStage(_ newStage: ActivityStage) {
        currentStage = newStage

        switch newStage {
        case .browsing:
            systemCoordinator?.configuration.spatialTemplatePreference = .sideBySide
            if isImmersiveActive {
                dismissImmersiveSpace()
            }

        case .exploring:
            systemCoordinator?.configuration.spatialTemplatePreference =
                .custom(ExplorationTemplate())
            if !isImmersiveActive {
                openImmersiveSpace()
            }

        case .presenting:
            // Complex coordination required
            coordinateWindowAndImmersiveTemplates()
        }
    }
}
```

### **5.2 Multi-Template Coordination**

```swift
struct CoordinatedTemplate: SpatialTemplate {
    var windowTemplate: any SpatialTemplate = SideBySideTemplate()
    var immersiveTemplate: any SpatialTemplate = CustomTemplate()

    var elements: [SpatialTemplateElement] {
        // Combine window and immersive template elements
        windowTemplate.elements + immersiveTemplate.elements
    }
}
```

### **5.3 Performance Optimization**

```swift
extension SharePlayManager {
    // Optimize message frequency based on spatial context
    func calculateOptimalSyncRate() -> TimeInterval {
        if isLocalSpatial {
            return 1.0/60.0  // 60 FPS for smooth spatial interaction
        } else {
            return 1.0/30.0  // 30 FPS for non-spatial interaction
        }
    }

    // Only sync spatial-relevant data when spatial
    func shouldSyncDataType(_ dataType: DataType) -> Bool {
        switch dataType {
        case .scrollPosition, .cameraTransform:
            return isLocalSpatial
        case .selectionState, .contentData:
            return true  // Always sync
        case .UIAnimation:
            return false  // Never sync (local only)
        }
    }
}
```

---

## 🐛 Level 6: Debugging & Troubleshooting

### **6.1 Essential Debugging Properties**

```swift
extension SharePlayManager {
    func debugSessionState() {
        print("=== SharePlay Debug Info ===")
        print("Session Active: \(isActive)")
        print("Local Spatial: \(isLocalSpatial)")
        print("Participant Count: \(participantCount)")

        if let sceneId = session?.sceneSessionIdentifier {
            print("Associated Scene: \(sceneId)")
        }

        if let coordinator = systemCoordinator {
            print("Template Preference: \(coordinator.configuration.spatialTemplatePreference)")
            print("Supports Group Immersive: \(coordinator.configuration.supportsGroupImmersiveSpace)")
        }
    }
}
```

### **6.2 Common Issues & Solutions**

#### **Issue 1: Random Scene Selection**
**Problem**: Multiple scenes can handle SharePlay, none prefer
**Solution**: Only one scene should prefer SharePlay activity

#### **Issue 2: Inconsistent Visual State**
**Problem**: Syncing scroll position when participant isn't spatial
**Solution**: Check `isSpatial` flag before syncing UI state

#### **Issue 3: Split Contacts in Immersive Space**
**Problem**: Users in different immersion styles can't see each other
**Solution**: Use `groupImmersionStyle` to coordinate immersion styles

#### **Issue 4: Wrong Participant Distances**
**Problem**: Participants too close/far from content
**Solution**: Use `contentExtent` to control template geometry

---

## 📋 Implementation Checklist

### **Foundation Requirements (Must Have):**
- [x] Scene association with Green Spurt pattern
- [x] SystemCoordinator configuration
- [x] Spatial detection (`isSpatial` monitoring)
- [x] Template selection logic
- [x] Basic visual consistency

### **Advanced Features (Should Have):**
- [x] Group immersive space support
- [x] Immersion style coordination
- [x] Content extent configuration
- [x] Shared coordinate system usage
- [x] Performance optimization

### **Production Ready (Nice to Have):**
- [ ] Custom spatial templates
- [ ] Role-based seat assignment
- [ ] Advanced debugging tools
- [ ] Error recovery patterns
- [ ] Analytics integration

---

## 🎯 Key Takeaways

### **The Architecture Foundation:**
1. **System handles shared context** (participant positioning)
2. **Apps handle visual consistency** (content synchronization)
3. **Scene association prevents competition** (can/prefer logic)
4. **Templates control geometry** (participant arrangement)
5. **Immersion coordination keeps users together** (groupImmersionStyle)

### **Critical Implementation Points:**
- Always monitor `isSpatial` before syncing spatial data
- Use `contentExtent` to control participant distances
- Implement `groupImmersionStyle` for seamless transitions
- Debug with `sceneSessionIdentifier` for scene association issues
- Coordinate templates for hybrid window + immersive experiences

**This foundation enables all advanced SharePlay features and is essential for building robust spatial experiences!**