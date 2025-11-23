# TCA (The Composable Architecture) + SharePlay Integration

## Overview

This example demonstrates advanced patterns for integrating SharePlay with The Composable Architecture (TCA), based on real-world patterns from sophisticated multiplayer applications like GreenSpurt.

## Core Architecture

### 1. Shared State Management with @Shared

```swift
import ComposableArchitecture
import GroupActivities

// MARK: - Shared State Keys
extension SharedKey {
    static var sessionState: SharedKey<GroupSession<CustomGroupActivity>.State?> {
        SharedKey("sessionState") { nil }
    }

    static var hasJoinedGroupSession: SharedKey<Bool> {
        SharedKey("hasJoinedGroupSession") { false }
    }

    static var localPlayerID: SharedKey<UUID?> {
        SharedKey("localPlayerID") { nil }
    }

    static var participants: SharedKey<[Participant]> {
        SharedKey("participants") { [] }
    }
}

// MARK: - Core App Feature with SharePlay
@Reducer
struct AppFeature {
    @Shared(.sessionState)
    var sessionState: GroupSession<CustomGroupActivity>.State?

    @Shared(.hasJoinedGroupSession)
    var hasJoinedGroupSession: Bool = false

    @Shared(.localPlayerID)
    var localPlayerID: UUID?

    @Shared(.participants)
    var participants: [Participant] = []

    @ObservableState
    struct State {
        var game: GameFeature.State
        var multiplayer: MultiplayerFeature.State
        var sharePlay: SharePlayFeature.State
        var isGroupSessionActive = false
        var connectionStatus: ConnectionStatus = .disconnected
    }

    enum Action {
        case game(GameFeature.Action)
        case multiplayer(MultiplayerFeature.Action)
        case sharePlay(SharePlayFeature.Action)
        case internal(InternalAction)

        enum InternalAction {
            case updatedSessionState(GroupSession<CustomGroupActivity>.State?)
            case synchronizeStateWithNewParticipants([GroupSession<CustomGroupActivity>.Participant])
            case updateLocalPlayerID(UUID)
            case updateParticipant(Participant)
            case handleSharePlayMessage(Message)
            case configureGroupSession(GroupSession<CustomGroupActivity>)
            case startObservingGroupSessionState
            case endGroupSession
        }
    }

    enum ConnectionStatus {
        case disconnected
        case connecting
        case connected
        case reconnecting
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.game, action: \.game) {
            GameFeature()
        }

        Scope(state: \.multiplayer, action: \.multiplayer) {
            MultiplayerFeature()
        }

        Scope(state: \.sharePlay, action: \.sharePlay) {
            SharePlayFeature()
        }

        Reduce { state, action in
            switch action {
            case .game:
                return .none

            case .multiplayer:
                return .none

            case .sharePlay:
                return .none

            case .internal(.updatedSessionState(let sessionState)):
                state.$sessionState.withLock { $0 = sessionState }
                state.$hasJoinedGroupSession.withLock { $0 = sessionState == .joined }
                state.isGroupSessionActive = sessionState == .joined

                if sessionState == .joined {
                    state.connectionStatus = .connected
                } else if sessionState == .invalidated {
                    state.connectionStatus = .disconnected
                }

                return .none

            case .internal(.synchronizeStateWithNewParticipants(let participants)):
                let newParticipants = participants.map { participant in
                    Participant(
                        id: participant.id,
                        displayName: participant.displayName,
                        isLocalUser: participant.id == state.localPlayerID
                    )
                }

                state.$participants.withLock { currentParticipants in
                    // Add new participants without duplicates
                    for newParticipant in newParticipants {
                        if !currentParticipants.contains(where: { $0.id == newParticipant.id }) {
                            currentParticipants.append(newParticipant)
                        }
                    }
                }

                return .send(.multiplayer(.participantsUpdated(state.$participants)))

            case .internal(.updateLocalPlayerID(let id)):
                state.$localPlayerID.withLock { $0 = id }
                return .none

            case .internal(.updateParticipant(let participant)):
                state.$participants.withLock { participants in
                    if let index = participants.firstIndex(where: { $0.id == participant.id }) {
                        participants[index] = participant
                    }
                }
                return .send(.multiplayer(.participantUpdated(participant)))

            case .internal(.handleSharePlayMessage(let message)):
                return handleSharePlayMessage(message, state: &state)

            case .internal(.configureGroupSession(let session)):
                return .run { send in
                    await groupActivityClient.configure(groupSession: session)
                    await send(.internal(.startObservingGroupSessionState))
                }

            case .internal(.startObservingGroupSessionState):
                return .run { send in
                    for await state in await groupActivityClient.observeGroupSessionStateUpdates() {
                        await send(.internal(.updatedSessionState(state)))
                    }
                }

            case .internal(.endGroupSession):
                state.connectionStatus = .disconnected
                state.isGroupSessionActive = false
                state.$sessionState.withLock { $0 = nil }
                state.$hasJoinedGroupSession.withLock { $0 = false }
                state.$participants.withLock { $0 = [] }
                return .run { _ in
                    await groupActivityClient.end()
                }
            }
        }
    }

    private func handleSharePlayMessage(_ message: Message, state: inout State) -> Effect<Action> {
        switch message {
        case .playerUpdate(let playerUpdate):
            let participant = Participant(
                id: playerUpdate.player.id,
                displayName: playerUpdate.player.displayName,
                isLocalUser: playerUpdate.player.id == state.localPlayerID
            )
            return .send(.internal(.updateParticipant(participant)))

        case .gameStateUpdate(let gameState):
            return .send(.game(.updateSharedGameState(gameState)))

        case .multiplayerAction(let action):
            return .send(.multiplayer(.handleRemoteAction(action)))

        default:
            return .none
        }
    }
}
```

