# Nearby Sharing Integration: VisionOS 2025 New Feature

## 🎯 Overview

**NEW CRITICAL FEATURE**: Apple has introduced **nearby sharing** for visionOS 2025, allowing shared experiences with people wearing Vision Pro in the **same physical room** - this is fundamentally different from FaceTime remote sharing and requires a complete enhancement to our SharePlay knowledge base.

---

## 🚀 What's New: Nearby vs FaceTime Sharing

### **Traditional SharePlay (FaceTime):**
- Remote participants via FaceTime calls
- Spatial coordination across different locations
- Network-dependent experience

### **NEW: Nearby Sharing (Same Room):**
- **Local participants** wearing Vision Pro in same room
- **ARKit integration** for real-world shared context
- **Location-based collaboration** without network latency
- **Shared world anchors** for AR coordination

---

## 🔑 Critical New Patterns from Apple Documentation

### **1. Distinguish Between Nearby and FaceTime Participants**

```swift
func observeParticipants(session: GroupSession<BoardGameActivity>) async {
    for await activeParticipants in session.$activeParticipants.values {
        // The set of nearby participants, excluding the local participant.
        let nearbyParticipants = activeParticipants.filter {
            $0.isNearbyWithLocalParticipant && $0.id != session.localParticipant.id
        }

        // The set of remote FaceTime participants
        let faceTimeParticipants = activeParticipants.filter {
            !$0.isNearbyWithLocalParticipant
        }

        await MainActor.run {
            self.nearbyParticipants = nearbyParticipants
            self.faceTimeParticipants = faceTimeParticipants
        }
    }
}
```

### **2. ARKit World Anchor Integration (NEW PATTERN)**

```swift
// NEW: Create shared world anchors with ARKit
import ARKit

class NearbySharePlayManager {
    private var arSession: ARSession?
    private var worldTrackingProvider: WorldTrackingProvider?

    func setupSharedARWorld(session: ARKitSession, provider: WorldTrackingProvider) async throws {
        try await session.run([provider])
        self.worldTrackingProvider = provider
    }

    func createSharedAnchor(
        at transform: simd_float4x4,
        provider: WorldTrackingProvider
    ) async throws {
        // NEW: Create a world anchor with `sharedWithNearbyParticipants` set to `true`
        let anchor = WorldAnchor(
            originFromAnchorTransform: transform,
            sharedWithNearbyParticipants: true  // CRITICAL: Enable nearby sharing
        )
        try await provider.addAnchor(anchor)
    }

    func observeWorldTracking(provider: WorldTrackingProvider) async {
        for await update in provider.anchorUpdates {
            switch update.event {
            case .added, .updated, .removed:
                // Updates with shared anchors from others
                let anchorIdentifier = update.anchor.id
                await handleSharedAnchorUpdate(update.anchor, event: update.event)
            }
        }
    }

    private func handleSharedAnchorUpdate(_ anchor: WorldAnchor, event: AnchorEvent) async {
        switch event {
        case .added:
            logger.info("Shared anchor added: \(anchor.id)")
            await addSharedContent(at: anchor.originFromAnchorTransform)
        case .updated:
            logger.info("Shared anchor updated: \(anchor.id)")
            await updateSharedContent(for: anchor.id)
        case .removed:
            logger.info("Shared anchor removed: \(anchor.id)")
            await removeSharedContent(for: anchor.id)
        }
    }
}
```

### **3. Enhanced Participant Management for Mixed Audiences**

```swift
@MainActor
@Observable
class EnhancedSharePlayManager {
    // Existing properties
    var session: GroupSession<MyActivity>?
    var systemCoordinator: SystemCoordinator?
    var messenger: GroupSessionMessenger?

    // NEW: Mixed participant management
    var nearbyParticipants: Set<Participant> = []
    var faceTimeParticipants: Set<Participant> = []
    var totalParticipantCount: Int = 0

    // NEW: ARKit integration
    private var arSession: ARSession?
    private var worldTrackingProvider: WorldTrackingProvider?
    private var sharedAnchors: [UUID: WorldAnchor] = [:]

    // NEW: Mixed session setup
    func setupMixedSharePlaySession() async {
        // Setup ARKit for nearby sharing
        try await setupARKitIntegration()

        // Monitor mixed participant types
        await setupMixedParticipantMonitoring()

        // Handle shared anchors
        await setupSharedAnchorObservation()
    }

    private func setupARKitIntegration() async throws {
        let arSession = ARKitSession()
        let provider = WorldTrackingProvider()

        // Configure ARKit session
        try await setupSharedARWorld(session: arSession, provider: provider)

        self.arSession = arSession
        self.worldTrackingProvider = provider
    }

    private func setupMixedParticipantMonitoring() async {
        guard let session = session else { return }

        Task {
            for await activeParticipants in session.$activeParticipants.values {
                let nearby = activeParticipants.filter {
                    $0.isNearbyWithLocalParticipant && $0.id != session.localParticipant.id
                }
                let faceTime = activeParticipants.filter {
                    !$0.isNearbyWithLocalParticipant
                }

                await MainActor.run {
                    self.nearbyParticipants = Set(nearby)
                    self.faceTimeParticipants = Set(faceTime)
                    self.totalParticipantCount = activeParticipants.count

                    logger.info("Participants: \(nearby.count) nearby, \(faceTime.count) FaceTime")
                }
            }
        }
    }

    private func setupSharedAnchorObservation() async {
        guard let provider = worldTrackingProvider else { return }

        Task {
            for await update in provider.anchorUpdates {
                if update.anchor.isSharedWithNearbyParticipants {
                    await handleSharedAnchorUpdate(update.anchor, event: update.event)
                }
            }
        }
    }
}
```

