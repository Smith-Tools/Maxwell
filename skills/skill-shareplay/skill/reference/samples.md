# SharePlay Sample Code Analysis: Complete Implementation Patterns

## 🎯 Overview

This document consolidates key implementation patterns extracted from Apple's official SharePlay sample code projects, providing production-ready patterns for different SharePlay use cases.

---

## 📊 Sample Code Analysis Summary

### **Analyzed Samples:**
1. **BuildingAGuessingGameForVisionOS** - Spatial gaming with custom templates
2. **DrawingContentInAGroupSession** - Real-time collaborative drawing
3. **SupportingCoordinatedMediaPlayback** - Synchronized media playback

### **Key Categories Covered:**
- ✅ **Spatial Gaming** - Custom templates, role management, turn-based coordination
- ✅ **Real-time Collaboration** - High-frequency data synchronization, conflict resolution
- ✅ **Media Coordination** - AVPlayer synchronization, playback coordination
- ✅ **Performance Optimization** - Latency handling, bandwidth management
- ✅ **User Experience** - State-based UI, error handling, participant management

---

## 🎮 VisionOS Spatial Gaming Patterns

### **Custom Spatial Template Implementation**

**From: BuildingAGuessingGameForVisionOS**

```swift
struct GameTemplate: SpatialTemplate {
    enum Role: String, SpatialTemplateRole {
        case player
        case activeTeam
    }

    static let playerPosition = Point3D(x: -2, z: 3)

    var elements: [any SpatialTemplateElement] {
        let activeTeamCenterPosition = SpatialTemplateElementPosition.app.offsetBy(x: 2, z: 3)

        let playerSeat = SpatialTemplateSeatElement(
            position: .app.offsetBy(x: Self.playerPosition.x, z: Self.playerPosition.z),
            direction: .lookingAt(activeTeamCenterPosition),
            role: Role.player
        )

        let activeTeamSeats: [any SpatialTemplateElement] = [
            .seat(position: activeTeamCenterPosition.offsetBy(x: 0, z: -0.5),
                  direction: .lookingAt(playerSeat), role: Role.activeTeam),
            .seat(position: activeTeamCenterPosition.offsetBy(x: 0, z: 0.5),
                  direction: .lookingAt(playerSeat), role: Role.activeTeam)
        ]

        return audienceSeats + [playerSeat] + activeTeamSeats
    }
}
```

**Key Insights:**
- Use `SpatialTemplateSeatElement` for participant positioning
- Implement `lookingAt()` for natural participant orientation
- Separate audience from active participant roles
- Use `Point3D` coordinates relative to app position

### **Dynamic Role Assignment Pattern**

```swift
func updateSpatialTemplatePreference() {
    switch game.stage {
    case .categorySelection:
        systemCoordinator.configuration.spatialTemplatePreference = .sideBySide
    case .teamSelection:
        systemCoordinator.configuration.spatialTemplatePreference = .custom(TeamSelectionTemplate())
    case .inGame:
        systemCoordinator.configuration.spatialTemplatePreference = .custom(GameTemplate())
    }
}

func updateLocalParticipantRole() {
    switch game.stage {
    case .categorySelection:
        systemCoordinator.resignRole()
    case .teamSelection:
        switch localPlayer.team {
        case .none: systemCoordinator.resignRole()
        case .blue: systemCoordinator.assignRole(TeamSelectionTemplate.Role.blueTeam)
        case .red: systemCoordinator.assignRole(TeamSelectionTemplate.Role.redTeam)
        }
    case .inGame:
        if localPlayer.isPlaying {
            systemCoordinator.assignRole(GameTemplate.Role.player)
        } else if let currentPlayer {
            if currentPlayer.team == localPlayer.team {
                systemCoordinator.assignRole(GameTemplate.Role.activeTeam)
            } else {
                systemCoordinator.resignRole()
            }
        }
    }
}
```

**Pattern Benefits:**
- Context-aware role assignment based on game state
- Automatic role updates when state changes
- Clean separation between template preference and role assignment

### **Turn-Based Game State Synchronization**

```swift
struct GameSyncStore {
    var editCount: Int = 0
    var lastModifiedBy: Participant?
    var game = GameModel()
}

func shareLocalGameState(_ newValue: GameModel) {
    gameSyncStore.editCount += 1
    gameSyncStore.lastModifiedBy = session.localParticipant

    let message = GameMessage(
        game: newValue,
        editCount: gameSyncStore.editCount
    )

    Task {
        do {
            try await messenger.send(message)
        } catch {
            print("The app can't send the game state message due to: \(error)")
        }
    }
}
```

