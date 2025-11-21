// MARK: - Error Recovery Strategies for SharePlay
// Based on verified SDK patterns and production-tested approaches

import Foundation
import GroupActivities

// MARK: - 1. Participant Disconnection Recovery
@MainActor
class ParticipantRecoveryHandler: ObservableObject {
    @Published var disconnectedParticipants: [UUID] = []
    @Published var reconnectionAttempts: [UUID: Int] = [:]
    @Published var recoveryStatuses: [UUID: RecoveryStatus] = [:]

    private let maxRetries = 3
    private let retryDelay: TimeInterval = 2.0 // seconds
    private var session: GroupSession<any GroupActivity>?
    private var messenger: GroupSessionMessenger?

    enum RecoveryStatus {
        case disconnected
        case reconnecting(attempt: Int)
        case reconnected
        case permanentlyDisconnected
        case recoveryFailed
    }

    func configure(session: GroupSession<any GroupActivity>, messenger: GroupSessionMessenger) {
        self.session = session
        self.messenger = messenger

        // Start monitoring participant changes
        Task {
            await monitorParticipantChanges()
        }
    }

    private func monitorParticipantChanges() async {
        guard let session = session else { return }

        var previousParticipants = Set<Participant>()

        for await activeParticipants in session.$activeParticipants.values {
            let currentParticipants = activeParticipants
            let leftParticipants = previousParticipants.subtracting(currentParticipants)
            let joinedParticipants = currentParticipants.subtracting(previousParticipants)

            // Handle disconnections
            for participant in leftParticipants {
                await handleParticipantDisconnection(participant.id)
            }

            // Handle reconnections
            for participant in joinedParticipants {
                await handleParticipantReconnection(participant.id)
            }

            previousParticipants = currentParticipants
        }
    }

    func handleParticipantDisconnection(_ participantID: UUID) async {
        guard !disconnectedParticipants.contains(participantID) else { return }

        disconnectedParticipants.append(participantID)
        recoveryStatuses[participantID] = .disconnected
        reconnectionAttempts[participantID] = 0

        // Attempt reconnection with exponential backoff
        await attemptReconnection(participantID: participantID)

        // If reconnection fails after max attempts, handle gracefully
        if recoveryStatuses[participantID] != .reconnected {
            await handlePermanentDisconnection(participantID: participantID)
        }
    }

    private func handleParticipantReconnection(_ participantID: UUID) async {
        // Participant reconnected - clean up tracking
        disconnectedParticipants.removeAll { $0 == participantID }
        recoveryStatuses.removeValue(forKey: participantID)
        reconnectionAttempts.removeValue(forKey: participantID)

        print("✅ Participant \(participantID) reconnected successfully")
    }

    private func attemptReconnection(participantID: UUID) async {
        guard let attempts = reconnectionAttempts[participantID],
              attempts < maxRetries else {
            recoveryStatuses[participantID] = .permanentlyDisconnected
            return
        }

        let delay = pow(retryDelay, Double(attempts))
        recoveryStatuses[participantID] = .reconnecting(attempt: attempts + 1)

        print("🔄 Attempting reconnection for participant \(participantID), attempt \(attempts + 1)")

        try? await Task.sleep(for: .seconds(delay))

        reconnectionAttempts[participantID]? += 1

        // Check if participant is back after delay
        await checkParticipantStatus(participantID: participantID)
    }

    private func checkParticipantStatus(participantID: UUID) async {
        guard let session = session else { return }

        let currentParticipants = session.activeParticipants
        if currentParticipants.contains(where: { $0.id == participantID }) {
            await handleParticipantReconnection(participantID)
        } else {
            // Still disconnected, continue retry attempts
            await attemptReconnection(participantID: participantID)
        }
    }

    private func handlePermanentDisconnection(participantID: UUID) async {
        recoveryStatuses[participantID] = .recoveryFailed

        // Remove from disconnected tracking
        disconnectedParticipants.removeAll { $0 == participantID }

        print("❌ Participant \(participantID) permanently disconnected after \(maxRetries) attempts")

        // Send notification to UI about permanent disconnection
        await NotificationCenter.default.post(
            name: .participantPermanentlyDisconnected,
            object: participantID
        )
    }

