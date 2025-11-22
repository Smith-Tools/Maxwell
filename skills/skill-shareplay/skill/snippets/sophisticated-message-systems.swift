// Sophisticated Message Systems for SharePlay
// Advanced patterns for complex message hierarchies, routing, and state synchronization

import Foundation
import GroupActivities
import SwiftData

// MARK: - 1. Advanced Message Architecture

/// Core message protocol for type safety and serialization
protocol SharePlayMessage: Codable, Sendable {
    var id: UUID { get }
    var timestamp: Date { get }
    var senderID: UUID { get }
    var priority: MessagePriority { get }
    var type: MessageType { get }
}

enum MessagePriority: Int, Codable, CaseIterable {
    case critical = 0    // System state changes, errors
    case high = 1        // Game state updates, player actions
    case normal = 2      // Chat, UI updates
    case low = 3         // Analytics, telemetry

    var deliveryGuarantee: DeliveryGuarantee {
        switch self {
        case .critical, .high:
            return .guaranteed
        case .normal, .low:
            return .bestEffort
        }
    }
}

enum DeliveryGuarantee: String, Codable {
    case guaranteed     // Must be delivered, retry until successful
    case bestEffort     // Try once, drop if failed
    case ordered        // Must be delivered in order
    case unordered      // Order doesn't matter
}

enum MessageType: String, Codable {
    case systemState
    case gameState
    case playerAction
    case chat
    case uiState
    case analytics
    case custom(String)
}

// MARK: - 2. Message Definitions

/// System state messages - critical priority
struct SystemStateMessage: SharePlayMessage {
    let id = UUID()
    let timestamp: Date
    let senderID: UUID
    let priority = MessagePriority.critical
    let type = MessageType.systemState

    let systemEvent: SystemEvent
    let sessionState: SessionState

    enum SystemEvent: String, Codable {
        case sessionStarted
        case sessionEnded
        case participantJoined
        case participantLeft
        case hostChanged
        case errorOccurred
    }

    enum SessionState: String, Codable {
        case waiting
        case active
        case paused
        case ended
        case error
    }
}

/// Game state messages - high priority
struct GameStateMessage: SharePlayMessage {
    let id = UUID()
    let timestamp: Date
    let senderID: UUID
    let priority = MessagePriority.high
    let type = MessageType.gameState

    let gameEvent: GameEvent
    let gameState: EncodedGameState
    let version: Int
    let checksum: String

    enum GameEvent: String, Codable {
        case stateChanged
        case turnStarted
        case turnEnded
        case roundCompleted
        case gameWon
        case gameLost
        case levelChanged
    }
}

struct EncodedGameState: Codable {
    let data: Data
    let encoding: StateEncoding
    let compression: CompressionType?

    enum StateEncoding: String, Codable {
        case json
        case protobuf
        case binary
        case custom(String)
    }

    enum CompressionType: String, Codable {
        case gzip
        case lz4
        case none
    }
}

/// Player action messages - high priority
struct PlayerActionMessage: SharePlayMessage {
    let id = UUID()
    let timestamp: Date
    let senderID: UUID
    let priority = MessagePriority.high
    let type = MessageType.playerAction

    let action: PlayerAction
    let target: ActionTarget
    let parameters: [String: EncodableValue]
    let sequenceNumber: Int

    enum PlayerAction: String, Codable {
        case move
        case interact
        case attack
        case defend
        case useItem
        case castSpell
        case build
        case destroy
        case claim
        case release
    }

    enum ActionTarget: Codable {
        case position(SIMD3<Float>)
        case object(UUID)
        case player(UUID)
        case area(Rect3D)
        case global
    }
}

struct Rect3D: Codable {
    let origin: SIMD3<Float>
    let size: SIMD3<Float>
}

/// Chat messages - normal priority
struct ChatMessage: SharePlayMessage {
    let id = UUID()
    let timestamp: Date
    let senderID: UUID
    let priority = MessagePriority.normal
    let type = MessageType.chat

    let content: String
    let messageType: ChatType
    let target: ChatTarget

    enum ChatType: String, Codable {
        case text
        case emoji
        case reaction
        case system
        private case custom(String)
    }

    enum ChatTarget: Codable {
        case all
        case team(String)
        case player(UUID)
        case spectator
    }
}

/// UI state messages - normal priority
struct UIStateMessage: SharePlayMessage {
    let id = UUID()
    let timestamp: Date
    let senderID: UUID
    let priority = MessagePriority.normal
    let type = MessageType.uiState