**Conflict Resolution Strategy:**
```swift
private func observeRemoteGameModelUpdates() {
    Task {
        for await (message, context) in messenger.messages(of: GameMessage.self) {
            let senderID = context.source.id

            let editCount = gameSyncStore.editCount
            let gameLastModifiedBy = gameSyncStore.lastModifiedBy ?? session.localParticipant
            let shouldAcceptMessage = if message.editCount > editCount {
                true
            } else if message.editCount == editCount && senderID > gameLastModifiedBy.id {
                true
            } else {
                false
            }

            guard shouldAcceptMessage else {
                continue
            }

            if message.game != gameSyncStore.game {
                gameSyncStore.game = message.game
            }
            gameSyncStore.editCount = message.editCount
            gameSyncStore.lastModifiedBy = context.source
        }
    }
}
```

---

## 🎨 Real-time Drawing Synchronization Patterns

### **Incremental Stroke Update Strategy**

**From: DrawingContentInAGroupSession**

```swift
struct UpsertStrokeMessage: Codable {
    let id: UUID
    let color: Stroke.Color
    let point: CGPoint  // Individual point, not entire stroke
}

func addPointToActiveStroke(_ point: CGPoint) {
    guard let stroke = activeStroke else { return }
    stroke.points.append(point)

    // Send individual point for real-time sync
    if let messenger = messenger {
        Task {
            try? await messenger.send(UpsertStrokeMessage(id: stroke.id, color: stroke.color, point: point))
        }
    }
}
```

**Key Pattern:** Send individual points rather than complete strokes for lower latency.

### **Hybrid Synchronization Strategy**

```swift
// Real-time updates
struct UpsertStrokeMessage: Codable {
    let id: UUID
    let color: Stroke.Color
    let point: CGPoint
}

// Full state for late joiners
struct CanvasMessage: Codable {
    let strokes: [Stroke]
    let pointCount: Int  // Heuristic for determining freshness
}
```

**Late Joiner Catch-up:**
```swift
groupSession.$activeParticipants
    .sink { activeParticipants in
        let newParticipants = activeParticipants.subtracting(groupSession.activeParticipants)

        Task {
            try? await messenger.send(CanvasMessage(strokes: self.strokes, pointCount: self.pointCount), to: .only(newParticipants))
        }
    }
    .store(in: &subscriptions)
```

### **Stroke Conflict Resolution**

```swift
func handle(_ message: UpsertStrokeMessage) {
    if let stroke = strokes.first(where: { $0.id == message.id }) {
        // Existing stroke - append point
        stroke.points.append(message.point)
    } else {
        // New stroke - create and add
        let stroke = Stroke(id: message.id, color: message.color)
        stroke.points.append(message.point)
        strokes.append(stroke)
    }
}
```

**Pattern Benefits:**
- UUID-based stroke identification prevents conflicts
- Incremental updates maintain real-time responsiveness
- Full state sync ensures late joiners get complete canvas

---

## 🎬 Media Coordination Patterns

### **AVPlayerPlaybackCoordinator Integration**

**From: SupportingCoordinatedMediaPlayback**

```swift
private var groupSession: GroupSession<MovieWatchingActivity>? {
    didSet {
        guard let session = groupSession else {
            player.rate = 0  // Stop playback if session terminates
            return
        }
        // Coordinate playback with the active session
        player.playbackCoordinator.coordinateWithSession(session)
    }
}
```

**Key Benefits:**
- Automatic timing coordination across devices
- Built-in conflict resolution for playback controls
- Seamless integration with existing AVPlayer controls

### **Custom Suspension for Quality Adaptation**

```swift
extension AVCoordinatedPlaybackSuspension.Reason {
    static var whatHappened = AVCoordinatedPlaybackSuspension.Reason(
        rawValue: "com.example.groupwatching.suspension.what-happened"
    )
}

func performWhatHappened() {
    let rewindDuration = CMTime(value: 10, timescale: 1)
    let rewindTime = player.currentTime() - rewindDuration

    // Start custom suspension for quality adaptation
    let suspension = player.playbackCoordinator.beginSuspension(for: .whatHappened)
    player.seek(to: rewindTime)
    player.rate = 2.0  // Double speed for catch-up

    // End suspension when catch-up complete
    DispatchQueue.main.asyncAfter(deadline: .now() + rewindDuration.seconds) {
        suspension.end()
    }
}
```

### **Centralized Coordination Manager**

```swift
class CoordinationManager {
    static let shared = CoordinationManager()
    @Published var enqueuedMovie: Movie?
    @Published var groupSession: GroupSession<MovieWatchingActivity>?

    private var subscriptions = Set<AnyCancellable>()

    func observeGroupSessions() {
        Task {
            for await groupSession in MovieWatchingActivity.sessions() {
                self.groupSession = groupSession
                groupSession.join()

                // Subscribe to session changes
                groupSession.$state.sink { [weak self] state in
                    if case .invalidated = state {
                        self?.groupSession = nil
                        self?.subscriptions.removeAll()
                    }
                }.store(in: &subscriptions)
            }
        }
    }
}
```

---

## 🚀 Performance Optimization Patterns

### **High-Frequency Update Optimization**