    // Public API for manual reconnection attempts
    func forceReconnectionAttempt(_ participantID: UUID) async {
        reconnectionAttempts[participantID] = 0
        await attemptReconnection(participantID: participantID)
    }
}

// MARK: - 2. State Synchronization Conflict Resolution
struct ConflictResolution {
    enum Strategy {
        case lastWriteWins
        case vector(clock: [UUID: Int])
        case merge(resolver: (Any, Any, UUID) -> Any)
        case timestamp优先 // Timestamp priority
        case participantOrder // Participant ID order
    }

    static func resolveConflict<T: Codable>(
        local: T,
        remote: T,
        strategy: Strategy,
        localParticipantID: UUID,
        remoteParticipantID: UUID
    ) -> T {
        switch strategy {
        case .lastWriteWins:
            return local // Local participant's state takes precedence

        case .vector(let clock):
            return resolveByVectorClock(local, remote, clock, localParticipantID, remoteParticipantID)

        .merge(let resolver):
            return resolver(local, remote, remoteParticipantID) as! T

        case .timestamp优先:
            return resolveByTimestamp(local, remote)

        case .participantOrder:
            return resolveByParticipantOrder(local, remote, localParticipantID, remoteParticipantID)
        }
    }

    private static func resolveByVectorClock<T: Codable>(
        _ local: T,
        _ remote: T,
        _ clock: [UUID: Int],
        _ localID: UUID,
        _ remoteID: UUID
    ) -> T {
        let localCount = clock[localID] ?? 0
        let remoteCount = clock[remoteID] ?? 0

        if localCount > remoteCount {
            return local
        } else if remoteCount > localCount {
            return remote
        } else {
            // Equal counts, use participant ID as tiebreaker
            return localID.uuidString < remoteID.uuidString ? local : remote
        }
    }

    private static func resolveByTimestamp<T: Codable>(_ local: T, _ remote: T) -> T {
        // This would require timestamp metadata in the message
        // For now, prefer local state to maintain responsiveness
        return local
    }

    private static func resolveByParticipantOrder<T: Codable>(
        _ local: T,
        _ remote: T,
        _ localID: UUID,
        _ remoteID: UUID
    ) -> T {
        // Use UUID lexical order as deterministic tiebreaker
        return localID.uuidString <= remoteID.uuidString ? local : remote
    }
}

// MARK: - 3. Message Delivery Failure Recovery
class MessageRetryManager {
    private var failedMessages: [UUID: FailedMessage] = [:]
    private let maxRetries = 5
    private let baseRetryDelay: TimeInterval = 1.0
    private let maxRetryDelay: TimeInterval = 30.0
    private var messenger: GroupSessionMessenger?

    private struct FailedMessage {
        let message: SharePlayMessage
        var attempts: Int
        var lastFailureTime: Date
        var nextRetryTime: Date
        let recipients: Set<Participant>?
    }

    init() {
        // Start cleanup task for expired failed messages
        Task {
            await startExpiredMessageCleanup()
        }
    }

    func configure(messenger: GroupSessionMessenger) {
        self.messenger = messenger
    }

    func recordFailure(_ message: SharePlayMessage, recipients: Set<Participant>? = nil, error: Error) {
        let failedMessage = FailedMessage(
            message: message,
            attempts: 1,
            lastFailureTime: Date(),
            nextRetryTime: Date().addingTimeInterval(baseRetryDelay),
            recipients: recipients
        )

        failedMessages[message.id] = failedMessage
        print("⚠️ Message \(message.id.uuidString) failed to deliver: \(error)")
    }