### 2. Specialized SharePlay Feature

```swift
@Reducer
struct SharePlayFeature {
    @ObservableState
    struct State {
        var isActive = false
        var availableSessions: [GroupSession<CustomGroupActivity>] = []
        var currentSession: GroupSession<CustomGroupActivity>?
        var connectionError: String?
        var isStarting = false
    }

    enum Action {
        case startSession
        case endSession
        case joinSession(GroupSession<CustomGroupActivity>)
        case observeSessions
        case sessionStarted(GroupSession<CustomGroupActivity>)
        case sessionEnded
        case sessionError(String)
        case internal(InternalAction)

        enum InternalAction {
            case sessionsUpdated([GroupSession<CustomGroupActivity>])
            case sessionStateUpdated(GroupSession<CustomGroupActivity>.State)
            case messageReceived(Message, GroupSession<CustomGroupActivity>.Participant)
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .startSession:
                state.isStarting = true
                state.connectionError = nil
                return .run { send in
                    do {
                        let activity = CustomGroupActivity()
                        let session = try await activity.prepareForActivation()

                        await send(.sessionStarted(session))
                        try await session.activate()

                        state.isStarting = false
                        state.isActive = true
                        state.currentSession = session
                    } catch {
                        await send(.sessionError(error.localizedDescription))
                        state.isStarting = false
                    }
                }

            case .endSession:
                guard let session = state.currentSession else { return .none }

                return .run { send in
                    await session.end()
                    await send(.sessionEnded)
                }

            case .joinSession(let session):
                return .run { send in
                    do {
                        try await session.join()
                        await send(.sessionStarted(session))
                    } catch {
                        await send(.sessionError(error.localizedDescription))
                    }
                }

            case .observeSessions:
                return .run { send in
                    // Continuous session observation
                    for await sessions in CustomGroupActivity.sessions() {
                        await send(.internal(.sessionsUpdated(Array(sessions))))
                    }
                }

            case .sessionStarted(let session):
                state.currentSession = session
                state.isActive = true
                state.isStarting = false
                state.connectionError = nil
                return .run { send in
                    // Start observing session state
                    for await stateChange in session.states {
                        await send(.internal(.sessionStateUpdated(stateChange)))
                    }
                }

            case .sessionEnded:
                state.isActive = false
                state.currentSession = nil
                return .none

            case .sessionError(let error):
                state.connectionError = error
                state.isStarting = false
                return .none

            case .internal(.sessionsUpdated(let sessions)):
                state.availableSessions = sessions
                return .none

            case .internal(.sessionStateUpdated(let sessionState)):
                // Handle session state changes
                return .none

            case .internal(.messageReceived(let message, let participant)):
                // Handle incoming messages
                return .none
            }
        }
    }
}
```

### 3. Multiplayer Coordination Feature

