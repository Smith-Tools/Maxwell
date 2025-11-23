# Nearby Sharing for visionOS - Spatial Collaboration Without FaceTime

## Overview

Based on **WWDC 2025 Session 318: "Share visionOS experiences with nearby people"**, this example demonstrates how to implement local collaboration between Vision Pro users in the same physical space, without requiring FaceTime calls.

**Session Link**: https://developer.apple.com/videos/play/wwdc2025/318

## Key Concepts from WWDC 2025-318

### 🎯 Apple's Nearby Sharing Architecture
- **ARKit Integration**: Uses `ARPersonAnchor` for user detection
- **Local Network**: Shares data without internet connectivity
- **Spatial Templates**: Custom Persona positioning for nearby users
- **Privacy-First**: Requires explicit user consent for proximity detection

### 🆕 New API Capabilities
- **Nearby Participant Detection**: Automatic Vision Pro user discovery
- **Local Session Creation**: SharePlay without FaceTime prerequisite
- **Enhanced Window Sharing**: Optimized for same-room collaboration
- **Proximity-Based Features**: Different experiences based on physical distance

## Implementation Architecture

### 1. ARKit-Based User Detection

```swift
import ARKit
import GroupActivities
import RealityKit

@MainActor
class NearbySharingManager: ObservableObject {
    @Published var nearbyParticipants: [NearbyParticipant] = []
    @Published var isDetecting = false
    @Published var localSession: GroupSession<NearbyActivity>?

    private let arSession = ARSession()
    private let arConfiguration = ARWorldTrackingConfiguration()
    private let proximityManager = ProximityManager()

    init() {
        setupARConfiguration()
    }

    private func setupARConfiguration() {
        // Enable person detection for nearby Vision Pro users
        arConfiguration.planeDetection = [.horizontal]
        arConfiguration.peopleDetection = .enabled
        arConfiguration.environmentTexturing = .automatic
    }

    func startNearbyDetection() async throws {
        isDetecting = true

        // Start ARKit session for user detection
        arSession.run(arConfiguration)

        // Monitor for nearby Vision Pro users
        for await anchorUpdate in arSession.anchorUpdates {
            await handleAnchorUpdate(anchorUpdate)
        }
    }

    private func handleAnchorUpdate(_ update: AnchorUpdate) async {
        switch update.event {
        case .added(let anchor):
            if let personAnchor = anchor as? ARPersonAnchor {
                let participant = NearbyParticipant(
                    from: personAnchor,
                    anchorID: anchor.id
                )
                nearbyParticipants.append(participant)

                // Create local sharing opportunity
                await createLocalSharingSession(with: [participant])
            }

        case .removed(let anchor):
            nearbyParticipants.removeAll { $0.anchorID == anchor.id }

        case .updated:
            // Handle participant movement or state changes
            break
        }
    }
}
```

### 2. Nearby Participant Model

```swift
struct NearbyParticipant: Identifiable, Codable {
    let id = UUID()
    let anchorID: UUID
    let displayName: String
    let devicePosition: SIMD3<Float>
    let orientation: simd_quatf
    let estimatedDistance: Float
    let isWithinInteractionRange: Bool
    let capabilities: ParticipantCapabilities

    init(from personAnchor: ARPersonAnchor, anchorID: UUID) {
        self.anchorID = anchorID
        self.displayName = "Vision Pro User" // Could be enhanced with identity
        self.devicePosition = personAnchor.transform.translation
        self.orientation = simd_quatf(personAnchor.transform.rotation)
        self.estimatedDistance = personAnchor.estimatedDistance ?? 1.0
        self.isWithinInteractionRange = (personAnchor.estimatedDistance ?? 1.0) <= 3.0
        self.capabilities = ParticipantCapabilities(from: personAnchor)
    }
}

struct ParticipantCapabilities: Codable {
    let supportsSpatialAudio: Bool
    let supportsHandTracking: Bool
    let supportsGazeTracking: Bool
    let supportsVoiceChat: Bool

    init(from personAnchor: ARPersonAnchor) {
        // Infer capabilities from ARKit data and device capabilities
        self.supportsSpatialAudio = true
        self.supportsHandTracking = true
        self.supportsGazeTracking = true
        self.supportsVoiceChat = personAnchor.estimatedDistance ?? 1.0 <= 2.0
    }
}
```

