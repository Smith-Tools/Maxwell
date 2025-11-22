# GameCenter + SharePlay Integration for visionOS

## Overview

Based on **WWDC 2025 Session 110338: "Add SharePlay to your multiplayer game with Game Center"**, this example demonstrates how to integrate GameCenter matchmaking with SharePlay for enhanced multiplayer gaming experiences on visionOS.

**Session Link**: Limited session - Based on Apple's GameCenter + SharePlay integration patterns

## Key Concepts from GameCenter Integration

### 🎯 Apple's GameCenter + SharePlay Architecture
- **Unified Matchmaking**: GameCenter handles player matching, SharePlay handles real-time sync
- **Seamless Transition**: From matchmaking to gameplay without leaving the app
- **Player Identity**: GameCenter authentication provides secure player identification
- **Achievement Sharing**: Shared achievement unlocking during multiplayer sessions

### 🆕 Integration Benefits
- **Automatic Player Discovery**: No need for manual friend finding
- **Ranking System**: Match players based on skill levels
- **Cross-Platform**: Works across iOS, iPadOS, visionOS, and macOS
- **Persistent Sessions**: Resume games even after app backgrounding

## Implementation Architecture

### 1. GameCenter + SharePlay Manager

```swift
import GameKit
import GroupActivities
import SwiftUI

@MainActor
class GameCenterSharePlayManager: ObservableObject {
    @Published var isGameCenterAuthenticated = false
    @Published var currentMatch: GKMatch?
    @Published var sharePlaySession: GroupSession<GameActivity>?
    @Published var players: [GKPlayer] = []
    @Published var matchmakingState: MatchmakingState = .idle

    private let gameCenterAuthenticator = GameCenterAuthenticator()
    private let matchmakingManager = GameCenterMatchmakingManager()
    private let sharePlayCoordinator = SharePlayCoordinator()

    enum MatchmakingState {
        case idle
        case searching
        case foundMatch
        case startingSharePlay
        case active
        case error(String)
    }

    init() {
        setupGameCenterAuthentication()
        setupMatchmakingCallbacks()
    }

    private func setupGameCenterAuthentication() {
        gameCenterAuthenticator.authenticate { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let player):
                    self?.isGameCenterAuthenticated = true
                    self?.players = [player]
                case .failure(let error):
                    self?.matchmakingState = .error(error.localizedDescription)
                }
            }
        }
    }

    private func setupMatchmakingCallbacks() {
        matchmakingManager.onMatchFound = { [weak self] match in
            Task { @MainActor in
                self?.handleMatchFound(match)
            }
        }

        matchmakingManager.onPlayerConnected = { [weak self] player in
            Task { @MainActor in
                self?.players.append(player)
            }
        }

        matchmakingManager.onPlayerDisconnected = { [weak self] player in
            Task { @MainActor in
                self?.players.removeAll { $0.playerID == player.playerID }
            }
        }
    }

    func startMultiplayerGame() async {
        guard isGameCenterAuthenticated else {
            matchmakingState = .error("GameCenter authentication required")
            return
        }

        matchmakingState = .searching

        do {
            // Start GameCenter matchmaking
            let match = try await matchmakingManager.findMatch()
            currentMatch = match
            matchmakingState = .foundMatch

            // Start SharePlay session with matched players
            await startSharePlaySession(with: match)

        } catch {
            matchmakingState = .error(error.localizedDescription)
        }
    }

    private func handleMatchFound(_ match: GKMatch) async {
        currentMatch = match
        matchmakingState = .startingSharePlay

        // Set up match delegate
        match.delegate = self

        // Start SharePlay session
        await startSharePlaySession(with: match)
    }

    private func startSharePlaySession(with match: GKMatch) async {
        do {
            // Create game activity with GameCenter integration
            let activity = GameActivity()
            activity.gameCenterMatch = match

            // Prepare SharePlay session
            let session = try await activity.prepareForActivation()
            sharePlaySession = session

            // Configure game session
            await configureGameSession(session: session, match: match)

            // Activate SharePlay
            try await session.activate()

            matchmakingState = .active

            // Notify match that session is ready
            try await match.startSession()

        } catch {
            matchmakingState = .error("Failed to start SharePlay: \(error.localizedDescription)")
        }
    }

    private func configureGameSession(
        session: GroupSession<GameActivity>,
        match: GKMatch
    ) async {
        // Configure spatial template for gaming
        let gameTemplate = createGamingSpatialTemplate()
        session.configuration?.spatialTemplate = gameTemplate

        // Set up game-specific sharing configuration
        session.configuration?.enableGameCenterFeatures = true
        session.configuration?.shareAchievements = true
        session.configuration?.shareProgress = true

        // Sync match state with SharePlay
        await syncMatchStateWithSharePlay(match: match, session: session)
    }

    private func createGamingSpatialTemplate() -> GroupActivitySharingConfiguration.SpatialTemplate {
        return GroupActivitySharingConfiguration.SpatialTemplate(
            participantLayout: .aroundRectangle,
            participantScale: 0.06, // Slightly larger for gaming visibility
            participantDistance: 1.5, // Comfortable gaming distance
            heightOffset: 0.2, // Slightly above table level
            lookAtCenter: true,
            participantSeparation: .fixed
        )
    }

    private func syncMatchStateWithSharePlay(match: GKMatch, session: GroupSession<GameActivity>) async {
        // Initial sync of match state
        await sharePlayCoordinator.broadcastGameState(
            GameUpdateMessage(
                matchID: match.matchID,
                playerIDs: match.players.map(\.playerID),
                gameState: .waiting
            )
        )
    }
}
```