    let uiEvent: UIEvent
    let componentID: String?
    let state: UIState

    enum UIEvent: String, Codable {
        case menuOpened
        case menuClosed
        case buttonPressed
        case sliderChanged
        case selectionChanged
        case focusChanged
        case modalShown
        case modalHidden
    }

    enum UIState: Codable {
        case boolean(Bool)
        case integer(Int)
        case float(Float)
        case string(String)
        case array([EncodableValue])
        case dictionary([String: EncodableValue])
    }
}

// MARK: - 3. Message Router and Dispatcher

/// Advanced message router with priority handling and routing logic
@MainActor
class MessageRouter: ObservableObject {
    @Published var messageQueue: [QueuedMessage] = []
    @Published var processingStatistics = ProcessingStatistics()

    private var messageHandlers: [MessageType: [MessageHandler]] = [:]
    private var messageBuffer: [UUID: [SharePlayMessage]] = [:] // For ordered delivery
    private var sequenceTrackers: [UUID: Int] = [:]
    private var processingTask: Task<Void, Never>?
    private let maxQueueSize = 1000
    private let batchSize = 10

    struct ProcessingStatistics {
        var messagesProcessed = 0
        var messagesDropped = 0
        var averageProcessingTime: TimeInterval = 0
        var queueDepth = 0
        var errorsEncountered = 0
    }

    struct QueuedMessage {
        let message: SharePlayMessage
        let receivedTime: Date
        let retryCount: Int
        let deliveryGuarantee: DeliveryGuarantee
    }

    func registerHandler(_ handler: MessageHandler, for messageType: MessageType) {
        messageHandlers[messageType, default: []].append(handler)
    }

    func routeMessage(_ message: SharePlayMessage, from participant: UUID) {
        let queuedMessage = QueuedMessage(
            message: message,
            receivedTime: Date(),
            retryCount: 0,
            deliveryGuarantee: message.priority.deliveryGuarantee
        )

        // Handle message based on priority and delivery guarantee
        switch message.priority.deliveryGuarantee {
        case .guaranteed:
            handleGuaranteedMessage(queuedMessage, from: participant)
        case .bestEffort:
            handleBestEffortMessage(queuedMessage, from: participant)
        case .ordered:
            handleOrderedMessage(queuedMessage, from: participant)
        case .unordered:
            handleUnorderedMessage(queuedMessage, from: participant)
        }

        updateStatistics()
    }

    private func handleGuaranteedMessage(_ message: QueuedMessage, from participant: UUID) {
        // Add to queue for guaranteed delivery
        if messageQueue.count < maxQueueSize {
            messageQueue.append(message)
        } else {
            // Remove oldest low-priority message to make room
            if let oldestIndex = messageQueue.firstIndex(where: { $0.message.priority == .low }) {
                messageQueue.remove(at: oldestIndex)
                messageQueue.append(message)
                processingStatistics.messagesDropped += 1
            }
        }

        startProcessingIfNeeded()
    }

    private func handleBestEffortMessage(_ message: QueuedMessage, from participant: UUID) {
        // Try to deliver immediately, drop if queue is full
        if messageQueue.count < maxQueueSize {
            messageQueue.append(message)
            startProcessingIfNeeded()
        } else {
            processingStatistics.messagesDropped += 1
        }
    }

    private func handleOrderedMessage(_ message: QueuedMessage, from participant: UUID) {
        // Buffer messages for ordered delivery
        let buffer = messageBuffer[participant, default: []]

        // Check if this is the next expected message
        let expectedSequence = sequenceTrackers[participant, default: 0]

        if let actionMessage = message.message as? PlayerActionMessage,
           actionMessage.sequenceNumber == expectedSequence {
            // This is the next expected message, deliver it
            messageQueue.append(message)
            sequenceTrackers[participant] = expectedSequence + 1

            // Check if we can deliver any buffered messages
            deliverBufferedMessages(for: participant)
        } else {
            // Buffer this message for later delivery
            messageBuffer[participant, default: []].append(message.message)
        }

        startProcessingIfNeeded()
    }

    private func handleUnorderedMessage(_ message: QueuedMessage, from participant: UUID) {
        // Add to queue immediately
        messageQueue.append(message)
        startProcessingIfNeeded()
    }