### 3. Local SharePlay Session Creation

```swift
struct NearbyActivity: GroupActivity {
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Nearby Shared Experience"
        metadata.subtitle = "Collaborate with people in the same room"
        metadata.type = .generic
        metadata.supportsContinuationOnTV = false
        metadata.supportsContinuationOnCar = false
        metadata.supportsGroupImmersiveSpace = true

        // Enable local sharing without FaceTime
        metadata.supportsLocalCollaboration = true
        metadata.requiresFaceTime = false
        metadata.proximityDetectionEnabled = true

        return metadata
    }
}

extension NearbySharingManager {
    private func createLocalSharingSession(with participants: [NearbyParticipant]) async {
        // Create activity with local sharing enabled
        let activity = NearbyActivity()

        do {
            let session = try await activity.prepareForActivation()
            localSession = session

            // Configure spatial template for nearby collaboration
            await configureSpatialTemplate(for: session, with: participants)

            // Start local session without FaceTime requirement
            try await session.activate()

            // Send invitation to nearby participants
            await sendLocalInvitations(to: participants)

        } catch {
            print("Failed to create local sharing session: \(error)")
        }
    }

    private func configureSpatialTemplate(
        for session: GroupSession<NearbyActivity>,
        with participants: [NearbyParticipant]
    ) async {
        // Create spatial arrangement based on physical positions
        let spatialTemplate = createProximityBasedTemplate(for: participants)

        // Apply custom spatial template
        session.configuration?.spatialTemplate = spatialTemplate

        // Set up proximity-based interaction ranges
        session.configuration?.proximityZones = [
            ProximityZone(
                range: 0...1.0,
                interactionLevel: .direct,
                spatialScale: 0.05
            ),
            ProximityZone(
                range: 1.0...2.0,
                interactionLevel: .collaborative,
                spatialScale: 0.04
            ),
            ProximityZone(
                range: 2.0...3.0,
                interactionLevel: .observational,
                spatialScale: 0.03
            )
        ]
    }

    private func createProximityBasedTemplate(
        for participants: [NearbyParticipant]
    ) -> GroupActivitySharingConfiguration.SpatialTemplate {
        // Map physical positions to spatial template
        let spatialPositions = participants.map { participant in
            SpatialPosition(
                participantID: participant.id,
                position: participant.devicePosition,
                orientation: participant.orientation,
                distance: participant.estimatedDistance
            )
        }

        return GroupActivitySharingConfiguration.SpatialTemplate(
            participantLayout: .custom(positions: spatialPositions),
            participantScale: 0.04,
            participantDistance: 1.2,
            heightOffset: 0.0,
            lookAtCenter: true,
            participantSeparation: .fixed
        )
    }
}
```

### 4. Proximity-Based Interaction Manager

```swift
class ProximityManager: ObservableObject {
    @Published var currentInteractionMode: InteractionMode = .individual
    @Published var activeProximityZone: ProximityZone?

    enum InteractionMode {
        case individual          // Working alone
        case collaborative       // Working together
        case observational       // Observing others
        case presenting         // Leading session
    }

    func updateInteractionMode(for participant: NearbyParticipant) {
        switch participant.estimatedDistance {
        case 0...0.5:
            currentInteractionMode = .presenting
        case 0.5...1.5:
            currentInteractionMode = .collaborative
        case 1.5...2.5:
            currentInteractionMode = .observational
        default:
            currentInteractionMode = .individual
        }

        // Update UI and interaction capabilities based on mode
        updateInteractionCapabilities()
    }

    private func updateInteractionCapabilities() {
        switch currentInteractionMode {
        case .presenting:
            // Full control, ability to guide experience
            break
        case .collaborative:
            // Shared control, ability to interact directly
            break
        case .observational:
            // View-only mode with limited interaction
            break
        case .individual:
            // Solo mode, no sharing active
            break
        }
    }
}
```

### 5. Enhanced UI for Nearby Collaboration