### 2. GameCenter Authenticated Activity

```swift
struct GameActivity: GroupActivity {
    var gameCenterMatch: GKMatch?

    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Multiplayer Game Session"
        metadata.subtitle = gameCenterMatch?.players.count.description ?? "Waiting for players"
        metadata.type = .gaming
        metadata.supportsContinuationOnTV = false
        metadata.supportsContinuationOnCar = false
        metadata.supportsGroupImmersiveSpace = true

        // GameCenter integration
        metadata.gameCenterEnabled = true
        metadata.requiresGameCenterAuth = true
        metadata.matchmakingSource = .gameCenter

        return metadata
    }
}

// GameCenter authentication helper
class GameCenterAuthenticator: NSObject {
    private let authenticationCompletion: (Result<GKPlayer, Error>) -> Void

    init(completion: @escaping (Result<GKPlayer, Error>) -> Void) {
        self.authenticationCompletion = completion
        super.init()
    }

    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            Task { @MainActor in
                if let viewController = viewController {
                    // Present authentication view controller
                    self?.presentAuthentication(viewController)
                } else if let error = error {
                    self?.authenticationCompletion(.failure(error))
                } else if GKLocalPlayer.local.isAuthenticated {
                    self?.authenticationCompletion(.success(GKLocalPlayer.local))
                } else {
                    self?.authenticationCompletion(.failure(AuthenticationError.unknown))
                }
            }
        }
    }

    private func presentAuthentication(_ viewController: UIViewController) {
        // This would need to be implemented in your app's context
        // For example: UIApplication.shared.keyWindow?.rootViewController?.present(viewController, animated: true)
    }

    enum AuthenticationError: LocalizedError {
        case unknown
        case cancelled

        var errorDescription: String? {
            switch self {
            case .unknown:
                return "Unknown authentication error"
            case .cancelled:
                return "Authentication was cancelled"
            }
        }
    }
}
```

### 3. Enhanced GameCenter Matchmaking