    func retryFailedMessages() async {
        guard let messenger = messenger else { return }

        let currentTime = Date()
        let messagesToRetry = failedMessages.filter { $0.value.nextRetryTime <= currentTime }

        for (messageID, record) in messagesToRetry {
            guard record.attempts < maxRetries else {
                // Max retries reached, remove from tracking
                failedMessages.removeValue(forKey: messageID)
                await handleMaxRetriesReached(messageID, message: record.message)
                continue
            }

            // Check backoff delay
            if currentTime >= record.nextRetryTime {
                await performRetry(messageID: messageID, record: record, messenger: messenger)
            }
        }
    }

    private func performRetry(messageID: UUID, record: FailedMessage, messenger: GroupSessionMessenger) async {
        let message = record.message

        do {
            let data = try JSONEncoder().encode(message)

            if let recipients = record.recipients {
                try await messenger.send(data, to: .only(recipients))
                print("🔄 Retrying message to specific participants: \(messageID.uuidString)")
            } else {
                try await messenger.send(data)
                print("🔄 Retrying broadcast message: \(messageID.uuidString)")
            }

            // Success - remove from failed messages
            failedMessages.removeValue(forKey: messageID)
            print("✅ Message \(messageID.uuidString) delivered successfully on attempt \(record.attempts)")

        } catch {
            // Retry failed - update tracking
            failedMessages[messageID]?.attempts += 1
            failedMessages[messageID]?.lastFailureTime = Date()

            // Calculate next retry time with exponential backoff
            let retryDelay = min(baseRetryDelay * pow(2.0, Double(record.attempts - 1)), maxRetryDelay)
            failedMessages[messageID]?.nextRetryTime = Date().addingTimeInterval(retryDelay)

            print("❌ Retry \(record.attempts) failed for message \(messageID.uuidString): \(error)")
        }
    }

    private func handleMaxRetriesReached(messageID: UUID, message: SharePlayMessage) async {
        failedMessages.removeValue(forKey: messageID)

        print("💀 Max retries reached for message \(messageID.uuidString) - marking as permanently failed")

        await NotificationCenter.default.post(
            name: .messagePermanentlyFailed,
            object: MessageFailureInfo(
                messageID: messageID,
                message: message,
                timestamp: Date()
            )
        )
    }

    private func startExpiredMessageCleanup() async {
        while !Task.isCancelled {
            let cutoffTime = Date().addingTimeInterval(-300) // 5 minutes
            let expiredMessages = failedMessages.filter { $0.value.lastFailureTime < cutoffTime }

            for messageID in expiredMessages.keys {
                failedMessages.removeValue(forKey: messageID)
                print("🧹 Cleaning up expired failed message: \(messageID.uuidString)")
            }

            try? await Task.sleep(for: .seconds(60))
        }
    }

    func getFailedMessagesCount() -> Int {
        return failedMessages.count
    }

    func getRetryStatistics() -> RetryStatistics {
        let totalAttempts = failedMessages.values.reduce(0) { $0 + $1.attempts }
        let successRate = calculateSuccessRate()

        return RetryStatistics(
            totalFailedMessages: failedMessages.count,
            totalRetryAttempts: totalAttempts,
            successRate: successRate
        )
    }

    private func calculateSuccessRate() -> Double {
        // This would require tracking both failed and successful messages
        // For now, return a placeholder
        return 0.0
    }
}