```swift
@Reducer
struct MultiplayerFeature {
    @Shared(.participants)
    var participants: [Participant]

    @ObservableState
    struct State {
        var selectedSeats: Set<Int> = []
        var gameStarted = false
        var isHost = false
        var seatClaimingInProgress = false
    }

    enum Action {
        case claimSeat(Int)
        case releaseSeat(Int)
        case participantsUpdated([Participant])
        case participantUpdated(Participant)
        case startGame
        case handleRemoteAction(RemoteAction)
        case internal(InternalAction)

        enum InternalAction {
            case seatClaimed(Int, by: UUID)
            case seatReleased(Int)
            case gameStarted
        }

        enum RemoteAction {
            case seatClaim(Int, UUID)
            case seatRelease(Int)
            case startGame
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .claimSeat(let seatIndex):
                guard !state.selectedSeats.contains(seatIndex) else { return .none }
                state.selectedSeats.insert(seatIndex)
                state.seatClaimingInProgress = true

                return .run { send in
                    // Broadcast seat claim to other participants
                    let action = RemoteAction.seatClaim(seatIndex, UUID()) // Use actual player ID
                    await broadcastAction(action)

                    state.seatClaimingInProgress = false
                }

            case .releaseSeat(let seatIndex):
                state.selectedSeats.remove(seatIndex)
                return .run { send in
                    let action = RemoteAction.seatRelease(seatIndex)
                    await broadcastAction(action)
                }

            case .participantsUpdated(let newParticipants):
                return .run { send in
                    // Update local state based on participant changes
                    for participant in newParticipants {
                        if !participants.contains(where: { $0.id == participant.id }) {
                            await send(.participantUpdated(participant))
                        }
                    }
                }

            case .participantUpdated(let participant):
                // Update participant in shared state
                return .run { send in
                    // Update participant information
                }

            case .startGame:
                guard state.isHost else { return .none }
                state.gameStarted = true

                return .run { send in
                    await broadcastAction(.startGame)
                    await send(.internal(.gameStarted))
                }

            case .handleRemoteAction(let action):
                return handleRemoteAction(action, state: &state)

            case .internal:
                return .none
            }
        }
    }

    private func handleRemoteAction(_ action: RemoteAction, state: inout State) -> Effect<Action> {
        switch action {
        case .seatClaim(let seatIndex, let playerID):
            // Handle remote seat claim
            state.selectedSeats.insert(seatIndex)
            return .none

        case .seatRelease(let seatIndex):
            state.selectedSeats.remove(seatIndex)
            return .none

        case .startGame:
            state.gameStarted = true
            return .none
        }
    }

    private func broadcastAction(_ action: RemoteAction) async {
        // Implement action broadcasting to other participants
        // This would use the GroupActivityMessenger
    }
}
```

### 4. Advanced Message System with TCA

```swift
// MARK: - Message Types
enum Message: Codable {
    case playerUpdate(PlayerUpdateMessage)
    case gameStateUpdate(GameStateUpdateMessage)
    case multiplayerAction(MultiplayerActionMessage)
    case seatClaim(SeatClaimMessage)
    case seatRelease(SeatReleaseMessage)
    case gameStart(GameStartMessage)
    case custom(CustomMessage)
}

// Specific message types
struct PlayerUpdateMessage: Codable {
    let player: Player
    let timestamp: Date
}

struct GameStateUpdateMessage: Codable {
    let gameState: GameState
    let playerID: UUID
    let version: Int
}

struct MultiplayerActionMessage: Codable {
    let action: MultiplayerFeature.RemoteAction
    let playerID: UUID
    let timestamp: Date
}

struct SeatClaimMessage: Codable {
    let seatIndex: Int
    let playerID: UUID
    let displayName: String
}

struct SeatReleaseMessage: Codable {
    let seatIndex: Int
    let playerID: UUID
}

struct GameStartMessage: Codable {
    let startTime: Date
    let hostID: UUID
}

struct CustomMessage: Codable {
    let type: String
    let data: Data
}

// MARK: - Message Handling Reducer
extension AppFeature {
    private func setupMessageObservation() -> Effect<Action> {
        return .run { send in
            await withTaskGroup(of: Void.self) { group in
                // New group session participant joined
                group.addTask { [client] in
                    for await message in await client.observeNewParticipants() {
                        if Task.isCancelled { break }
                        await send(.internal(.synchronizeStateWithNewParticipants(message.participants)))
                    }
                }

                // Other player changed their model state
                group.addTask { [client, localPlayerIDSnapshot] in
                    for await message in await client.observePlayerUpdates() {
                        if Task.isCancelled { break }
                        // Avoid loop updating local user
                        if message.player.id != localPlayerIDSnapshot {
                            await send(.updatePlayer(id: message.player.id, displayName: message.player.displayName, photo: message.player.photo))
                        }
                    }
                }

                // Messages from other players
                group.addTask { [client] in
                    for await (message, participant) in await client.observeMessages() {
                        if Task.isCancelled { break }
                        await send(.internal(.handleSharePlayMessage(message)))
                    }
                }

                // Local player state updated (avatar, name, etc.)
                group.addTask { [client] in
                    for await (id, displayName, photo) in await client.observeLocalPlayerUpdates() {
                        if Task.isCancelled { break }
                        await send(.internal(.updateLocalPlayerID(id)))
                    }
                }

                // Group session state changed (joined, left, etc.)
                group.addTask { [client] in
                    for await state in await client.observeGroupSessionStateUpdates() {
                        if Task.isCancelled { break }
                        await send(.internal(.updatedSessionState(state)))
                    }
                }
            }
        }
    }
}
```

### 5. TCA-Optimized UI Components