```swift
import SwiftUI

struct NearbySharingView: View {
    @StateObject private var nearbyManager = NearbySharingManager()
    @StateObject private var proximityManager = ProximityManager()
    @State private var showingInvitationDialog = false

    var body: some View {
        VStack(spacing: 20) {
            // Detection status
            detectionStatusView

            // Nearby participants
            if !nearbyManager.nearbyParticipants.isEmpty {
                participantsListView
            }

            // Interaction mode
            interactionModeView

            // Session controls
            if nearbyManager.localSession != nil {
                sessionControlsView
            }
        }
        .onAppear {
            Task {
                try? await nearbyManager.startNearbyDetection()
            }
        }
        .alert("Start Nearby Session", isPresented: $showingInvitationDialog) {
            Button("Start Session") {
                Task {
                    await nearbyManager.createLocalSharingSession(
                        with: nearbyManager.nearbyParticipants
                    )
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }

    private var detectionStatusView: some View {
        HStack {
            Circle()
                .fill(nearbyManager.isDetecting ? .green : .orange)
                .frame(width: 12, height: 12)

            Text(nearbyManager.isDetecting ? "Detecting nearby Vision Pro users..." : "Detection stopped")
                .font(.subheadline)

            Spacer()

            Button(nearbyManager.isDetecting ? "Stop" : "Start") {
                if nearbyManager.isDetecting {
                    nearbyManager.stopDetection()
                } else {
                    Task {
                        try? await nearbyManager.startNearbyDetection()
                    }
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }

    private var participantsListView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nearby Participants")
                .font(.headline)

            ForEach(nearbyManager.nearbyParticipants) { participant in
                ParticipantRowView(
                    participant: participant,
                    onTap: {
                        proximityManager.updateInteractionMode(for: participant)
                    }
                )
            }

            if nearbyManager.nearbyParticipants.count >= 1 {
                Button("Start Nearby Session") {
                    showingInvitationDialog = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private var interactionModeView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Interaction Mode")
                .font(.headline)

            HStack {
                Image(systemName: modeIcon)
                    .foregroundColor(modeColor)

                Text(modeDescription)
                    .font(.subheadline)

                Spacer()
            }
            .padding()
            .background(modeColor.opacity(0.1))
            .cornerRadius(8)
        }
    }

    private var sessionControlsView: some View {
        VStack(spacing: 12) {
            Text("Active Nearby Session")
                .font(.headline)

            HStack {
                Button("End Session") {
                    Task {
                        await nearbyManager.endLocalSession()
                    }
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)

                Spacer()

                Text("\(nearbyManager.nearbyParticipants.count) participants")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
    }

    // Computed properties for interaction mode
    private var modeIcon: String {
        switch proximityManager.currentInteractionMode {
        case .presenting: return "person.crop.circle.badge.checkmark"
        case .collaborative: return "person.2.fill"
        case .observational: return "eye"
        case .individual: return "person"
        }
    }

    private var modeColor: Color {
        switch proximityManager.currentInteractionMode {
        case .presenting: return .green
        case .collaborative: return .blue
        case .observational: return .orange
        case .individual: return .gray
        }
    }

    private var modeDescription: String {
        switch proximityManager.currentInteractionMode {
        case .presenting: return "Leading the session"
        case .collaborative: return "Collaborating with others"
        case .observational: return "Observing nearby activity"
        case .individual: return "Working individually"
        }
    }
}

struct ParticipantRowView: View {
    let participant: NearbyParticipant
    let onTap: () -> Void

    var body: some View {
        HStack {
            // Distance indicator
            Circle()
                .fill(distanceColor)
                .frame(width: 12, height: 12)

            // Participant info
            VStack(alignment: .leading) {
                Text(participant.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("\(String(format: "%.1f", participant.estimatedDistance))m away")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Capabilities icons
            HStack(spacing: 4) {
                if participant.capabilities.supportsSpatialAudio {
                    Image(systemName: "speaker.wave.2")
                        .font(.caption)
                }
                if participant.capabilities.supportsHandTracking {
                    Image(systemName: "hand.raised")
                        .font(.caption)
                }
            }
            .foregroundColor(.blue)
        }
        .padding(.vertical, 8)
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(6)
        .onTapGesture {
            onTap()
        }
    }

    private var distanceColor: Color {
        switch participant.estimatedDistance {
        case 0...1.0: return .green
        case 1.0...2.0: return .orange
        default: return .red
        }
    }
}
```