    private func deliverBufferedMessages(for participant: UUID) {
        guard var buffer = messageBuffer[participant] else { return }

        let expectedSequence = sequenceTrackers[participant, default: 0]

        // Find messages that can be delivered now
        let deliverableMessages = buffer.filter { message in
            guard let actionMessage = message as? PlayerActionMessage else { return true }
            return actionMessage.sequenceNumber <= expectedSequence
        }

        // Queue deliverable messages
        for message in deliverableMessages {
            let queuedMessage = QueuedMessage(
                message: message,
                receivedTime: Date(),
                retryCount: 0,
                deliveryGuarantee: .ordered
            )
            messageQueue.append(queuedMessage)
        }

        // Remove delivered messages from buffer
        buffer.removeAll { message in
            deliverableMessages.contains(message)
        }
        messageBuffer[participant] = buffer
    }

    private func startProcessingIfNeeded() {
        guard processingTask == nil, !messageQueue.isEmpty else { return }

        processingTask = Task { @MainActor in
            await processMessageQueue()
        }
    }

    private func processMessageQueue() async {
        while !messageQueue.isEmpty && !Task.isCancelled {
            // Sort by priority and timestamp
            messageQueue.sort { lhs, rhs in
                if lhs.message.priority.rawValue != rhs.message.priority.rawValue {
                    return lhs.message.priority.rawValue < rhs.message.priority.rawValue
                }
                return lhs.receivedTime < rhs.receivedTime
            }

            // Process batch of messages
            let batch = Array(messageQueue.prefix(batchSize))
            messageQueue.removeFirst(min(batchSize, messageQueue.count))

            await withTaskGroup(of: Void.self) { group in
                for queuedMessage in batch {
                    group.addTask { [weak self] in
                        await self?.processMessage(queuedMessage)
                    }
                }
            }

            // Small delay to prevent overwhelming the system
            try? await Task.sleep(for: .milliseconds(10))
        }

        processingTask = nil
    }

    private func processMessage(_ queuedMessage: QueuedMessage) async {
        let startTime = Date()

        do {
            // Find handlers for this message type
            guard let handlers = messageHandlers[queuedMessage.message.type] else {
                print("No handlers registered for message type: \(queuedMessage.message.type)")
                return
            }

            // Deliver to all handlers
            for handler in handlers {
                try await handler.handle(queuedMessage.message)
            }

            // Update statistics
            let processingTime = Date().timeIntervalSince(startTime)
            updateProcessingStatistics(processingTime)

        } catch {
            print("Error processing message: \(error)")
            processingStatistics.errorsEncountered += 1

            // Retry for guaranteed messages
            if queuedMessage.deliveryGuarantee == .guaranteed {
                await retryMessage(queuedMessage)
            }
        }
    }

    private func retryMessage(_ queuedMessage: QueuedMessage) async {
        let retryMessage = QueuedMessage(
            message: queuedMessage.message,
            receivedTime: queuedMessage.receivedTime,
            retryCount: queuedMessage.retryCount + 1,
            deliveryGuarantee: queuedMessage.deliveryGuarantee
        )

        // Exponential backoff
        let delay = min(pow(2.0, Double(retryMessage.retryCount)), 30.0)
        try? await Task.sleep(for: .seconds(delay))

        if retryMessage.retryCount < 5 {
            messageQueue.append(retryMessage)
        } else {
            processingStatistics.messagesDropped += 1
        }
    }

    private func updateProcessingStatistics(_ processingTime: TimeInterval) {
        processingStatistics.messagesProcessed += 1

        // Update average processing time
        let totalMessages = processingStatistics.messagesProcessed
        processingStatistics.averageProcessingTime =
            (processingStatistics.averageProcessingTime * Double(totalMessages - 1) + processingTime) / Double(totalMessages)
    }

    private func updateStatistics() {
        processingStatistics.queueDepth = messageQueue.count
    }
}

// MARK: - 4. Message Handler Protocol

protocol MessageHandler: Sendable {
    func handle(_ message: SharePlayMessage) async throws
}

// MARK: - 5. Specialized Message Handlers

/// Game state handler
class GameStateHandler: MessageHandler {
    private let gameStateManager: GameStateManager

    init(gameStateManager: GameStateManager) {
        self.gameStateManager = gameStateManager
    }

    func handle(_ message: SharePlayMessage) async throws {
        guard let gameStateMessage = message as? GameStateMessage else { return }

        // Verify game state integrity
        guard gameStateMessage.checksum == calculateChecksum(for: gameStateMessage.gameState) else {
            throw MessageError.invalidChecksum
        }

        // Apply game state update
        try await gameStateManager.applyStateUpdate(
            gameStateMessage.gameState,
            version: gameStateMessage.version,
            from: message.senderID
        )
    }

