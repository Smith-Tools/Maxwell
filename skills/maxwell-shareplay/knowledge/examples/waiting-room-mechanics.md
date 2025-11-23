# Example: SharePlay Waiting Room Mechanics

## Success Scenario Analysis
Waiting for certain amount of people to join a session and then displaying the option to start, altogether all in sync.

## Key Implementation Requirements

### 1. Waiting Room State Management
```swift
class WaitingRoomManager: ObservableObject {
    @Published var participants: [Participant] = []
    @Published var minimumParticipants: Int = 2
    @Published var sessionState: WaitingRoomState = .waiting
    @Published var canStartSession: Bool = false

    enum WaitingRoomState {
        case waiting      // Waiting for participants
        case ready        // Minimum participants reached
        case starting     // Session starting countdown
        case inSession    // Session active
    }

    // Check if session can start
    private func updateCanStartSession() {
        canStartSession = participants.count >= minimumParticipants
        if canStartSession && sessionState == .waiting {
            sessionState = .ready
        }
    }
}
```

### 2. Participant Management
```swift
struct Participant: Identifiable, Codable {
    let id: UUID
    let name: String
    let isHost: Bool
    let joinDate: Date
    var isReady: Bool = false
    var persona: PersonaData?

    // SharePlay synchronization
    struct PersonaData: Codable {
        let position: SIMD3<Float>
        let orientation: simd_quatf
    }
}
```

### 3. Synchronized Start Coordination
```swift
class SessionStartCoordinator {
    private let messenger: GroupActivityMessenger
    private let countdownDuration: TimeInterval = 3.0

    func initiateStartCountdown() async throws {
        // 1. Broadcast start intent to all participants
        try await messenger.send(SessionMessage.startCountdown)

        // 2. Begin synchronized countdown
        try await startSynchronizedCountdown()
    }

    private func startSynchronizedCountdown() async throws {
        for countdown in (1...Int(countdownDuration)).reversed() {
            // Broadcast countdown update
            try await messenger.send(SessionMessage.countdown(countdown))
            try await Task.sleep(for: .seconds(1))
        }

        // 3. Final start signal
        try await messenger.send(SessionMessage.start)
    }
}
```

### 4. Waiting Room UI
```swift
struct WaitingRoomView: View {
    @StateObject private var waitingRoomManager = WaitingRoomManager()
    @State private var showingStartConfirmation = false

    var body: some View {
        VStack(spacing: 20) {
            // Participant list
            ParticipantListView(participants: waitingRoomManager.participants)

            // Status indicator
            WaitingRoomStatusView(
                currentState: waitingRoomManager.sessionState,
                participantCount: waitingRoomManager.participants.count,
                minimumRequired: waitingRoomManager.minimumParticipants
            )

            // Start button (only show when ready)
            if waitingRoomManager.canStartSession {
                Button("Start Session") {
                    showingStartConfirmation = true
                }
                .buttonStyle(.borderedProminent)
                .disabled(waitingRoomManager.sessionState == .starting)
            }

            // Host controls
            if isHost {
                HostControlsView(waitingRoomManager: waitingRoomManager)
            }
        }
        .confirmationDialog("Start SharePlay Session", isPresented: $showingStartConfirmation) {
            Button("Start Now", role: .destructive) {
                Task {
                    try await startSession()
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }

    private func startSession() async {
        waitingRoomManager.sessionState = .starting
        // Synchronized start logic here
    }
}
```

### 5. Real-time Participant Sync
```swift
extension WaitingRoomManager: GroupActivityObserver {
    func groupActivitySession(_ session: GroupActivitySession, participantDidJoin participant: Participant) {
        DispatchQueue.main.async {
            self.participants.append(participant)
            self.updateCanStartSession()
        }
    }

    func groupActivitySession(_ session: GroupActivitySession, participantDidLeave participant: Participant) {
        DispatchQueue.main.async {
            self.participants.removeAll { $0.id == participant.id }
            self.updateCanStartSession()
        }
    }

    func groupActivitySession(_ session: GroupActivitySession, didReceive message: Data) {
        // Handle ready state changes, start countdowns, etc.
        handleWaitingRoomMessage(message)
    }
}
```

## Critical Integration Points

### Minimum Participant Logic
- Configurable minimum participant threshold
- Host can override minimum for testing
- Graceful handling when participants drop below minimum

### Synchronized Start Experience
- All participants see same countdown
- Network latency compensation for countdown timing
- Fallback if synchronization fails

### Participant States
- Track ready status for each participant
- Visual indicators for participant states
- Handle network disconnections gracefully

## Testing Requirements
1. **Participant Join/Leave**: Test dynamic participant changes
2. **Minimum Threshold**: Verify start button appears at correct participant count
3. **Synchronized Countdown**: All participants see same countdown timing
4. **Network Conditions**: Test with poor network connectivity
5. **Host Migration**: Test start coordination if host leaves
6. **Edge Cases**: Single participant, rapid join/leave, etc.

## Implementation Checklist
- [ ] Implement waiting room state management
- [ ] Create participant data structures
- [ ] Add synchronized start countdown
- [ ] Design waiting room UI components
- [ ] Implement real-time participant sync
- [ ] Add minimum participant logic
- [ ] Handle network disconnection scenarios
- [ ] Test multi-participant coordination
- [ ] Validate synchronized start timing
- [ ] Add accessibility features for waiting room