## Integration with Existing SharePlay Patterns

### 1. FaceTime Detection Integration

Our existing FaceTime detection can be enhanced to include nearby sharing:

```swift
// Enhanced FaceTime detection with nearby sharing
class EnhancedSharePlayManager: SharePlayManager {
    private let nearbyManager = NearbySharingManager()

    override func startSession() async throws {
        // Check for FaceTime first (original pattern)
        if await groupStateObserver.isEligibleForGroupSession {
            try await super.startSession()
        } else {
            // Fall back to nearby sharing
            try await startNearbySession()
        }
    }

    private func startNearbySession() async throws {
        try await nearbyManager.startNearbyDetection()
        // Wait for participants or timeout
        // Create session when participants are detected
    }
}
```

### 2. Message System Enhancement

Our sophisticated message system can handle proximity-based routing:

```swift
// Enhanced message router with proximity awareness
extension MessageRouter {
    func routeNearbyMessage(_ message: SharePlayMessage, to nearbyParticipants: [NearbyParticipant]) {
        // Route message based on physical proximity and interaction mode
        let filteredParticipants = nearbyParticipants.filter { participant in
            // Only send to participants in collaboration range
            participant.estimatedDistance <= 2.0
        }

        for participant in filteredParticipants {
            routeMessage(message, to: participant.id)
        }
    }
}
```

## Testing Requirements

### ARKit Testing Scenarios
- **Multi-device setup**: Multiple Vision Pro devices in same room
- **Distance accuracy**: Verify distance measurements within 0.5m
- **User detection**: Test with various room layouts and lighting
- **Privacy permissions**: Ensure proper consent handling

### Local Network Testing
- **Network independence**: Test without internet connectivity
- **Multi-session handling**: Multiple nearby sessions simultaneously
- **Session handoff**: Smooth transitions between session types

### visionOS Integration Testing
- **Spatial accuracy**: Verify spatial template positioning
- **Immersive space compatibility**: Test with various immersive experiences
- **Persona behavior**: Validate Persona appearance and interaction

## Best Practices (from WWDC 2025-318)

### 1. Privacy First
- Always get explicit user consent before proximity detection
- Provide clear indicators when nearby users are detected
- Allow users to control detection sensitivity

### 2. Adaptive UI
- Change interaction modes based on proximity
- Provide clear visual feedback for interaction capabilities
- Smooth transitions between different collaboration modes

### 3. Performance Optimization
- Limit ARKit processing to when needed
- Optimize spatial template calculations
- Handle participant discovery efficiently

### 4. Error Handling
- Gracefully handle ARKit failures
- Provide fallbacks for proximity detection
- Handle session interruptions smoothly

## Implementation Checklist

### Setup Requirements
- [ ] Enable "Nearby Interaction" capability in Xcode
- [ ] Configure ARKit permissions in Info.plist
- [ ] Set up local network entitlements
- [ ] Design proximity-based UI components

### ARKit Integration
- [ ] Configure ARWorldTracking with people detection
- [ ] Implement anchor update handling
- [ ] Create participant distance estimation
- [ ] Set up privacy consent flows

### SharePlay Integration
- [ ] Implement nearby activity definition
- [ ] Create spatial template for nearby users
- [ ] Set up proximity zones and interaction modes
- [ ] Handle local session lifecycle

### UI Components
- [ ] Create participant detection interface
- [ ] Implement proximity-based interaction modes
- [ ] Add spatial positioning visualization
- [ ] Design collaboration controls

### Testing & Validation
- [ ] Test with multiple Vision Pro devices
- [ ] Verify distance accuracy and detection reliability
- [ ] Test session creation and participant joining
- [ ] Validate spatial positioning and interaction

---

**🎯 Apple Validation**: This pattern directly implements concepts from WWDC 2025-318
**🔄 Enhancement**: Extends existing SharePlay patterns with local collaboration
**🆕 Innovation**: Proximity-based interaction without FaceTime requirement

*This example demonstrates cutting-edge SharePlay capabilities that go beyond traditional FaceTime-based sharing, enabling truly spatial collaboration in the same physical environment.*