    private func calculateChecksum(for state: EncodedGameState) -> String {
        // Simple checksum implementation
        return String(state.data.hashValue)
    }
}

/// Player action handler
class PlayerActionHandler: MessageHandler {
    private let actionCoordinator: ActionCoordinator
    private let playerManager: PlayerManager

    init(actionCoordinator: ActionCoordinator, playerManager: PlayerManager) {
        self.actionCoordinator = actionCoordinator
        self.playerManager = playerManager
    }

    func handle(_ message: SharePlayMessage) async throws {
        guard let actionMessage = message as? PlayerActionMessage else { return }

        // Validate action
        try await validateAction(actionMessage)

        // Execute action
        try await actionCoordinator.executeAction(
            actionMessage.action,
            target: actionMessage.target,
            parameters: actionMessage.parameters,
            by: message.senderID
        )
    }

    private func validateAction(_ message: PlayerActionMessage) async throws {
        // Check if player is allowed to perform this action
        guard try await playerManager.canPerformAction(
            message.action,
            playerID: message.senderID
        ) else {
            throw MessageError.unauthorizedAction
        }
    }
}

/// Chat handler
class ChatHandler: MessageHandler {
    private let chatManager: ChatManager
    private let moderationService: ModerationService

    init(chatManager: ChatManager, moderationService: ModerationService) {
        self.chatManager = chatManager
        self.moderationService = moderationService
    }

    func handle(_ message: SharePlayMessage) async throws {
        guard let chatMessage = message as? ChatMessage else { return }

        // Moderate content if needed
        if try await moderationService.requiresModeration(chatMessage.content) {
            let moderatedContent = try await moderationService.moderate(chatMessage.content)
            try await chatManager.deliverMessage(
                content: moderatedContent,
                type: chatMessage.messageType,
                target: chatMessage.target,
                from: message.senderID
            )
        } else {
            try await chatManager.deliverMessage(
                content: chatMessage.content,
                type: chatMessage.messageType,
                target: chatMessage.target,
                from: message.senderID
            )
        }
    }
}

// MARK: - 6. Message Encoding and Compression

/// Advanced message encoder with compression support
struct MessageEncoder {
    private let compressionEnabled: Bool
    private let compressionLevel: Int

    init(compressionEnabled: Bool = true, compressionLevel: Int = 6) {
        self.compressionEnabled = compressionEnabled
        self.compressionLevel = compressionLevel
    }

    func encode(_ message: SharePlayMessage) throws -> Data {
        let jsonData = try JSONEncoder().encode(message)

        guard compressionEnabled else { return jsonData }

        return try compress(jsonData)
    }

    func decode<T: SharePlayMessage>(_ data: Data, as type: T.Type) throws -> T {
        let decompressedData = try decompress(data)
        return try JSONDecoder().decode(type, from: decompressedData)
    }

    private func compress(_ data: Data) throws -> Data {
        // Use standard compression for data > 1KB
        guard data.count > 1024 else { return data }

        return try data.withUnsafeBytes { rawBufferPointer in
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
            defer { buffer.deallocate() }

            let compressedSize = compression_encode_buffer(
                buffer,
                data.count,
                rawBufferPointer.bindMemory(to: UInt8.self),
                data.count,
                nil,
                COMPRESSION_ZLIB
            )

            guard compressedSize > 0 else {
                throw CompressionError.encodingFailed
            }

            return Data(bytes: buffer, count: compressedSize)
        }
    }

    private func decompress(_ data: Data) throws -> Data {
        // Try decompression, return original if fails
        guard !data.isEmpty else { return data }

        return try data.withUnsafeBytes { rawBufferPointer in
            // Estimate decompressed size (start with 10x original)
            let estimatedSize = data.count * 10
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: estimatedSize)
            defer { buffer.deallocate() }

            let decompressedSize = compression_decode_buffer(
                buffer,
                estimatedSize,
                rawBufferPointer.bindMemory(to: UInt8.self),
                data.count,
                nil,
                COMPRESSION_ZLIB
            )

            guard decompressedSize > 0 else {
                throw CompressionError.decodingFailed
            }

            return Data(bytes: buffer, count: decompressedSize)
        }
    }
}

enum CompressionError: Error {
    case encodingFailed
    case decodingFailed
}
}