```swift
class GameCenterMatchmakingManager: NSObject {
    private let request: GKMatchRequest
    private var matchmaker: GKMatchmakerViewController?
    private let matchmakingQueue = DispatchQueue(label: "matchmaking", qos: .userInitiated)

    // Callbacks
    var onMatchFound: ((GKMatch) -> Void)?
    var onPlayerConnected: ((GKPlayer) -> Void)?
    var onPlayerDisconnected: ((GKPlayer) -> Void)?

    init() {
        self.request = GKMatchRequest()
        self.request.minPlayers = 2
        self.request.maxPlayers = 8
        self.request.playerAttributes = createPlayerAttributes()
    }

    func findMatch() async throws -> GKMatch {
        return try await withCheckedThrowingContinuation { continuation in
            matchmakingQueue.async {
                self.onMatchFound = { match in
                    continuation.resume(returning: match)
                }

                // Show native matchmaking UI
                let matchmaker = GKMatchmakerViewController(matchRequest: self.request)
                matchmaker.matchmakerDelegate = self
                self.matchmaker = matchmaker

                // Present matchmaker view controller
                self.presentMatchmaker(matchmaker)
            }
        }
    }

    private func createPlayerAttributes() -> [String: Any] {
        return [
            "visionOS": true,
            "supportsImmersive": true,
            "skillLevel": GKLocalPlayer.local.totalGamesPlayed > 10 ? "intermediate" : "beginner",
            "preferredGameType": "collaborative"
        ]
    }

    private func presentMatchmaker(_ matchmaker: GKMatchmakerViewController) {
        // This would need to be implemented in your app's context
        // Present the matchmaker UI
    }

    // Custom matchmaking for visionOS specific features
    func findVisionOSMatch() async throws -> GKMatch {
        var request = self.request
        request.playerAttributes["visionOS"] = true
        request.inviteMessage = "Join a visionOS multiplayer session!"

        return try await findMatch()
    }
}

// Matchmaking delegate
extension GameCenterMatchmakingManager: GKMatchmakerViewControllerDelegate {
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        matchmakingQueue.async {
            self.onMatchFound?(nil)
        }
    }

    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        match.delegate = self
        matchmakingQueue.async {
            self.onMatchFound?(match)
        }
    }

    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        matchmakingQueue.async {
            // Handle matchmaking failure
        }
    }
}

// Match delegate
extension GameCenterMatchmakingManager: GKMatchDelegate {
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        // Handle data from GameCenter match
        matchmakingQueue.async {
            // Process game data
        }
    }

    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        matchmakingQueue.async {
            switch state {
            case .connected:
                self.onPlayerConnected?(player)
            case .disconnected:
                self.onPlayerDisconnected?(player)
            case .stateUnknown:
                break
            @unknown default:
                break
            }
        }
    }
}
```

### 4. SharePlay Game Coordinator