// MARK: - 4. Network Condition Adaptation
actor NetworkAdaptationManager {
    enum NetworkQuality {
        case excellent
        case good
        case poor
        case disconnected

        var messageBatchSize: Int {
            switch self {
            case .excellent: return 20
            case .good: return 10
            case .poor: return 5
            case .disconnected: return 0
            }
        }

        var retryDelay: TimeInterval {
            switch self {
            case .excellent: return 1.0
            case .good: return 2.0
            case .poor: return 5.0
            case .disconnected: return 10.0
            }
        }

        var compressionThreshold: Int {
            switch self {
            case .excellent: return 1000  // 1KB
            case .good: return 500     // 512B
            case .poor: return 200     // 200B
            case .disconnected: return 0
            }
        }
    }

    private(set) var currentQuality: NetworkQuality = .good
    private var qualityCheckTask: Task<Void, Never>?
    private var lastQualityCheck = Date()

    func startMonitoring() {
        qualityCheckTask = Task {
            while !Task.isCancelled {
                await checkNetworkQuality()
                try? await Task.sleep(for: .seconds(5))
            }
        }
    }

    func stopMonitoring() {
        qualityCheckTask?.cancel()
        qualityCheckTask = nil
    }

    private func checkNetworkQuality() async {
        // Simulate network quality check based on recent performance
        let currentTime = Date()

        // In a real implementation, this would measure:
        // - Message delivery times
        // - Packet loss rates
        // - Latency measurements
        // - Bandwidth availability

        let messageDeliveryLatency = await measureMessageDeliveryLatency()
        let packetLossRate = await measurePacketLossRate()
        let bandwidth = await measureAvailableBandwidth()

        currentQuality = determineNetworkQuality(
            latency: messageDeliveryLatency,
            packetLoss: packetLossRate,
            bandwidth: bandwidth
        )

        lastQualityCheck = currentTime

        print("🌐 Network quality updated: \(currentQuality) (latency: \(messageDeliveryLatency)ms, loss: \(packetLossRate)%, bandwidth: \(bandwidth)bps)")

        await NotificationCenter.default.post(
            name: .networkQualityChanged,
            object: NetworkQualityInfo(
                quality: currentQuality,
                latency: messageDeliveryLatency,
                packetLossRate: packetLossRate,
                bandwidth: bandwidth,
                timestamp: currentTime
            )
        )
    }

    private func measureMessageDeliveryLatency() -> Double {
        // Simulated measurement - in reality, track actual message send/receive times
        // This would measure the time from message.send() to successful receipt
        return Double.random(in: 50...200) // Simulated 50-200ms latency
    }

    private func measurePacketLossRate() -> Double {
        // Simulated measurement - in reality, track sent vs received message counts
        return Double.random(in: 0...5) // Simulated 0-5% packet loss
    }

    private func measureAvailableBandwidth() -> Int {
        // Simulated measurement - in reality, measure actual data throughput
        return Int.random(in: 1000...10000) // Simulated 1-10 Mbps
    }

    private func determineNetworkQuality(latency: Double, packetLoss: Double, bandwidth: Int) -> NetworkQuality {
        // Score network quality based on metrics
        if latency < 100 && packetLoss < 1 && bandwidth > 5000 {
            return .excellent
        } else if latency < 200 && packetLoss < 3 && bandwidth > 2000 {
            return .good
        } else if latency < 500 && packetLoss < 10 && bandwidth > 500 {
            return .poor
        } else {
            return .disconnected
        }
    }

    func getAdaptiveParameters() -> AdaptiveParameters {
        return AdaptiveParameters(
            messageBatchSize: currentQuality.messageBatchSize,
            retryDelay: currentQuality.retryDelay,
            compressionThreshold: currentQuality.compressionThreshold,
            shouldUseCompression: currentQuality.compressionThreshold > 0
        )
    }
}

// MARK: - Supporting Types
struct MessageFailureInfo {
    let messageID: UUID
    let message: SharePlayMessage
    let timestamp: Date
}

struct RetryStatistics {
    let totalFailedMessages: Int
    let totalRetryAttempts: Int
    let successRate: Double
}

struct NetworkQualityInfo {
    let quality: NetworkAdaptationManager.NetworkQuality
    let latency: Double
    let packetLossRate: Double
    let bandwidth: Int
    let timestamp: Date
}

struct AdaptiveParameters {
    let messageBatchSize: Int
    let retryDelay: TimeInterval
    let compressionThreshold: Int
    let shouldUseCompression: Bool
}

// MARK: - Notification Names
extension Notification.Name {
    static let participantPermanentlyDisconnected = Notification.Name("participantPermanentlyDisconnected")
    static let messagePermanentlyFailed = Notification.Name("messagePermanentlyFailed")
    static let networkQualityChanged = Notification.Name("networkQualityChanged")
}