**From Drawing Sample:**
```swift
var tasks = Set<Task<Void, Never>>()

// Non-blocking message sending
func addPointToActiveStroke(_ point: CGPoint) {
    // Local update first
    stroke.points.append(point)

    // Asynchronous network update
    if let messenger = messenger {
        Task {
            try? await messenger.send(UpsertStrokeMessage(id: stroke.id, color: stroke.color, point: point))
        }
    }
}

// Task management
func configureGroupSession(_ session: GroupSession<DrawTogetherActivity>) {
    var task = Task {
        for await (message, _) in messenger.messages(of: UpsertStrokeMessage.self) {
            handle(message)
        }
    }
    tasks.insert(task)
}
```

### **Media Loading Optimization**

**From Media Sample:**
```swift
func loadImage(completion: @escaping (UIImage?) -> Void) {
    if FileManager.default.fileExists(atPath: imageURL.path) {
        // Load from cache
        completion(UIImage(contentsOfFile: imageURL.path)!)
    } else {
        // Generate with timeout protection
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let semaphore = DispatchSemaphore(value: 0)

            // Asynchronous image generation
            self?.imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: .zero)]) { _, cgImage, _, result, error in
                defer { semaphore.signal() }

                guard let cgImage = cgImage, result == .complete, error == nil else {
                    completion(nil)
                    return
                }

                completion(UIImage(cgImage: cgImage))
            }

            if semaphore.wait(timeout: .now() + self.imageLoadingTimeout) == .timedOut {
                self?.imageGenerator.cancelAllCGImageGeneration()
            }
        }
    }
}
```

---

## 🎯 Universal Implementation Patterns

### **Session Management Architecture**

```swift
// Universal session controller pattern
class SessionController<T: GroupActivity>: ObservableObject {
    @Published var session: GroupSession<T>?
    @Published var messenger: GroupSessionMessenger?
    @Published var systemCoordinator: SystemCoordinator?

    private var tasks = Set<Task<Void, Never>>()

    init?(_ groupSession: GroupSession<T>) async {
        self.session = groupSession

        // Setup messenger
        self.messenger = GroupSessionMessenger(session: groupSession)

        // Setup system coordinator for visionOS
        #if os(visionOS)
        if let coordinator = await groupSession.systemCoordinator {
            self.systemCoordinator = coordinator
            var config = SystemCoordinator.Configuration()
            config.supportsGroupImmersiveSpace = true
            coordinator.configuration = config
        }
        #endif

        setupMessageHandlers()
        groupSession.join()
    }

    private func setupMessageHandlers() {
        // Setup message handling tasks
        // Add to tasks set for cleanup
    }

    deinit {
        tasks.forEach { $0.cancel() }
    }
}
```

### **Error Handling Pattern**

```swift
// Universal error handling
extension SessionController {
    private func handleError(_ error: Error, context: String) {
        print("SharePlay Error [\(context)]: \(error)")

        // Handle specific error types
        if let groupActivityError = error as? GroupActivityError {
            switch groupActivityError {
            case .notEligibleForGroupSession:
                // Show user guidance
                break
            case .sessionAlreadyActive:
                // Handle session conflict
                break
            @unknown default:
                // Unknown error handling
                break
            }
        }
    }
}
```

### **Activity Activation Pattern**

```swift
// Universal SharePlay button
struct SharePlayButton<ActivityType: GroupActivity & Transferable & Sendable>: View {
    let activity: ActivityType
    let text: String

    @ObservedObject private var groupStateObserver = GroupStateObserver()
    @State private var isActivationErrorViewPresented = false

    var body: some View {
        ZStack {
            ShareLink(item: activity, preview: SharePreview(text)).hidden()

            Button(text, systemImage: "shareplay") {
                Task.detached {
                    do {
                        try await activity.activate()
                    } catch {
                        await MainActor.run {
                            isActivationErrorViewPresented = true
                        }
                    }
                }
            }
            .disabled(!groupStateObserver.isEligibleForGroupSession)
            .alert("Unable to start activity", isPresented: $isActivationErrorViewPresented) {
                Button("Ok", role: .cancel) { }
            } message: {
                Text("Please try again later.")
            }
        }
    }
}
```

---

## 🏆 Key Takeaways for Production Apps

### **1. Choose the Right Synchronization Strategy**
- **Gaming**: Turn-based with conflict resolution
- **Drawing**: Incremental updates with full state sync
- **Media**: Built-in AVPlayer coordination

### **2. Implement Robust Error Handling**
- Always handle session invalidation
- Provide user feedback for activation errors
- Gracefully degrade when SharePlay isn't available

### **3. Optimize for Performance**
- Use asynchronous operations for network updates
- Implement caching for media assets
- Prioritize latency over bandwidth for real-time features

### **4. Design for User Experience**
- Provide clear feedback during session states
- Handle participant joins/leaves gracefully
- Implement proper cleanup on session termination

### **5. Leverage Platform-Specific Features**
- Use SystemCoordinator for visionOS spatial features
- Implement custom spatial templates for gaming
- Use AVPlayerPlaybackCoordinator for media apps

---

These patterns provide a comprehensive foundation for building production-quality SharePlay applications across different domains and platforms.