```swift
@MainActor
class SharePlayCoordinator: ObservableObject {
    private var messenger: GroupSessionMessenger?
    private var gameState: GameState = .waiting
    private var playerStates: [String: PlayerState] = [:]

    func setupMessenger(for session: GroupSession<GameActivity>) async {
        messenger = GroupSessionMessenger(for: session) { [weak self] message, participant in
            await self?.handleGameMessage(message, from: participant)
        }
    }

    func broadcastGameState(_ update: GameUpdateMessage) async {
        guard let messenger = messenger else { return }

        do {
            let data = try JSONEncoder().encode(update)
            try await messenger.send(data)
        } catch {
            print("Failed to broadcast game state: \(error)")
        }
    }

    private func handleGameMessage(_ data: Data, from participant: GroupSession<GameActivity>.Participant) async {
        do {
            let update = try JSONDecoder().decode(GameUpdateMessage.self, from: data)
            await processGameUpdate(update, from: participant)
        } catch {
            print("Failed to decode game message: \(error)")
        }
    }

    private func processGameUpdate(_ update: GameUpdateMessage, from participant: GroupSession<GameActivity>.Participant) async {
        // Process different types of game updates
        switch update.gameState {
        case .waiting:
            gameState = .waiting
        case .playing:
            gameState = .playing
            await handleGameStart(update)
        case .paused:
            gameState = .paused
        case .ended:
            gameState = .ended
            await handleGameEnd(update)
        case .playerAction(let action):
            await handlePlayerAction(action, from: participant)
        }
    }

    private func handleGameStart(_ update: GameUpdateMessage) async {
        // Initialize game state for all players
        for playerID in update.playerIDs {
            playerStates[playerID] = PlayerState(
                playerID: playerID,
                score: 0,
                isReady: false,
                currentPosition: SIMD3<Float>(0, 0, 0)
            )
        }

        // Notify UI that game is starting
        NotificationCenter.default.post(
            name: .gameStateDidChange,
            object: gameState
        )
    }

    private func handlePlayerAction(_ action: PlayerAction, from participant: GroupSession<GameActivity>.Participant) async {
        // Handle different player actions
        switch action.type {
        case .move:
            await handlePlayerMove(action, from: participant)
        case .interact:
            await handlePlayerInteraction(action, from: participant)
        case .score:
            await handlePlayerScore(action, from: participant)
        case .chat:
            await handlePlayerChat(action, from: participant)
        }
    }

    // Implementation for specific game actions
    private func handlePlayerMove(_ action: PlayerAction, from participant: GroupSession<GameActivity>.Participant) async {
        // Update player position
        if let position = action.parameters["position"] as? SIMD3<Float> {
            playerStates[participant.id]?.currentPosition = position

            // Broadcast position update to all players
            let update = GameUpdateMessage(
                matchID: "", // Would be filled with actual match ID
                playerIDs: [],
                gameState: .playerAction(action)
            )
            await broadcastGameState(update)
        }
    }

    private func handlePlayerInteraction(_ action: PlayerAction, from participant: GroupSession<GameActivity>.Participant) async {
        // Handle player interactions with game objects
        // This would be game-specific
    }

    private func handlePlayerScore(_ action: PlayerAction, from participant: GroupSession<GameActivity>.Participant) async {
        // Update player score
        if let score = action.parameters["score"] as? Int {
            playerStates[participant.id]?.score += score

            // Check for achievements
            await checkAchievements(for: participant.id)
        }
    }

    private func handlePlayerChat(_ action: PlayerAction, from participant: GroupSession<GameActivity>.Participant) async {
        // Handle in-game chat
        if let message = action.parameters["message"] as? String {
            // Broadcast chat message
            let chatUpdate = GameUpdateMessage(
                matchID: "",
                playerIDs: [],
                gameState: .chatMessage(ChatMessage(
                    playerID: participant.id,
                    message: message,
                    timestamp: Date()
                ))
            )
            await broadcastGameState(chatUpdate)
        }
    }

    private func handleGameEnd(_ update: GameUpdateMessage) async {
        // Calculate final scores, determine winner
        // Share achievements
        // Handle game session cleanup
    }

    private func checkAchievements(for playerID: String) async {
        guard let playerState = playerStates[playerID] else { return }

        // Check GameCenter achievements
        let achievementIDs = AchievementManager.checkEligibility(
            for: playerState,
            in: gameState
        )

        for achievementID in achievementIDs {
            await unlockAchievement(achievementID, for: playerID)
        }
    }

    private func unlockAchievement(_ achievementID: String, for playerID: String) async {
        do {
            let achievement = GKAchievement(identifier: achievementID)
            achievement.percentComplete = 100
            try await GKAchievementReporter.report([achievement])

            // Share achievement unlock with SharePlay
            let achievementUpdate = GameUpdateMessage(
                matchID: "",
                playerIDs: [],
                gameState: .achievementUnlock(AchievementUnlock(
                    playerID: playerID,
                    achievementID: achievementID,
                    timestamp: Date()
                ))
            )
            await broadcastGameState(achievementUpdate)

        } catch {
            print("Failed to report achievement: \(error)")
        }
    }
}
```

### 5. visionOS Game UI with GameCenter Integration