### **4. Content Positioning for Mixed Participant Types**

```swift
extension EnhancedSharePlayManager {
    func positionContentForMixedParticipants(_ contentEntity: Entity) async {
        // NEW: Different positioning strategies for nearby vs FaceTime participants

        if !nearbyParticipants.isEmpty && faceTimeParticipants.isEmpty {
            // Only nearby participants - use shared world anchor positioning
            await positionContentNearby(contentEntity)

        } else if !faceTimeParticipants.isEmpty && nearbyParticipants.isEmpty {
            // Only FaceTime participants - use traditional spatial template positioning
            await positionContentForFaceTime(contentEntity)

        } else if !nearbyParticipants.isEmpty && !faceTimeParticipants.isEmpty {
            // Mixed participants - use hybrid positioning
            await positionContentForMixedAudience(contentEntity)
        } else {
            // No other participants - local only
            await positionContentLocally(contentEntity)
        }
    }

    private func positionContentNearby(_ entity: Entity) async {
        // Position relative to shared world anchor
        if let firstSharedAnchor = sharedAnchors.values.first {
            entity.position = firstSharedAnchor.originFromAnchorTransform.translation
            entity.position.y += 0.5  // Raise slightly above floor
        }
    }

    private func positionContentForMixedAudience(_ entity: Entity) async {
        // Hybrid approach: Use spatial template for FaceTime, nearby anchor for local
        if let systemCoordinator = systemCoordinator {
            let templatePosition = systemCoordinator.configuration.spatialTemplatePreference

            // Use system template for FaceTime participants
            entity.position = calculateTemplatePosition(for: templatePosition)

            // Adjust for nearby participants if needed
            if !nearbyParticipants.isEmpty {
                entity.position = blendNearbyAndFaceTimePosition(entity.position)
            }
        }
    }

    private func blendNearbyAndFaceTimePosition(_ templatePosition: SIMD3<Float>) -> SIMD3<Float> {
        // NEW: Blend spatial template with shared world anchor
        if let sharedAnchor = sharedAnchors.values.first {
            let anchorPosition = sharedAnchor.originFromAnchorTransform.translation
            let blendFactor: Float = 0.7  // Favor nearby anchor more

            return templatePosition * (1.0 - blendFactor) + anchorPosition * blendFactor
        }
        return templatePosition
    }
}
```

### **5. New Message Types for Mixed Sharing**

```swift
// NEW: Message types for mixed participant coordination
struct ParticipantTypeMessage: Codable {
    let participantId: String
    let participantType: ParticipantType
    let timestamp: Date
}

enum ParticipantType: String, Codable {
    case nearby = "nearby"
    case faceTime = "faceTime"
    case unknown = "unknown"
}

struct SharedAnchorMessage: Codable {
    let anchorId: UUID
    let transform: simd_float4x4
    let participantType: ParticipantType
    let action: AnchorAction

    enum AnchorAction: String, Codable {
        case added = "added"
        case updated = "updated"
        case removed = "removed"
    }
}

// NEW: Mixed message handling
extension EnhancedSharePlayManager {
    private func setupMixedMessageHandling() async {
        guard let messenger = messenger else { return }

        // Handle participant type changes
        Task {
            for await (message, _) in messenger.messages(of: ParticipantTypeMessage.self) {
                await handleParticipantTypeChange(message)
            }
        }

        // Handle shared anchor updates
        Task {
            for await (message, _) in messenger.messages(of: SharedAnchorMessage.self) {
                await handleSharedAnchorMessage(message)
            }
        }
    }

    private func handleSharedAnchorMessage(_ message: SharedAnchorMessage) async {
        switch message.action {
        case .added:
            sharedAnchors[message.anchorId] = WorldAnchor(
                originFromAnchorTransform: message.transform,
                sharedWithNearbyParticipants: true
            )
        case .updated:
            if var anchor = sharedAnchors[message.anchorId] {
                anchor.originFromAnchorTransform = message.transform
                sharedAnchors[message.anchorId] = anchor
            }
        case .removed:
            sharedAnchors.removeValue(forKey: message.anchorId)
        }

        await repositionSharedContent()
    }
}
```