// MARK: - 7. Message Caching and Persistence

/// Message cache for offline scenarios and recovery
actor MessageCache {
    private var cache: [UUID: CachedMessage] = [:]
    private var persistentStorage: MessageStorage
    private let maxCacheSize = 10000
    private let cacheTimeout: TimeInterval = 3600 // 1 hour

    struct CachedMessage {
        let message: SharePlayMessage
        let timestamp: Date
        let deliveryStatus: DeliveryStatus

        enum DeliveryStatus {
            case pending
            case delivered
            case failed
            case expired
        }
    }

    init(persistentStorage: MessageStorage) {
        self.persistentStorage = persistentStorage
    }

    func store(_ message: SharePlayMessage, status: CachedMessage.DeliveryStatus = .pending) {
        cache[message.id] = CachedMessage(
            message: message,
            timestamp: Date(),
            deliveryStatus: status
        )

        // Persist critical messages
        if message.priority == .critical {
            Task {
                try? await persistentStorage.store(message)
            }
        }

        cleanupExpiredMessages()
    }

    func retrieve(_ messageID: UUID) -> CachedMessage? {
        return cache[messageID]
    }

    func getPendingMessages() -> [SharePlayMessage] {
        return cache.values
            .filter { $0.deliveryStatus == .pending }
            .map { $0.message }
    }

    func markDelivered(_ messageID: UUID) {
        cache[messageID]?.deliveryStatus = .delivered
    }

    func markFailed(_ messageID: UUID) {
        cache[messageID]?.deliveryStatus = .failed
    }

    private func cleanupExpiredMessages() {
        let cutoffDate = Date().addingTimeInterval(-cacheTimeout)

        cache = cache.filter { _, cachedMessage in
            cachedMessage.timestamp > cutoffDate ||
            cachedMessage.deliveryStatus == .pending
        }

        // Maintain cache size limit
        if cache.count > maxCacheSize {
            let sortedByTimestamp = cache.sorted { $0.value.timestamp < $1.value.timestamp }
            let toRemove = sortedByTimestamp.prefix(cache.count - maxCacheSize)

            for (id, _) in toRemove {
                cache.removeValue(forKey: id)
            }
        }
    }
}

// MARK: - 8. Error Types

enum MessageError: LocalizedError {
    case invalidChecksum
    case unauthorizedAction
    case messageTooLarge
    case encodingFailed
    case decodingFailed
    case deliveryFailed
    case handlerNotFound
    case bufferOverflow

    var errorDescription: String? {
        switch self {
        case .invalidChecksum:
            return "Message checksum validation failed"
        case .unauthorizedAction:
            return "Player not authorized to perform this action"
        case .messageTooLarge:
            return "Message size exceeds maximum limit"
        case .encodingFailed:
            return "Failed to encode message"
        case .decodingFailed:
            return "Failed to decode message"
        case .deliveryFailed:
            return "Failed to deliver message"
        case .handlerNotFound:
            return "No handler found for message type"
        case .bufferOverflow:
            return "Message buffer overflow"
        }
    }
}

// MARK: - 9. Supporting Protocols

protocol GameStateManager: Sendable {
    func applyStateUpdate(_ state: EncodedGameState, version: Int, from playerID: UUID) async throws
}

protocol ActionCoordinator: Sendable {
    func executeAction(_ action: PlayerActionMessage.PlayerAction, target: PlayerActionMessage.ActionTarget, parameters: [String: EncodableValue], by playerID: UUID) async throws
}

protocol PlayerManager: Sendable {
    func canPerformAction(_ action: PlayerActionMessage.PlayerAction, playerID: UUID) async throws -> Bool
}

protocol ChatManager: Sendable {
    func deliverMessage(content: String, type: ChatMessage.ChatType, target: ChatMessage.ChatTarget, from playerID: UUID) async throws
}

protocol ModerationService: Sendable {
    func requiresModeration(_ content: String) async throws -> Bool
    func moderate(_ content: String) async throws -> String
}

protocol MessageStorage: Sendable {
    func store(_ message: SharePlayMessage) async throws
    func retrieve(messageID: UUID) async throws -> SharePlayMessage?
    func cleanup() async throws
}

// MARK: - 10. Utility Types

enum EncodableValue: Codable {
    case string(String)
    case integer(Int)
    case float(Float)
    case boolean(Bool)
    case data(Data)
    case array([EncodableValue])
    case dictionary([String: EncodableValue])
    case null
}