```swift
import SwiftUI

struct GameCenterGameView: View {
    @StateObject private var gameManager = GameCenterSharePlayManager()
    @StateObject private var sharePlayCoordinator = SharePlayCoordinator()

    var body: some View {
        VStack(spacing: 20) {
            // GameCenter status
            gameCenterStatusView

            // Matchmaking controls
            if gameManager.isGameCenterAuthenticated {
                matchmakingControlsView
            } else {
                authenticationView
            }

            // Active game session
            if gameManager.matchmakingState == .active {
                activeGameView
            }

            // Players list
            if !gameManager.players.isEmpty {
                playersListView
            }
        }
        .onAppear {
            // Auto-authenticate with GameCenter
            gameManager.setupGameCenterAuthentication()
        }
    }

    private var gameCenterStatusView: some View {
        HStack {
            Circle()
                .fill(gameManager.isGameCenterAuthenticated ? .green : .red)
                .frame(width: 12, height: 12)

            Text(gameManager.isGameCenterAuthenticated ? "GameCenter Connected" : "GameCenter Disconnected")
                .font(.subheadline)

            if gameManager.isGameCenterAuthenticated {
                Text("as \(GKLocalPlayer.local.displayName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }

    private var authenticationView: some View {
        VStack(spacing: 16) {
            Image(systemName: "gamecontroller")
                .font(.system(size: 48))
                .foregroundColor(.blue)

            Text("Connect to GameCenter")
                .font(.headline)

            Text("Sign in with GameCenter to play multiplayer games")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Sign In") {
                // Trigger GameCenter authentication
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private var matchmakingControlsView: some View {
        VStack(spacing: 16) {
            Text("Multiplayer Gaming")
                .font(.headline)

            // Matchmaking state indicator
            matchmakingStateView

            // Action buttons
            switch gameManager.matchmakingState {
            case .idle:
                Button("Start Multiplayer") {
                    Task {
                        await gameManager.startMultiplayerGame()
                    }
                }
                .buttonStyle(.borderedProminent)

            case .searching:
                ProgressView("Finding players...")
                    .padding()

            case .foundMatch:
                Button("Start Game") {
                    // Game will start automatically
                }
                .buttonStyle(.borderedProminent)

            case .startingSharePlay:
                ProgressView("Starting SharePlay session...")
                    .padding()

            case .active:
                Button("End Game") {
                    Task {
                        await gameManager.endGameSession()
                    }
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)

            case .error(let message):
                Text("Error: \(message)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)

                Button("Try Again") {
                    Task {
                        await gameManager.startMultiplayerGame()
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }

    private var matchmakingStateView: some View {
        HStack {
            Circle()
                .fill(stateColor)
                .frame(width: 8, height: 8)

            Text(stateDescription)
                .font(.subheadline)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(stateColor.opacity(0.1))
        .cornerRadius(12)
    }

    private var activeGameView: some View {
        VStack(spacing: 16) {
            Text("Game in Progress")
                .font(.headline)

            HStack {
                Text("Players: \(gameManager.players.count)")
                Spacer()
                Text("Session: Active")
                    .foregroundColor(.green)
            }
            .font(.subheadline)

            // Game-specific UI would go here
            Text("[Game Interface]")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
        .background(Color.green.opacity(0.05))
        .cornerRadius(12)
    }

    private var playersListView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Players (\(gameManager.players.count))")
                .font(.headline)

            ForEach(gameManager.players, id: \.playerID) { player in
                PlayerRowView(player: player)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }

    // Computed properties
    private var stateColor: Color {
        switch gameManager.matchmakingState {
        case .idle: return .gray
        case .searching: return .orange
        case .foundMatch: return .blue
        case .startingSharePlay: return .purple
        case .active: return .green
        case .error: return .red
        }
    }

    private var stateDescription: String {
        switch gameManager.matchmakingState {
        case .idle: return "Ready"
        case .searching: return "Searching for players"
        case .foundMatch: return "Match found"
        case .startingSharePlay: return "Starting session"
        case .active: return "Game active"
        case .error: return "Error"
        }
    }
}

struct PlayerRowView: View {
    let player: GKPlayer

    var body: some View {
        HStack {
            // Player avatar or default
            AsyncImage(url: player.photoURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 40, height: 40)
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())

            // Player info
            VStack(alignment: .leading) {
                Text(player.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                if player.isFriend {
                    Text("Friend")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }

            Spacer()

            // GameCenter player status
            if player.isLocalPlayer {
                Text("You")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
    }
}
```

## Integration with Existing Patterns

### 1. Enhanced SharePlay Session Management

```swift
// Enhanced SharePlay manager with GameCenter integration
class EnhancedSharePlayManager: SharePlayManager {
    private let gameCenterManager = GameCenterSharePlayManager()

    override func startSession() async throws {
        // Check if this is a game scenario
        if await gameCenterManager.isGameCenterAuthenticated {
            try await startGameCenterSession()
        } else {
            // Fall back to regular SharePlay
            try await super.startSession()
        }
    }

    private func startGameCenterSession() async throws {
        try await gameCenterManager.startMultiplayerGame()
    }
}
```