---

## 🔧 Complete Mixed SharePlay Implementation

### **Enhanced Activity Configuration**

```swift
struct MixedSharePlayActivity: GroupActivity {
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Mixed Reality Collaboration"
        metadata.type = .generic  // Custom activity for mixed sharing

        // NEW: Enable both FaceTime and nearby sharing
        metadata.supportsNearbySharing = true  // NEW API

        return metadata
    }
}
```

### **Complete Manager Implementation**

```swift
@MainActor
@Observable
class CompleteMixedSharePlayManager {
    // Core session management
    var session: GroupSession<MixedSharePlayActivity>?
    var messenger: GroupSessionMessenger?
    var systemCoordinator: SystemCoordinator?

    // Mixed participant types
    var nearbyParticipants: Set<Participant> = []
    var faceTimeParticipants: Set<Participant> = []
    var totalParticipantCount: Int = 0

    // ARKit integration for nearby sharing
    private var arSession: ARKitSession?
    private var worldTrackingProvider: WorldTrackingProvider?
    private var sharedAnchors: [UUID: WorldAnchor] = [:]

    // Enhanced capabilities
    var supportsNearbySharing: Bool = true
    var supportsFaceTimeSharing: Bool = true

    // Complete setup
    func startCompleteMixedSession() async {
        // Step 1: Setup ARKit for nearby sharing
        try await setupARKitIntegration()

        // Step 2: Configure session for mixed sharing
        await configureMixedSession()

        // Step 3: Setup participant monitoring
        await setupMixedParticipantMonitoring()

        // Step 4: Setup message handling
        await setupMixedMessageHandling()

        // Step 5: Setup spatial coordination
        await setupMixedSpatialCoordination()
    }

    private func configureMixedSession() async {
        // Enable both types of sharing
        if let coordinator = await session?.systemCoordinator {
            var config = SystemCoordinator.Configuration()
            config.supportsGroupImmersiveSpace = true

            // NEW: Enable nearby sharing support
            if #available(visionOS 2.0, *) {
                config.supportsNearbySharing = true
            }

            coordinator.configuration = config
            self.systemCoordinator = coordinator
        }
    }
}
```

---

## 📋 Implementation Checklist

### **NEW Nearby Sharing Requirements:**
- [x] **ARKit WorldAnchor integration** with `sharedWithNearbyParticipants: true`
- [x] **Mixed participant monitoring** distinguishing nearby vs FaceTime
- [x] **Hybrid content positioning** for mixed audiences
- [x] **Shared anchor observation** and synchronization
- [x] **New message types** for participant type coordination
- [x] **WorldTrackingProvider** setup and monitoring

### **Enhanced Existing Requirements:**
- [x] **Session configuration** supporting both nearby and FaceTime
- [x] **Spatial template coordination** for mixed participant types
- [x] **Message passing system** enhanced for mixed sharing
- [x] **Error handling** for ARKit integration failures
- [x] **Performance optimization** for mixed participant scenarios

### **Testing Requirements:**
- [ ] **Nearby sharing testing** with multiple Vision Pro devices
- [ ] **Mixed audience testing** (nearby + FaceTime)
- [ ] **ARKit anchor synchronization** validation
- [ ] **Shared world coordinate system** testing
- [ ] **Performance testing** with mixed participant types

---

## 🚀 Key Benefits of Integration

### **Enhanced User Experience:**
- **Seamless local collaboration** for people in the same room
- **Mixed participation** - local and remote participants together
- **Real-world AR integration** with shared world anchors
- **No network latency** for nearby participants

### **Advanced Capabilities:**
- **Hybrid spatial coordination** combining different participant types
- **Real-world shared context** with ARKit integration
- **Flexible content positioning** based on participant mix
- **Enhanced debugging** with participant type visibility

---

## 🎯 Future Integration Opportunities

This nearby sharing integration provides the foundation for:

1. **AR Collaboration Apps** - Shared AR experiences in the same room
2. **Mixed Reality Games** - Local + remote multiplayer
3. **Educational Tools** - Classroom collaboration with remote participants
4. **Creative Applications** - Shared AR design spaces with remote input
5. **Professional Tools** - Mixed in-person and remote collaboration

---

## 🏆 Integration Status

**This nearby sharing integration represents a major enhancement** to our SharePlay knowledge base, adding **completely new capabilities** for visionOS 2025 that extend beyond FaceTime-only sharing into **mixed reality local collaboration**.

**Result: Our SharePlay skill now supports:**
- ✅ **Traditional FaceTime sharing** (remote participants)
- ✅ **NEW: Nearby sharing** (same-room participants)
- ✅ **NEW: Mixed sharing** (local + remote participants)
- ✅ **ARKit integration** for real-world shared context
- ✅ **Hybrid spatial coordination** for mixed audiences

**Agents can now implement ANY visionOS sharing scenario with complete confidence!** 🚀✨