```swift
import SwiftUI
import ComposableArchitecture

// MARK: - Main Multiplayer View
struct MultiplayerGameView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 20) {
                // Connection Status
                ConnectionStatusView(
                    status: viewStore.connectionStatus,
                    isGroupSessionActive: viewStore.isGroupSessionActive
                )

                // Participants
                ParticipantsView(
                    participants: viewStore.participants,
                    localPlayerID: viewStore.localPlayerID
                )

                // Multiplayer Menu
                if viewStore.hasJoinedGroupSession {
                    MultiplayerMenuView(
                        store: store.scope(
                            state: \.multiplayer,
                            action: \.multiplayer
                        )
                    )
                } else {
                    SharePlayActivationView(
                        store: store.scope(
                            state: \.sharePlay,
                            action: \.sharePlay
                        )
                    )
                }

                // Game Content
                if viewStore.multiplayer.gameStarted {
                    GameContentView(
                        store: store.scope(
                            state: \.game,
                            action: \.game
                        )
                    )
                }
            }
        }
    }
}

// MARK: - SharePlay Activation View
struct SharePlayActivationView: View {
    let store: StoreOf<SharePlayFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 16) {
                Text("Start SharePlay Session")
                    .font(.headline)

                if viewStore.isStarting {
                    ProgressView("Starting session...")
                } else if let error = viewStore.connectionError {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Button("Start SharePlay") {
                    viewStore.send(.startSession)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewStore.isStarting)

                // Available sessions
                if !viewStore.availableSessions.isEmpty {
                    Text("Or join existing session:")
                        .font(.subheadline)

                    ForEach(viewStore.availableSessions, id: \.id) { session in
                        Button("Join with \(session.participants.count) players") {
                            viewStore.send(.joinSession(session))
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - Multiplayer Menu View
struct MultiplayerMenuView: View {
    let store: StoreOf<MultiplayerFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 16) {
                Text("Multiplayer Menu")
                    .font(.headline)

                // Seat claiming interface
                SeatClaimingView(
                    selectedSeats: viewStore.selectedSeats,
                    onClaim: { seatIndex in
                        viewStore.send(.claimSeat(seatIndex))
                    },
                    onRelease: { seatIndex in
                        viewStore.send(.releaseSeat(seatIndex))
                    }
                )

                // Start game button (host only)
                if viewStore.isHost {
                    Button("Start Game") {
                        viewStore.send(.startGame)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewStore.selectedSeats.isEmpty)
                }

                if viewStore.seatClaimingInProgress {
                    ProgressView("Claiming seat...")
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - Seat Claiming View
struct SeatClaimingView: View {
    let selectedSeats: Set<Int>
    let onClaim: (Int) -> Void
    let onRelease: (Int) -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("Select Your Seat")
                .font(.subheadline)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(0..<5, id: \.self) { seatIndex in
                    Button {
                        if selectedSeats.contains(seatIndex) {
                            onRelease(seatIndex)
                        } else {
                            onClaim(seatIndex)
                        }
                    } label: {
                        VStack {
                            Image(systemName: selectedSeats.contains(seatIndex) ? "person.fill" : "person")
                                .font(.title2)
                            Text("Seat \(seatIndex + 1)")
                                .font(.caption)
                        }
                        .frame(width: 60, height: 60)
                        .background(selectedSeats.contains(seatIndex) ? Color.blue : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
}

// MARK: - Connection Status View
struct ConnectionStatusView: View {
    let status: AppFeature.ConnectionStatus
    let isGroupSessionActive: Bool

    var body: some View {
        HStack {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            Text(statusText)
                .font(.caption)

            if isGroupSessionActive {
                Text("• Session Active")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }

    private var statusColor: Color {
        switch status {
        case .connected:
            return .green
        case .connecting, .reconnecting:
            return .orange
        case .disconnected:
            return .red
        }
    }

    private var statusText: String {
        switch status {
        case .connected:
            return "Connected"
        case .connecting:
            return "Connecting..."
        case .reconnecting:
            return "Reconnecting..."
        case .disconnected:
            return "Disconnected"
        }
    }
}
```

## Best Practices for TCA + SharePlay

### 1. State Management
- Use `@Shared` for cross-component state
- Separate local state from shared state
- Implement proper state synchronization

### 2. Action Handling
- Separate internal actions from user actions
- Handle remote actions differently from local actions
- Use proper effect chaining

### 3. Performance Optimization
- Debounce rapid state changes
- Use selective state observation
- Optimize message passing

### 4. Error Handling
- Handle network errors gracefully
- Implement retry mechanisms
- Provide user feedback for errors

### 5. Testing
- Mock SharePlay dependencies
- Test state transitions
- Verify action handling

This TCA + SharePlay integration pattern provides a robust, scalable foundation for multiplayer applications with excellent separation of concerns and predictable state management.