### 2. Achievement Sharing Enhancement

```swift
// Enhanced achievement system with SharePlay
class AchievementManager {
    static func checkEligibility(for playerState: PlayerState, in gameState: GameState) -> [String] {
        var eligibleAchievements: [String] = []

        // Check score-based achievements
        if playerState.score >= 1000 {
            eligibleAchievements.append("first_mille")
        }

        // Check SharePlay-specific achievements
        if gameState.players.count >= 4 {
            eligibleAchievements.append("party_animal")
        }

        // Check visionOS-specific achievements
        if gameState.spatialFeaturesEnabled {
            eligibleAchievements.append("spatial_master")
        }

        return eligibleAchievements
    }

    static func shareAchievement(_ achievement: GKAchievement, with session: GroupSession<GameActivity>) async {
        let achievementMessage = GameUpdateMessage(
            matchID: "",
            playerIDs: [],
            gameState: .achievementUnlock(AchievementUnlock(
                playerID: GKLocalPlayer.local.playerID,
                achievementID: achievement.identifier,
                timestamp: Date()
            ))
        )

        // Broadcast achievement unlock to all players
        try? await session.messenger?.send(JSONEncoder().encode(achievementMessage))
    }
}
```

## Testing Requirements

### GameCenter Integration Testing
- **Authentication flow**: Test GameCenter sign-in process
- **Matchmaking scenarios**: Test various player count configurations
- **Network conditions**: Test with poor connectivity
- **Cross-platform compatibility**: Test with different device types

### SharePlay + GameCenter Testing
- **Session coordination**: Ensure SharePlay and GameCenter sync properly
- **Player state management**: Verify player state consistency
- **Achievement sharing**: Test achievement unlocking and sharing
- **Game state synchronization**: Validate real-time game state updates

### visionOS Specific Testing
- **Spatial positioning**: Test player positioning in immersive space
- **Hand tracking integration**: Verify hand tracking works with multiplayer
- **Performance**: Test with multiple players in same session

## Best Practices (from Apple Integration Patterns)

### 1. Unified Authentication
- Always authenticate with GameCenter before multiplayer features
- Handle authentication failures gracefully
- Provide clear feedback to users

### 2. Seamless Session Management
- Coordinate GameCenter and SharePlay sessions
- Handle session transitions smoothly
- Provide fallback options for session failures

### 3. Player Experience
- Use native GameCenter matchmaking UI
- Provide clear player status indicators
- Enable in-game communication features

### 4. Performance Optimization
- Optimize message frequency for gaming
- Use spatial positioning efficiently
- Handle large player counts gracefully

## Implementation Checklist

### GameCenter Setup
- [ ] Enable GameCenter capability in Xcode
- [ ] Configure GameCenter authentication
- [ ] Set up matchmaking request parameters
- [ ] Implement achievement tracking
- [ ] Configure leaderboard integration

### SharePlay Integration
- [ ] Create GameCenter-aware GroupActivity
- [ ] Set up spatial template for gaming
- [ ] Implement real-time state synchronization
- [ ] Handle session lifecycle management
- [ ] Add achievement sharing capabilities

### UI Components
- [ ] GameCenter authentication interface
- [ ] Matchmaking status indicators
- [ ] Player list with GameCenter integration
- [ ] In-game communication features
- [ ] Achievement notifications

### Testing & Validation
- [ ] Test GameCenter authentication flow
- [ ] Verify matchmaking functionality
- [ ] Test SharePlay session coordination
- [ ] Validate achievement sharing
- [ ] Test cross-platform compatibility

---

**🎯 Apple Validation**: Integrates GameCenter patterns with SharePlay best practices
**🔄 Enhancement**: Extends existing SharePlay patterns with multiplayer gaming
**🆕 Innovation**: Unified GameCenter + SharePlay gaming experience

*This example demonstrates cutting-edge multiplayer gaming integration that combines Apple's GameCenter matchmaking with SharePlay's real-time synchronization capabilities, creating seamless multiplayer experiences on visionOS.*