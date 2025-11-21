# SharePlay API Reference

## Core Framework: GroupActivities

### Primary Classes

#### GroupActivity
```swift
protocol GroupActivity {
    var metadata: GroupActivityMetadata { get }
    static var activityIdentifier: String { get }

    func activate() async throws
    func prepareForActivation() async throws
}
```

#### GroupSession<T>
```swift
class GroupSession<T: GroupActivity> {
    @Published var participants: Set<Participant>
    @Published var state: State

    enum State {
        case waiting
        case joined
        case invalidated
    }

    func join()
    func leave()
}
```

#### GroupSessionMessenger
```swift
class GroupSessionMessenger {
    init(session: GroupSession<T>, deliveryMode: DeliveryMode = .reliable)

    func send<Message: Codable>(_ message: Message, to participants: ParticipantSet? = nil) async throws
    func messages<Message: Codable>(of type: Message.Type) -> AsyncStream<(Message, Participant)>

    enum DeliveryMode {
        case reliable
        case unreliable
    }
}
```

#### SystemCoordinator (visionOS)
```swift
class SystemCoordinator {
    var configuration: Configuration { get set }
    var groupImmersionStyle: AsyncStream<GroupImmersionStyle?>

    struct Configuration {
        var supportsGroupImmersiveSpace: Bool
        var spatialTemplatePreference: SpatialTemplatePreference?
    }
}
```

### Supporting Classes

#### GroupActivityMetadata
```swift
struct GroupActivityMetadata {
    var type: ActivityType
    var title: String
    var subtitle: String?
    var fallbackURL: URL?
    var supportsContinuationOnTV: Bool
}
```

#### Participant
```swift
struct Participant: Identifiable, Hashable {
    let id: UUID
    let initials: String
    let handle: String?
    var isLocal: Bool
    var isNearbyWithLocalParticipant: Bool
}
```

#### GroupStateObserver
```swift
class GroupStateObserver: ObservableObject {
    @Published var isEligibleForGroupSession: Bool
}
```

## SwiftUI Integration

### Modifiers

#### handlesExternalEvents (Legacy)
```swift
.modifier(handlesExternalEvents(preferring: [String], allowing: [String]))
```

#### groupActivityAssociation (VisionOS 26+)
```swift
.modifier(groupActivityAssociation(.primary(String)))
.modifier(groupActivityAssociation(.secondary(String)))
.modifier(groupActivityAssociation([Association]))
.modifier(groupActivityAssociation(Association?))
```

### Environment Values

#### SharePlay Environment
```swift
@Environment(\.supportsMultipleWindows) var supportsMultipleWindows: Bool
@Environment(\.openWindow) var openWindow: OpenWindowAction
@Environment(\.dismissWindow) var dismissWindow: DismissWindowAction
@Environment(\.openImmersiveSpace) var openImmersiveSpace: OpenImmersiveSpaceAction
@Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace: DismissImmersiveSpaceAction
```

### Transferable Protocol

#### GroupActivityTransferRepresentation
```swift
struct GroupActivityTransferRepresentation<Data>: TransferRepresentation {
    init(_ build: @escaping (Data) -> some GroupActivity)
}
```

## VisionOS Spatial Features

### Spatial Templates
```swift
enum SpatialTemplatePreference {
    case sideBySide
    case aroundTable
    case sideBySide.contentExtent(CGFloat)
}
```

### Immersion Styles
```swift
enum GroupImmersionStyle {
    case full
    case mixed
    case progressive
}
```

## Nearby Sharing (VisionOS)

### ARKit Integration
```swift
#if os(visionOS)
import ARKit

class NearbySharingManager {
    func startNearbySharing() async
    func stopNearbySharing()

    // ARKit shared world anchors
    func shareWorldAnchor(_ anchor: ARAnchor) async
    func receiveWorldAnchors() -> AsyncStream<ARAnchor>
}
#endif
```

## Data Synchronization

### Message Patterns
```swift
// Reliable messaging for state updates
let reliableMessenger = GroupSessionMessenger(session: session, deliveryMode: .reliable)

// Unreliable messaging for real-time interactions
let unreliableMessenger = GroupSessionMessenger(session: session, deliveryMode: .unreliable)
```

### Late Joiner Support
```swift
// Send current state to new participants
groupSession.$activeParticipants
    .sink { participants in
        let newParticipants = participants.subtracting(previousParticipants)
        Task {
            try? await messenger.send(currentState, to: .only(newParticipants))
        }
    }
```

## File Transfer (iOS 17+)

### GroupSessionJournal
```swift
class GroupSessionJournal {
    func add(_ url: URL, metadata: FileMetadata) async throws -> Attachment
    var attachments: AsyncStream<Attachment>
}

struct Attachment {
    let fileURL: URL?
    let metadata: FileMetadata
}
```

## Implementation Patterns

### Basic Activity Setup
```swift
struct MyActivity: GroupActivity, Transferable {
    static let activityIdentifier = "com.myapp.myactivity"

    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "My Activity"
        metadata.type = .generic
        return metadata
    }
}
```

### Session Management
```swift
class SharePlayManager: ObservableObject {
    @Published var session: GroupSession<MyActivity>?
    private var messenger: GroupSessionMessenger?

    func configureSession(_ session: GroupSession<MyActivity>) {
        self.session = session
        self.messenger = GroupSessionMessenger(session: session)

        Task {
            await setupMessageHandlers()
        }

        session.join()
    }
}
```

### Scene Association (Modern)
```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .groupActivityAssociation(.primary("main-activity"))

        ImmersiveSpace(id: "immersive") {
            ImmersiveView()
        }
        .groupActivityAssociation(.secondary("immersive-activity"))
    }
}
```

## Availability Detection

### Runtime Check
```swift
class SharePlayAvailabilityChecker: ObservableObject {
    @Published var isAvailable = false
    @StateObject private var groupStateObserver = GroupStateObserver()

    init() {
        isAvailable = groupStateObserver.isEligibleForGroupSession

        #if targetEnvironment(simulator)
        isAvailable = false // Force false for simulator
        #endif
    }
}
```

## Error Handling

### Common Errors
- `GroupActivityError.notEligibleForGroupSession`
- `GroupActivityError.sessionAlreadyActive`
- Network connectivity issues
- Entitlements missing

### Best Practices
```swift
do {
    try await activity.activate()
} catch GroupActivityError.notEligibleForGroupSession {
    // Show appropriate UI
} catch {
    // Handle other errors
}
```

## Performance Considerations

### Message Optimization
- Keep messages small (< 1KB recommended)
- Use reliable delivery for state changes
- Use unreliable delivery for real-time interactions
- Implement rate limiting for high-frequency updates

### Session Management
- Join sessions as quickly as possible
- Clean up resources when session ends
- Handle participant drops gracefully
- Implement proper memory management

---

This API reference covers all essential SharePlay APIs across iOS, iPadOS, and visionOS platforms.